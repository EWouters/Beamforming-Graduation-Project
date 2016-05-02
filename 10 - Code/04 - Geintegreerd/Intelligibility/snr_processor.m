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
        Parent
        PlotParent
        MainObj                           % Handle of main object
        Name           = 'SNR Processor'; % Name of Processor
        ChanNameClean  = {};              % Channel names
        ChanNamesNoisy = {};              % Channel names
        CurrentSample  = 1;               % Current sample
        WindowSize     = 2048;            % Size of window to process, twice this length is taken and multiplied by the window
        SigalignOpt    = 'g';
        SNROpt         = 'Vq';
        Seg
        Glo
        STOI
        PESQ
        MicNames
        SourceNames
        NMics = 0;
        x_m
        x_s
        IsInitialized 
        
        Snf            = [];              % SNR Data per Frame
        Rf             = [];              % Reference frames
        Ef             = [];              % Difference frames
        Vf             = [];              % Indices of active frames
        Nf
        Nr
        SNROptions                        % Struct with options from SNR function
        Tag            = 'snr_processor'; % Tag to find object
        UI
        PlotUI
        IntelProcessor
    end
    methods
        function obj = snr_processor(parent, plotParent, mainObj, snrOptions)
            % Parse Input
            % figure Handle
            if nargin == 0
                obj.Parent = figure('Name',obj.Name,'NumberTitle','off','resize','on');
            elseif nargin >= 1
                if ishandle(parent)
                    obj.Parent = parent;
                else
                    warning(['First argument needs to be a handle,'...
                        'new figure created.']);
                    obj.Parent = figure('Name',obj.Name,'NumberTitle','off','resize','on');
                end
            end
            if nargin < 2
                obj.PlotParent = figure('Name',[obj.Name ' Plots'],'NumberTitle','off','resize','on');
            else
                if ishandle(plotParent)
                    obj.PlotParent = plotParent;
                else
                    warning(['First argument needs to be a handle,'...
                        'new figure created.']);
                    obj.PlotParent = figure('Name',[obj.Name ' Plots'],'NumberTitle','off','resize','on');
                end
            end
            if nargin >= 3
                obj.MainObj = mainObj;
            else
                obj.MainObj.Parent = std_panel(figure, grid2pos([]),obj.Name);
                obj.MainObj.DataBuffer = bf_data(obj.MainObj);
                obj.MainObj.DataBuffer.load([]);
                obj.MainObj.UI.IntelChannels = std_selector_ui(obj.MainObj.Parent.Panel,obj.MainObj);
                help snr_processor
            end
            if nargin >= 4
                obj.SNROptions = snrOptions;
            else
                obj.SNROptions.m = 'Vq';
                obj.SNROptions.tf = 0.01;
                fs = 48000;
                obj.SNROptions.kf = round(obj.SNROptions.tf*fs);
            end
            
            obj.IntelProcessor = intel_processor(obj.MainObj);
            
%             obj.Initialize();

            % Graphics Code
            obj.UI = obj.graphicsCode();
            
            % Debug
%             assignin('base','obj',obj);
        end
        
        function obj = Initialize(obj,~,~)
            obj.MainObj.UI.IntelChannels.Update();
            
            obj.MainObj.UI.IntelChannels.Update();
            chanNames = obj.MainObj.UI.IntelChannels.ChanNames;
            if isempty(chanNames)
                warning('No channels connected');
                obj.UI.txNMics.String = 'Not Initialized: No channels';
                obj.IsInitialized = 0;
                try
                    obj.MainObj.UI.Intel.TabGroup1.SelectedTab = obj.MainObj.UI.Intel.Tabs{1};
                catch %#ok<CTCH>
                end
                return;
            else
                obj.IsInitialized = 1;
            end
            
            typeStr = {'Mic','Source','Noise'};
            micNames = [];
            sourceNames = [];
            noiseNames = [];
            for ii = 1:length(chanNames)
                if ~isempty(strfind(chanNames{ii},':')) || ...
                        ~isempty(strfind(chanNames{ii},'Mic')) || ...
                        ~isempty(strfind(chanNames{ii},'Beamformer'))
                    micNames = [micNames ii];
                elseif strfind(chanNames{ii},'Source')
                    sourceNames = [sourceNames ii];
                elseif strfind(chanNames{ii},'Noise')
                    noiseNames = [noiseNames ii];
                end
            end
            obj.MicNames = chanNames(micNames);
            obj.NMics = size(obj.MicNames,2);
            obj.SourceNames = chanNames(sourceNames);
            noiseNames = chanNames(noiseNames);
            
            if isempty(obj.MicNames)
                warning('No mics');
                obj.IsInitialized = 0;
                obj.UI.txNMics.String = 'Not Initialized: No mics';
                try
                    obj.MainObj.UI.Settings.TabGroup1.SelectedTab = obj.MainObj.UI.Settings.Tabs{2};
                catch %#ok<CTCH>
                end
                return;
            end
            if isempty(obj.SourceNames)
                warning('No sources');
                obj.IsInitialized = 0;
                obj.UI.txNMics.String = 'Not Initialized: No source';
                try
                    obj.MainObj.UI.Settings.TabGroup1.SelectedTab = obj.MainObj.UI.Settings.Tabs{2};
                catch %#ok<CTCH>
                end
                return;
            end
            
            obj.CurrentSample = 1;
                
            if obj.IsInitialized
                obj.x_m = obj.MainObj.DataBuffer.Locations(obj.MainObj.DataBuffer.names2inds(obj.MicNames),1:3);
                obj.x_s = obj.MainObj.DataBuffer.Locations(obj.MainObj.DataBuffer.names2inds(obj.SourceNames),1:3);

                obj.UI.txNMics.String = sprintf('Initialized with %i channels and 1 source',obj.NMics);
                obj.UI.pbProcessAtOnceSNR.Enable = 'On';
                obj.UI.pbProcessAtOnceSTOIPESQ.Enable = 'On';
                obj.UI.pbProcess.Enable = 'On';
            else
                obj.UI.txNMics.String = 'Not Initialized';
                obj.UI.pbProcessAtOnceSNR.Enable = 'Off';
                obj.UI.pbProcessAtOnceSTOIPESQ.Enable = 'Off';
                obj.UI.pbPlot.Enable = 'Off';
                obj.UI.pbProcess.Enable = 'Off';
            end
            
%             s = obj.MainObj.DataBuffer.getAudioData(obj.MicNames);
%             r = obj.MainObj.DataBuffer.getAudioData(obj.SourceNames);
%             
%             
%             m=obj.m;
%             tf = obj.WindowSize/obj.MainObj.DataBuffer.Fs;
%             for ii = 1:size(obj.MicNames,2)
%                 [~,~,rr,ss] = sigalign(s(:,ii),r,1/4,'g');
%                 [seg(ii),glo(ii)] = snrseg(ss,rr,fs,m,tf);
%             end
%             
%             obj.Seg = seg;
%             obj.Glo = glo;
        end
        
        function value = Update(obj,~,~)
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
        
%         function seg = getSegmentalSNR(obj)
%             seg=mean(obj.Snf(obj.Vf));
%         end
%         
%         function glo = getGlobalSNR(obj)
%             glo=10*log10(sum(obj.Rf(obj.Vf))/sum(obj.Ef(obj.Vf)));
%         end
%         
%         function varargout = getPlotData(obj)
%             kf = obj.SNROptions.kf;
%             snv=snf;
%             snv(~vf)=NaN;
%             snu=snf;
%             snu(vf>0)=NaN;
%             varargout{1} = [1 nr]/fs;
%             varargout{2} = [glo seg; glo seg];
%             varargout{3} = ':k';
%             varargout{4} = ((1:nf)*kf+(1-kf)/2)/fs;
%             varargout{5} = snv;
%             varargout{6} = '-b';
%             varargout{7} = ((1:nf)*kf+(1-kf)/2)/fs;
%             varargout{8} = snu;
%             varargout{9} = '-r';
%         end
        
        %% Button Process Callback
        function pbProcessAtOnceSNR_Callback(obj,~,~)
            if obj.IsInitialized
                wait_h = waitbar(0,'Calculating SNR and SNR_{seg}','Name', 'Please wait');
                
                obj.UI.pbProcessAtOnceSNR.Enable = 'Off';
                s = obj.MainObj.DataBuffer.getAudioData(obj.MicNames);
                r = obj.MainObj.DataBuffer.getAudioData(obj.SourceNames);
                sigalignOpt = obj.SigalignOpt;
                snrOpt = obj.SNROpt;
                fs = obj.MainObj.DataBuffer.Fs;
                tf = obj.WindowSize/fs;
                nMics = obj.NMics;
                nFrames = 1;
                
                micNames = obj.MicNames;
                for ii = 1:size(obj.MicNames,2)
                    waitbar(ii/2/nMics,wait_h,sprintf('Alligning %s to reference signal',micNames{ii}));
                    [~,~,rr,ss] = sigalign(s(:,ii),r,1/4,sigalignOpt,fs);
                    waitbar((ii+1)/2/nMics,wait_h,sprintf('Calculating SNR for %s',micNames{ii}));
                    [seg(ii),glo(ii), snf{ii},rf{ii},ef{ii},vf{ii},nf(ii),nr(ii)] = snrseg(ss,rr,fs,snrOpt,tf);
                end
                obj.Seg = seg;
                obj.Glo = glo;
                obj.Snf = snf;
                obj.Rf = rf;
                obj.Ef = ef;
                obj.Vf = vf;
                obj.Nf = nf;
                obj.Nr = nr;
                
                close(wait_h);
                
                obj.UI.pbProcessAtOnceSNR.Enable = 'On';
                obj.UI.pbPlot.Enable = 'On';
            else
                obj.UI.pbPlot.Enable = 'Off';
                obj.Initialize();
            end
        end
        
        %% Button Process Callback
        function pbProcessAtOnceSTOIPESQ_Callback(obj,~,~)
            if obj.IsInitialized
                obj.UI.pbProcessAtOnceSTOIPESQ.Enable = 'Off';
                obj.IntelProcessor.Initialize();
                obj.STOI = obj.IntelProcessor.Stoi;
                obj.PESQ = obj.IntelProcessor.Pesq;
                obj.UI.pbProcessAtOnceSTOIPESQ.Enable = 'On';
                obj.UI.pbPlot.Enable = 'On';
            end
        end
        
        %% Button Plot Callback
        function pbPlot_Callback(obj,~,~)
            if obj.IsInitialized
                if size(obj.Glo) ~= obj.NMics;
                    obj.IsInitialized = 0;
                    warning('SNR not up to date')
                    obj.Initialize();
                    return;
                end
                if size(obj.STOI) ~= obj.NMics;
                    warning('STOI or PESQ not up to date')
                    obj.Initialize();
                    return;
                end
                obj.PlotUI = obj.plotGraphics();
                try
                    obj.MainObj.UI.Plots.TabGroup1.SelectedTab = obj.MainObj.UI.Plots.Tabs{3};
                catch %#ok<CTCH>
                end
                return;
            end
        end
        
        %% Button All Callback
        function pbAll_Callback(obj,~,~)
            obj.Initialize();
            obj.pbProcessAtOnceSNR_Callback();
            obj.pbProcessAtOnceSTOIPESQ_Callback();
            obj.pbPlot_Callback();
        end
            
        %% UI Selection Callback
        function selectionChanged_Callback(obj,~,~)
            % Window size
            windowSize = str2double(obj.UI.edWindowSize.String);
            if isnumeric(windowSize) && isfinite(windowSize)
                if windowSize > 1/obj.MainObj.DataBuffer.Fs;
                    obj.WindowSize = round(windowSize*obj.MainObj.DataBuffer.Fs);
                    obj.UI.edWindowSize.String = mat2str(windowSize);
                end
            end
            obj.SigalignOpt = obj.UI.edSigalign.String;
            obj.SNROpt = obj.UI.edSNR.String;
        end
        
        %% SNR Processor Graphics Code
        
        function UI = graphicsCode(obj)
            % GRAPHICSCODE Graphics Code
            % SNR Processor UI panel
            x=3;y=8;
            UI.txNMics = uicontrol(obj.Parent,'Style','text',...
                'String','Not Initialized','FontWeight','Bold',...
                'Units','normalized','Position',grid2pos([1,1,1,1,1,y]));
            UI.txWindowSize = uicontrol(obj.Parent,'Style','text',...
                'String','SNR Window size in seconds:',...
                'Units','normalized','Position',grid2pos([1,2,2,1,x,y]));
            UI.edWindowSize = uicontrol(obj.Parent,'Style','edit',...
                'String',mat2str(obj.WindowSize/obj.MainObj.DataBuffer.Fs),...
                'Callback',@obj.selectionChanged_Callback,...
                'Units','normalized','Position',grid2pos([3,2,1,1,x,y]));
            UI.txSigalign = uicontrol(obj.Parent,'Style','text',...
                'String','sigalign options',...
                'Units','normalized','Position',grid2pos([1,3,2,1,x,y]));
            UI.edSigalign = uicontrol(obj.Parent,'Style','edit',...
                'String',obj.SigalignOpt,...
                'Units','normalized','Position',grid2pos([3,3,1,1,x,y]));
            UI.txSNR = uicontrol(obj.Parent,'Style','text',...
                'String','snrseg options',...
                'Units','normalized','Position',grid2pos([1,4,2,1,x,y]));
            UI.edSNR = uicontrol(obj.Parent,'Style','edit',...
                'String',obj.SNROpt,...
                'Units','normalized','Position',grid2pos([3,4,1,1,x,y]));
            UI.pbInitialize = uicontrol(obj.Parent,'Style','pushbutton',...
                'String','Initialize','Callback',@obj.Initialize,...
                'Units','normalized','Position',grid2pos([1,7,1,1,x,y]));
            UI.pbProcess = uicontrol(obj.Parent,'Style','pushbutton',...
                'String','Process','Callback',@obj.Update, 'Enable', 'Off',...
                'Units','normalized','Position',grid2pos([2,7,1,1,x,y]));
            UI.pbProcessAtOnceSNR = uicontrol(obj.Parent,'Style','pushbutton',...
                'String','Process SNR at once','Callback',@obj.pbProcessAtOnceSNR_Callback,...
                'Units','normalized','Position',grid2pos([1,8,1,1,x,y]), 'Enable', 'Off');
            UI.pbProcessAtOnceSTOIPESQ = uicontrol(obj.Parent,'Style','pushbutton', 'Enable', 'Off',...
                'String','Process STOI and PESQ','Callback',@obj.pbProcessAtOnceSTOIPESQ_Callback,...
                'Units','normalized','Position',grid2pos([2,8,1,1,x,y]));
            UI.pbPlot = uicontrol(obj.Parent,'Style','pushbutton', 'Enable', 'Off',...
                'String','Plot Results','Callback',@obj.pbPlot_Callback,...
                'Units','normalized','Position',grid2pos([3,8,1,1,x,y]));
            
            UI.pbAll = uicontrol(obj.Parent,'Style','pushbutton',...
                'String','Init,Process and Plot','Callback',@obj.pbAll_Callback,...
                'Units','normalized','Position',grid2pos([3,7,1,1,x,y]));
        end
        
        %% Plot SNR Graphics Code
        
        function plotUI = plotGraphics(obj)
            % SNR Processor Plot UI panel
            if ~obj.IsInitialized
                warning('Could not plot SNR because object is not initialized');
            else
                % Clean up ui elements
                oldUI = findobj('Tag','SNR_plot');
                if ~isempty(oldUI)
                    delete(oldUI);
                    clear('obj.PlotUI');
                end
                % Create new plots
                x=7;y=4*obj.NMics;
                sp = 0.05;
                
                fs = obj.MainObj.DataBuffer.Fs;
                tf = obj.WindowSize/fs;
                kf=round(tf*fs); % length of frame in samples
%                 nf = size(obj.Vf,2);
%                 nr=kf*nf;

                for ii = 1:obj.NMics
                    snf = obj.Snf{ii};
                    vf = obj.Vf{ii};
                    nf = obj.Nf(ii);
                    nr = obj.Nr(ii);
                    glo = obj.Glo(ii);
                    seg = obj.Seg(ii);
                    stoi = obj.STOI(ii);
                    pesq = obj.PESQ(ii);
                    
                    snv=snf;
                    snv(~vf)=NaN;
                    snu=snf;
                    snu(vf>0)=NaN;
                    plotUI.Axes(ii) = subplot(obj.NMics,1,ii, 'Parent',obj.PlotParent, 'TitleFontSizeMultiplier', 0.5, 'Tag','SNR_plot');
                    plot([1 nr]/fs,[glo seg; glo seg],':k',((1:nf)*kf+(1-kf)/2)/fs,snv,'-b',((1:nf)*kf+(1-kf)/2)/fs,snu,'-r', 'Tag','SNR_plot');
                    title(sprintf('SNR = %.1f dB, SNR_{seg} = %.1f dB, STOI = %.2f, PESQ = %.2f ',glo,seg,stoi,pesq), 'Tag','SNR_plot');
                    ylabel('Frame SNR');
                    xlabel('Time (s)');
                    legend(plotUI.Axes(ii),obj.MicNames{ii});
%                     

                    fprintf('Intelligibility %s:\n    SNR    = %.1f dB\n    SNRseg = %.1f dB\n    STOI   = %.2f\n    PESQ   = %.2f \n',obj.MicNames{ii},glo,seg,stoi,pesq)
%                     plotUI.txSNR = uicontrol(obj.Parent,'Style','text',...
%                         'String','SNR',...
%                         'Units','normalized','Position',grid2pos([y-1,ii,1,1,x,y]));
%                     plotUI.edSNR = uicontrol(obj.Parent,'Style','edit',...
%                         'String',mat2str(obj.Glo(ii)),...
%                         'Callback',@obj.selectionChanged_Callback,...
%                         'Units','normalized','Position',grid2pos([y,ii,1,1,x,y]));
%                     plotUI.txSNRseg = uicontrol(obj.Parent,'Style','text',...
%                         'String','SNR_{seg}',...
%                         'Units','normalized','Position',grid2pos([y-1,ii+1,1,1,x,y]));
%                     plotUI.edSNRseg = uicontrol(obj.Parent,'Style','edit',...
%                         'String',mat2str(obj.Seg(ii)),...
%                         'Callback',@obj.selectionChanged_Callback,...
%                         'Units','normalized','Position',grid2pos([y,ii+1,1,1,x,y]));
%                     plotUI.txSTOI = uicontrol(obj.Parent,'Style','text',...
%                         'String','STOI',...
%                         'Units','normalized','Position',grid2pos([y-1,ii+2,1,1,x,y]));
%                     plotUI.edSTOI = uicontrol(obj.Parent,'Style','edit',...
%                         'String',mat2str(obj.STOI(ii)),...
%                         'Callback',@obj.selectionChanged_Callback,...
%                         'Units','normalized','Position',grid2pos([y,ii+2,1,1,x,y]));
%                     plotUI.txPESQ = uicontrol(obj.Parent,'Style','text',...
%                         'String','PESQ',...
%                         'Units','normalized','Position',grid2pos([y-1,ii+3,1,1,x,y]));
%                     plotUI.edPESQ = uicontrol(obj.Parent,'Style','edit',...
%                         'String',mat2str(obj.PESQ(ii)),...
%                         'Callback',@obj.selectionChanged_Callback,...
%                         'Units','normalized','Position',grid2pos([y,ii+3,1,1,x,y]));
                end
                drawnow;
            end
        end
        
    end
end

% This file is based on:
function [seg,glo, snf, rf, ef, vf,nf,nr]=snrseg(s,r,fs,m,tf)
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
        figure;
        snv=snf;
        snv(~vf)=NaN;
        snu=snf;
        snu(vf>0)=NaN;
        plot([1 nr]/fs,[glo seg; glo seg],':k',((1:nf)*kf+(1-kf)/2)/fs,snv,'-b',((1:nf)*kf+(1-kf)/2)/fs,snu,'-r');
        title(sprintf('SNR = %.1f dB, SNR_{seg} = %.1f dB',glo,seg));
        ylabel('Frame SNR');
        xlabel('Time (s)');
    end
end