classdef snr_processor < handle
    % SNR_PROCESSOR Standard processing object. This file is a template to
    % make a processing object like a beamformer or an intelligibility measure
    %
    %   SNR_PROCESSOR() create processing object
    %   SNR_PROCESSOR(MAINOBJ) create processing object with handle to main object
    %
    % SNR_PROCESSOR Methods:
    %   update  - Function to get a data window and call process function if
    %   there is data available to process
    %   process - Function where processing is done
    %
    % SNR_PROCESSOR Properties:
    %   MainObj       - Handle of main object
    %   Name          - Name of Processor
    %   ChanNames     - Channel names
    %   CurrentSample - Current sample
    %   WindowSize    - Size of window to process, twice this length is
    %   taken and multiplied by the window
    %   FftData       - Fft Data matrix
    %   Tag           - Tag to find object
    %   Win           - Window to use on audio signal standard the sqrt(hanning(2*WindowSize)) is used
    %
    %   Written for the BSc graduation project Acoustic Enhancement via
    %   Beamforming Using Smartphones.
    %
    %   Team:       S. Bosma                R. Brinkman
    %               T. de Rooij             R. Smeding
    %               N. van Wijngaarden      E. Wouters
    %
    %   Supervisor: Jorge Martínez Castañeda
    %
    %   Contact: E.H.Wouters@student.tudelft.nl
    %
    %   See also SNR_PROCESSOR, MAIN_WINDOW
    
    %% Properties
    properties
        MainObj                           % Handle of main object
        Name           = 'SNR Processor'; % Name of Processor
        ChanNameClean  = {};              % Channel names
        ChanNamesNoisy = {};              % Channel names
        CurrentSample  = 1;               % Current sample
        WindowSize     = 2048;            % Size of window to process, twice this length is taken and multiplied by the window
        Snf            = [];              % SNR Data per Frame
        Rf             = [];              % Reference frames
        Ef             = [];              % Difference frames
        Vf             = [];              % Indices of active frames
        SNROptions                        % Struct with options from SNR function
        Tag            = 'snr_processor'; % Tag to find object
    end
    methods
        function obj = snr_processor(mainObj, snrOptions)
            if nargin == 0
                obj.MainObj.DataBuffer = bf_data(obj.MainObj);
                obj.MainObj.UI.PlotSettings = std_selector_ui(figure,obj.MainObj);
                obj.MainObj.DataBuffer.setNChan(1);
                obj.MainObj.DataBuffer.setTotalSamples(48000);
                help snr_processor
            elseif nargin >= 1
                obj.MainObj = mainObj;
            end
            if nargin >= 2
                obj.SNROptions = snrOptions;
            else
                obj.SNROptions.m = 'Vq';
                obj.SNROptions.tf = 0.01;
                fs = 48000;
                obj.SNROptions.kf = round(obj.SNROptions.tf*fs);
            end
        end
        
        function value = Update(obj)
%             disp('Update recieved')
            value = 0;
            if ~isempty(obj.ChanNameClean)
                while obj.CurrentSample + obj.WindowSize*2 <= min(obj.MainObj.DataBuffer.CurrentSample(obj.MainObj.DataBuffer.names2inds({obj.ChanNameClean,obj.ChanNamesNoisy})))
                    value = value + 1;
                    % Load data from buffer
                    dataIn = obj.MainObj.DataBuffer.getAudioData({obj.ChanNameClean,obj.ChanNamesNoisy},obj.CurrentSample,obj.CurrentSample+obj.WindowSize*2-1);
                    S = dataIn(1,:);
                    R = dataIn(2:end,:);

                    % Call process function
    %                 tic
                    for ii = 1:length(obj.ChanNamesNoisy)
                        [snf(ii,:),rf(ii,:),ef(ii,:),vf(ii,:)] = obj.process(S,R(ii,:));
                    end
                    obj.Snf = [obj.Snf;snf];
                    obj.Rf = [obj.Rf;rf];
                    obj.Ef = [obj.Ef;ef];
                    obj.Vf = [obj.Vf;vf];
    %                 toc
                    % TODO return data to buffer or save in property
    %                 disp(dataOut);
                    obj.CurrentSample = obj.CurrentSample + obj.WindowSize;

                    % Write back to buffer
                    obj.MainObj.DataBuffer.addSamples(dataOut,obj.Name,1);
                end
            end
        end
        
        function [snf,rf,ef,vf] = process(obj, s,r)
            % PROCESS 
            %
            %   [snf,rf,ef,vf] = PROCESS(S,R)
            %
            %   S - Clean signal
            %   R - Noisy signal
            %
            %   snf - Signal to noise ratio per frame
            %   rf  - Reference frames
            %   ef  - Difference frames
            %   vf  - Valid frames
            %
            %   m  mode [default = 'V']
            %       w = No VAD - use whole file
            %       v = use sohn VAD to discard silent portions
            %       V = use P.56-based VAD to discard silent portions [default]
            %       a = A-weight the signals
            %       b = weight signals by BS-468
            %       q = use quadratic interpolation to remove delays +- 1 sample
            %       z = do not do any alignment
            %       p = plot results
            %   tf  frame increment [0.01]
            m = obj.SNROptions.m;
            kf = obj.SNROptions.kf;
            
            snmax=100;  % clipping limit for SNR

            % filter the input signals if required

            if any(m=='a')  % A-weighting
                [b,a]=stdspectrum(2,'z',fs);
                s=filter(b,a,s);
                r=filter(b,a,r);
            elseif any(m=='b') %  BS-468 weighting
                [b,a]=stdspectrum(8,'z',fs);
                s=filter(b,a,s);
                r=filter(b,a,r);
            end

            mq=~any(m=='z');
            nr=min(length(r), length(s));
            % kf=round(tf*fs); % length of frame in samples
            ifr=kf+mq:kf:nr-mq; % ending sample of each frame
            ifl=ifr(end);
            nf=numel(ifr);
            rf=sum(reshape(r(mq+1:ifl).^2,kf,nf),1);
            ef=sum(reshape((s(mq+1:ifl)-r(mq+1:ifl)).^2,kf,nf),1);
            if mq
                efm=sum(reshape((s(3:ifl+1)-r(2:ifl)).^2,kf,nf),1);
                efp=sum(reshape((s(1:ifl-1)-r(2:ifl)).^2,kf,nf),1);
                efa=0.5*(efp+efm)-ef;
                efb=0.5*(efp-efm);
                efmk=(abs(efb)<2*efa) & (efa>0); % mask for frames with a valid minimum
                if any(efmk)
                    ef(efmk)=ef(efmk)-0.25*efb(efmk).^2./efa(efmk);
                end
                ef=min(min(ef,efm),efp);
            end

            em=ef==0; % mask for zero noise frames
            rm=rf==0; % mask for zero reference frames
            snf=10*log10((rf+rm)./(ef+em));
            snf(rm)=-snmax;
            snf(em)=snmax;
            
            % select the frames to include

            if any(m=='w')
                vf=true(1,nf); % include all frames
            elseif any(m=='v');
                vs=vadsohn(r,fs,'na');
                nvs=length(vs);
                [vss,vix]=sort([ifr'; vs(:,2)]);
                vjx=zeros(nvs+nf,5);
                vjx(vix,1)=(1:nvs+nf)'; % sorted position
                vjx(1:nf,2)=vjx(1:nf,1)-(1:nf)'; % prev VAD frame end (or 0 or nvs+1 if none)
                vjx(nf+1:end,2)=vjx(nf+1:end,1)-(1:nvs)'; % prev snr frame end (or 0 or nvs+1 if none)
                dvs=[vss(1)-mq; vss(2:end)-vss(1:end-1)];  % number of samples from previous frame boundary
                vjx(:,3)=dvs(vjx(:,1)); % number of samples from previous frame boundary
                vjx(1:nf,4)=vs(min(1+vjx(1:nf,2),nvs),3); % VAD result for samples between prev frame boundary and this one
                vjx(nf+1:end,4)=vs(:,3); % VAD result for samples between prev frame boundary and this one
                vjx(1:nf,5)=1:nf; % SNR frame to accumulte into
                vjx(vjx(nf+1:end,2)>=nf,3)=0;  % zap any VAD frame beyond the last snr fram
                vjx(nf+1:end,5)=min(vjx(nf+1:end,2)+1,nf); % SNR frame to accumulate into
                vf=full(sparse(1,vjx(:,5),vjx(:,3).*vjx(:,4),1,nf))>kf/2; % accumulate into SNR frames and compare with threshold
            else  % default is 'V'
                [~,~,~,vad]=activlev(r,fs);    % do VAD on reference signal
                vf=sum(reshape(vad(mq+1:ifl),kf,nf),1)>kf/2; % find frames that are mostly active
            end
        end
        
        function seg = getSegmentalSNR(obj)
            seg=mean(obj.Snf(obj.Vf));
        end
        
        function glo = getGlobalSNR(obj)
            glo=10*log10(sum(obj.Rf(obj.Vf))/sum(obj.Ef(obj.Vf)));
        end
        
        function varargout = getPlotData(obj)
            kf = obj.SNROptions.kf;
            snv=snf;
            snv(~vf)=NaN;
            snu=snf;
            snu(vf>0)=NaN;
            varargout{1} = [1 nr]/fs;
            varargout{2} = [glo seg; glo seg];
            varargout{3} = ':k';
            varargout{4} = ((1:nf)*kf+(1-kf)/2)/fs;
            varargout{5} = snv;
            varargout{6} = '-b';
            varargout{7} = ((1:nf)*kf+(1-kf)/2)/fs;
            varargout{8} = snu;
            varargout{9} = '-r';
        end
    end
end

% This file is partly based on:
function [seg,glo]=snrseg(s,r,fs,m,tf)
%SNRSEG Measure segmental and global SNR [SEG,GLO]=(S,R,FS,M,TF)
%
%Usage: (1) seg=snrseg(s,r,fs);                  % s & r are noisy and clean signal
%       (2) seg=snrseg(s,r,fs,'wz');             % no VAD or inerpolation used ['Vq' is default]
%       (3) [seg,glo]=snrseg(s,r,fs,'Vq',0.03);  % 30 ms frames
%
% Inputs:    s  test signal
%            r  reference signal
%           fs  sample frequency (Hz)
%            m  mode [default = 'V']
%                 w = No VAD - use whole file
%                 v = use sohn VAD to discard silent portions
%                 V = use P.56-based VAD to discard silent portions [default]
%                 a = A-weight the signals
%                 b = weight signals by BS-468
%                 q = use quadratic interpolation to remove delays +- 1 sample
%                 z = do not do any alignment
%                 p = plot results
%           tf  frame increment [0.01]
%
% Outputs: seg = Segmental SNR in dB
%          glo = Global SNR in dB (typically 7 dB greater than SNR-seg)
%
% This function compares a noisy signal, S, with a clean reference, R, and
% computes the segemntal signal-to-noise ratio (SNR) in dB. The signals,
% which must be of the same length, are split into non-overlapping frames
% of length TF (default 10 ms) and the SNR of each frame in dB is calculated.
% The segmental SNR is the average of these values, i.e.
%         SEG = mean(10*log10(sum(Ri^2)/sum((Si-Ri)^2))
% where the mean is over frames and the sum runs over one particular frame.
% Two optional modifications can be made to this basic formula:
%
%    (a) Frames are excluded if there is no significant energy in the R
%        signal. The idea is to limit the calculation to frames in which
%        speech is active. By default, the voicebox function "activlev" is
%        used to detect the inactive frames (the 'V' mode option).
%
%    (b) In each frame independently, the reference signal is shifted by up
%        to +- 1 sample to find the alignment than minimizes the noise
%        component (S-R)^2. This shifting accounts for small misalignments
%        and/or sample frequency differences between the two signals. For
%        larger shifts, you can use the voicebox function "sigalign".
%        Accurate alignemnt is especially important at high SNR values.
%
% If no M argument is specified, both these modifications will be applied;
% this is equivalent to specifying M='Vq'.

% Bugs/suggestions
% (1) Optionally restrict the bandwidth to the smaller of the two
%     bandwidths either with an extra parameter or automatically determined

%      Copyright (C) Mike Brookes 2011
%      Version: $Id: snrseg.m 2953 2013-05-02 12:51:26Z dmb $
%
%   VOICEBOX is a MATLAB toolbox for speech processing.
%   Home page: http://www.ee.ic.ac.uk/hp/staff/dmb/voicebox/voicebox.html
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   This program is free software; you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation; either version 2 of the License, or
%   (at your option) any later version.
%
%   This program is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You can obtain a copy of the GNU General Public License from
%   http://www.gnu.org/copyleft/gpl.html or by writing to
%   Free Software Foundation, Inc.,675 Mass Ave, Cambridge, MA 02139, USA.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if nargin<4 || ~ischar(m)
        m='Vq';
    end
    if nargin<5 || ~numel(tf)
        tf=0.01; % default frame length is 10 ms
    end
    snmax=100;  % clipping limit for SNR

    % filter the input signals if required

    if any(m=='a')  % A-weighting
        [b,a]=stdspectrum(2,'z',fs);
        s=filter(b,a,s);
        r=filter(b,a,r);
    elseif any(m=='b') %  BS-468 weighting
        [b,a]=stdspectrum(8,'z',fs);
        s=filter(b,a,s);
        r=filter(b,a,r);
    end

    mq=~any(m=='z');
    nr=min(length(r), length(s));
    kf=round(tf*fs); % length of frame in samples
    ifr=kf+mq:kf:nr-mq; % ending sample of each frame
    ifl=ifr(end);
    nf=numel(ifr);
    rf=sum(reshape(r(mq+1:ifl).^2,kf,nf),1);
    ef=sum(reshape((s(mq+1:ifl)-r(mq+1:ifl)).^2,kf,nf),1);
    if mq
        efm=sum(reshape((s(3:ifl+1)-r(2:ifl)).^2,kf,nf),1);
        efp=sum(reshape((s(1:ifl-1)-r(2:ifl)).^2,kf,nf),1);
        efa=0.5*(efp+efm)-ef;
        efb=0.5*(efp-efm);
        efmk=(abs(efb)<2*efa) & (efa>0); % mask for frames with a valid minimum
        if any(efmk)
            ef(efmk)=ef(efmk)-0.25*efb(efmk).^2./efa(efmk);
        end
        ef=min(min(ef,efm),efp);
    end

    em=ef==0; % mask for zero noise frames
    rm=rf==0; % mask for zero reference frames
    snf=10*log10((rf+rm)./(ef+em));
    snf(rm)=-snmax;
    snf(em)=snmax;

    % select the frames to include

    if any(m=='w')
        vf=true(1,nf); % include all frames
    elseif any(m=='v');
        vs=vadsohn(r,fs,'na');
        nvs=length(vs);
        [vss,vix]=sort([ifr'; vs(:,2)]);
        vjx=zeros(nvs+nf,5);
        vjx(vix,1)=(1:nvs+nf)'; % sorted position
        vjx(1:nf,2)=vjx(1:nf,1)-(1:nf)'; % prev VAD frame end (or 0 or nvs+1 if none)
        vjx(nf+1:end,2)=vjx(nf+1:end,1)-(1:nvs)'; % prev snr frame end (or 0 or nvs+1 if none)
        dvs=[vss(1)-mq; vss(2:end)-vss(1:end-1)];  % number of samples from previous frame boundary
        vjx(:,3)=dvs(vjx(:,1)); % number of samples from previous frame boundary
        vjx(1:nf,4)=vs(min(1+vjx(1:nf,2),nvs),3); % VAD result for samples between prev frame boundary and this one
        vjx(nf+1:end,4)=vs(:,3); % VAD result for samples between prev frame boundary and this one
        vjx(1:nf,5)=1:nf; % SNR frame to accumulte into
        vjx(vjx(nf+1:end,2)>=nf,3)=0;  % zap any VAD frame beyond the last snr fram
        vjx(nf+1:end,5)=min(vjx(nf+1:end,2)+1,nf); % SNR frame to accumulate into
        vf=full(sparse(1,vjx(:,5),vjx(:,3).*vjx(:,4),1,nf))>kf/2; % accumulate into SNR frames and compare with threshold
    else  % default is 'V'
        [~,~,~,vad]=activlev(r,fs);    % do VAD on reference signal
        vf=sum(reshape(vad(mq+1:ifl),kf,nf),1)>kf/2; % find frames that are mostly active
    end
    seg=mean(snf(vf));
    glo=10*log10(sum(rf(vf))/sum(ef(vf)));

    if ~nargout || any (m=='p')
        subplot(311);
        plot((1:length(s))/fs,s);
        ylabel('Signal');
        title(sprintf('SNR = %.1f dB, SNR_{seg} = %.1f dB',glo,seg));
        axh(1)=gca;
        subplot(312);
        plot((1:length(r))/fs,r);
        ylabel('Reference');
        axh(2)=gca;
        subplot(313);
        snv=snf;
        snv(~vf)=NaN;
        snu=snf;
        snu(vf>0)=NaN;
        plot([1 nr]/fs,[glo seg; glo seg],':k',((1:nf)*kf+(1-kf)/2)/fs,snv,'-b',((1:nf)*kf+(1-kf)/2)/fs,snu,'-r');
        ylabel('Frame SNR');
        xlabel('Time (s)');
        axh(3)=gca;
        linkaxes(axh,'x');
    end
end