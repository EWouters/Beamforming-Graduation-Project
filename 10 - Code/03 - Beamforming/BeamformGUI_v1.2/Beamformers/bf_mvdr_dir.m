classdef bf_mvdr_dir < handle
    % BF_DATA Standard processing object. This file is a template to
    % make a processing object like a beamformer or an intelligibility measure
    %
    %   BF_DATA() create processing object
    %   BF_DATA(MAINOBJ) create processing object with handle to main object
    %
    % BF_DATA Methods:
    %   update  - Function to get a data window and call process function if
    %   there is data available to process
    %   process - Function where processing is done
    %
    % BF_DATA Properties:
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
    %   See also BF_DATA, MAIN_WINDOW
    
    %% Properties
    properties
        MainObj                             % Handle of main object
        Name          = 'MVDR Beamformer';  % Name of Processor
        MicNames     = {};                 % Channel names
        SourceNames     = {};                 % Channel names
        NMics         = 0;
        IsInitialized = 0;
        CurrentSample = 1;                  % Current sample
        WindowSize    = 2048;               % Size of window to process, twice this length is taken and multiplied by the window
        Weights       = [];                 % Weights matrix
        Fs            = 48000;              % sample rate in Hz
        c             = 342;                % speed of sound
        L_b           = 2048                % length of block?   default: 2048
        L_be          = 2^nextpow2(floor(48000.*0.016)); % ??? default: 2^nextpow2(floor(fs.*0.016))
        EP_ss
        delta_s       = 0.90; % Parameter to control weighing of current and previous EP_ss
        epsil         = 10^-1 % Regularization factor, default: regfactmvdr =10^-1; om inversie makkelijker te maken (ill conditioned) en white noise gain filter. Normale kamer: 10e-1 en 10e-3. Simulatie: 10e-10 tot 10e-9
        Win                                 % Window to use on audio signal
        Tag           = 'bf_mvdr';    % Tag to find object
        x_s
        x_m
    end
    methods
        function obj = bf_mvdr_dir(mainObj)
            if nargin == 0
                obj.MainObj.Parent = std_panel(figure, grid2pos([]),obj.Name);
%                 obj.MainObj.Update = str2func('obj.Update');
                obj.MainObj.DataBuffer = bf_data(obj.MainObj);
                obj.MainObj.DataBuffer.load([]);
                obj.MainObj.UI.BFChannels = std_selector_ui(obj.MainObj.Parent.Panel,obj.MainObj);
                help bf_mvdr
            elseif nargin >= 1
                obj.MainObj = mainObj;
            end
            
%             obj.Initialize();
            
            % Debug
%             assignin('base','obj',obj)
        end
        
        function obj = Initialize(obj)
            obj.MainObj.UI.BFChannels.Update();
            obj.Fs = obj.MainObj.DataBuffer.Fs;
            obj.Win = repmat(sqrt(hanning(2*obj.WindowSize)),1,size(obj.MainObj.UI.BFChannels.ChanNames,1));
            obj.EP_ss = sparse(obj.NMics*(obj.L_b+1),obj.NMics*(obj.L_b+1));
            obj.Weights = [];
            
            
            % Get constants
            fs = obj.Fs;
            c = obj.c;
            L_b = obj.L_b; %#ok<*PROP>
            L_be = obj.L_be;
            EP_ss = obj.EP_ss;
            delta_s = obj.delta_s;
            epsil = obj.epsil;
            win = obj.Win;
            Nmics = obj.NMics;
            x_m = obj.x_m;
            x_s = obj.x_s;
            
            
            chanNames = obj.MainObj.UI.BFChannels.ChanNames;
            
            typeStr = {'Mic','Source','Noise'};
            micNames = [];
            sourceNames = [];
            noiseNames = [];
            for ii = 1:length(chanNames)
                if ~isempty(strfind(chanNames{ii},':')) || ~isempty(strfind(chanNames{ii},'Mic'))
                    micNames = [micNames ii];
                elseif strfind(chanNames{ii},'Source')
                    sourceNames = [sourceNames ii];
                elseif strfind(chanNames{ii},'Noise')
                    noiseNames = [noiseNames ii];
                end
            end
            obj.MicNames = chanNames(micNames);
            obj.SourceNames = chanNames(sourceNames);
            noiseNames = chanNames(noiseNames);
            
            if isempty(obj.MicNames)
                warning('No mics')
                obj.IsInitialized = 0;
                return;
            end
            if isempty(obj.SourceNames)
                warning('No sources')
                obj.IsInitialized = 0;
                return;
            end
            
            obj.x_m = obj.MainObj.DataBuffer.Locations(obj.MainObj.DataBuffer.names2inds(obj.MicNames),:);
            obj.x_s = obj.MainObj.DataBuffer.Locations(obj.MainObj.DataBuffer.names2inds(obj.SourceNames),1:3);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            %% Load directivity here
            
            g = 1;
            if 0
                for ii = 1:size(obj.MicNames,2)
                    g(:,ii) = directivity(x_m(ii,:),x_s);
                end
            elseif 0
                for ii = 1:size(obj.MicNames,2)
                    g(:,ii) = directivity([0 0 0 0 0 0],[0 0 0]);
                end
            end
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            obj.IsInitialized = 1;
            
            xinput = obj.MainObj.DataBuffer.getAudioData(obj.MicNames);
            
            [ymvdr, W, EP_ss] = MVDR(fs,c,L_b,L_be,x_m(:,1:3),x_s,xinput,epsil,delta_s,EP_ss,win, g);
            
            
            obj.MainObj.DataBuffer.addSamples(ymvdr, obj.Name,1);
            obj.Weights = W;
            obj.EP_ss = EP_ss;
        end
        
    end
end

function [ymvdr, W, EP_ss] = MVDR(fs,c,L_b,L_be,x_m,x_s,xinput,epsil,delta_s,EP_ss,win, g)
    % Algorithm. Author: dr. Jorge Martinez (J.A.MartinezCastaneda@TuDelft.nl)
    Nmics = size(x_m,1);
    k =((0:L_b).'.*pi.*fs./L_b)./c;
    dn = distcalc(x_m,x_s);
    a = 1./(4*pi.*dn);
    D = repmat(a,L_b+1,1).*exp(-1i.*k*dn);
    sim_l = size(xinput,1);
    epsilon = speye(Nmics*(L_b+1)).*epsil;
    mLb = L_b/L_be;
    ymvdr = zeros(sim_l,1);
    sim_lb=ceil(sim_l/L_b)-1;
    
    win = repmat(win,1,Nmics);

    for t = 1:sim_lb-1
        auxt=((1:2*L_b)+(t-1)*L_b).';
        X = fft(xinput(auxt,1:Nmics).*win);
        for te = 1:mLb-1
            if 2*L_b + (t-1)*L_b + (te+1)*L_be < sim_l;
                auxte = ((1:2*L_b) + (t-1)*L_b + (te-1)*L_be).';
                X_s = fft(xinput(auxte,1:Nmics).*win);

                EP_ss = pwest(L_b,Nmics,X_s,EP_ss,delta_s,te+t == 2);
            end
        end
        [W, Xmvdr] = mvdrcoreBAP(L_b,Nmics,X,EP_ss,epsilon,D, g);
        ovl= ifft(Xmvdr,'symmetric');
        ymvdr(auxt) = ymvdr(auxt) + ovl.*win(:,1);
    end

end

function varargout = mvdrcoreBAP(L_b,Nmics,X,EP_ss,epsilon,D,varargin)
% Author: dr. Jorge Martinez (J.A.MartinezCastaneda@TuDelft.nl)
% This is used for realtime? 
% Inputs:
% L_b  - length of block?   default: 2048
% Nmics - number of microphones
% X - input signal
% EP_ss - ?? default: sparse(zeros(Nmics*(L_b+1),Nmics*(L_b+1)))
% epsilon - Regularization factor, default: regfactmvdr =10^-1;
% D - delays, default: repmat(a,L_b+1,1).*exp(-1i.*k*dn); a = 1./(4*pi.*dn); dn = distcalc(x_m,x_s);
% varargin - ??

    X = X(1:L_b+1,:).';
    MX = mat2cell(X,Nmics,ones(L_b+1,1));
    Xblk = sparse(blkdiag(MX{:}));

    D = D.';
    D = D(:);    
    
    if nargin > 6
        g = varargin{1};
        if g ~= 1
            G =  fft(g);
            G = G(1:L_b+1,1:Nmics).';
            G = G(:);
            D = D.*G;
        end
    end
    
    P_ss = EP_ss+epsilon;
    P_ss_D = P_ss\D;
    
    MPssD=mat2cell(reshape(P_ss_D,Nmics,L_b+1),Nmics,ones(L_b+1,1));
    PssDblk = sparse(blkdiag(MPssD{:}));
    DPssD = D'*PssDblk;
    DPssD = repmat(DPssD,Nmics,1);
    DPssD=DPssD(:);

    W = P_ss_D./DPssD;
    varargout{1} = W;
    if nargout > 1
        Xmvdr = W'*Xblk;
        Xmvdr = [Xmvdr.' ; zeros(L_b-1,1)];
        varargout{2} = Xmvdr;
    end
        
end

function D=distcalc(Mpos,Lpos)
    % DISTCAL Binary distance calculator for valid device matrices.
    % Author: dr. Jorge Martinez (J.A.MartinezCastaneda@TuDelft.nl)

    M=size(Mpos,1);
    L=size(Lpos,1);

    dotprods=Lpos*Mpos.';
    Lsqrprods=diag(Lpos*Lpos.');
    Msqrprods=diag(Mpos*Mpos.').';
    D=(repmat(Lsqrprods,1,M)+repmat(Msqrprods,L,1)-(2.*dotprods)).^0.5;
end


function ymvdr = mvdrbfBAP(fs,c,L_b,L_be,x_m,x_s,xinput,epsil,delta_s,rtflag)
    % Author: dr. Jorge Martinez (J.A.MartinezCastaneda@TuDelft.nl).
    %
    % Inputs:
    % fs - sample rate in Hz
    % c  - speed of sound
    % L_b  - length of block?   default: 2048
    % L_be - ???                default: 2^nextpow2(floor(fs.*0.016));
    % x_m - Microphone positions [x y z;]
    % x_s - focal_point? of beamformer [x y z;]. Can this be a vector?
    % xinput - getexcerpsBAP(sourcein,Nmics,fs,sim_time,recdata,datadir);
    % epsil - Regularization factor, default: regfactmvdr =10^-1; om inversie
    % makkelijker te maken (ill conditioned) en white noise gain filter.
    % Normale kamer: 10e-1 en 10e-3
    % Simulatie:   10e-10 tot 10e-9
    % delta_s - ???         default: delta_s = 0.90;
    % rtflag - real time flag

    if logical(mod(L_b/L_be,1))
        error('Beamforming:mvdrbf','The block size for power estimation must be an integer multiple of the block size for the beamforming process');
    end


    Nmics = size(x_m,1);
    dn = distcalc(x_m,x_s);
    omega=(0:L_b).'.*pi.*fs./L_b;
    k = omega./c;

    a = 1./(4*pi.*dn);
    D = repmat(a,L_b+1,1).*exp(-1i.*k*dn);

    sim_l = size(xinput,1);

    epsilon = speye(Nmics*(L_b+1)).*epsil;
    mLb = L_b/L_be;

    win = sqrt(hanning(2*L_b));
    win = repmat(win,1,Nmics);


    ymvdr = zeros(sim_l,1);

    sim_lb=ceil(sim_l/L_b)-1;

    EP_ss = sparse(Nmics*(L_b+1),Nmics*(L_b+1));

    if ~rtflag
        %wait_h = waitbar(0,'Calculating PSD','Position',[138.4 345.6 308 60],'Name','Please wait');
        for te = 1:sim_lb-1
            auxte = ((1:2*L_b) + (te-1)*L_b ).';
            X_s = fft(xinput(auxte,1:Nmics).*win);

            EP_ss= pwest(L_b,Nmics,X_s,EP_ss,delta_s,te == 1);
            %waitbar(te/sim_lb,wait_h);
        end
        %close(wait_h);
        [~, W]= mvdrcoreBAP(L_b,Nmics,X_s,EP_ss,epsilon,D);
    end



    %wait_h = waitbar(0,'Applying the beamformer','Position',[138.4 345.6 308 60],'Name','Please wait');
    for t = 1:sim_lb-1
        auxt=((1:2*L_b)+(t-1)*L_b).';
        X = fft(xinput(auxt,1:Nmics).*win);

        if rtflag
            for te = 1:mLb-1
                if 2*L_b + (t-1)*L_b + (te+1)*L_be < sim_l;
                    auxte = ((1:2*L_b) + (t-1)*L_b + (te-1)*L_be).';
                    X_s = fft(xinput(auxte,1:Nmics).*win);

                    EP_ss = pwest(L_b,Nmics,X_s,EP_ss,delta_s,te+t == 2);
                end
            end
            Xmvdr = mvdrcore(L_b,Nmics,X,EP_ss,epsilon,D);
        else
            X = X(1:L_b+1,:).';
            MX = mat2cell(X,Nmics,ones(L_b+1,1));
            Xblk = sparse(blkdiag(MX{:}));
            Xmvdr = W'*Xblk;
            Xmvdr = [Xmvdr.' ; zeros(L_b-1,1)];
        end

        ovl= ifft(Xmvdr,'symmetric');
        ymvdr(auxt) = ymvdr(auxt) + ovl.*win(:,1);


        %waitbar(t/sim_lb,wait_h);
    end
    ymvdr = ymvdr./max(abs(ymvdr));

    %close(wait_h);

    return
end