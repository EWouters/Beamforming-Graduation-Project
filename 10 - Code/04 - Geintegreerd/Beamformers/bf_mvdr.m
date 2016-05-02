classdef bf_mvdr < handle
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
        Parent
        MainObj                             % Handle of main object
        Name          = 'MVDR Beamformer';  % Name of Processor
        MicNames      = {};                 % Channel names
        SourceNames   = {};                 % Channel names
        NMics         = 0;
        IsInitialized = 0;
        CurrentSample = 1;                  % Current sample
        WindowSize    = 2048;               % Size of window to process, twice this length is taken and multiplied by the window
        Weights       = [];                 % Weights matrix
        Directivity   = 0;
        g             = 1;                  % Microphone directivity pattern
        L_b           = 2048                % length of block?   default: 2048
        L_be          = 2^nextpow2(floor(48000.*0.016)); % ength of fft, default: 2^nextpow2(floor(fs.*0.016))
%         EP_ss
        delta_s       = 0.90; % Parameter to control weighing of current and previous EP_ss
        epsil         = 10^-1 % Regularization factor, default: regfactmvdr =10^-1; om inversie makkelijker te maken (ill conditioned) en white noise gain filter. Normale kamer: 10e-1 en 10e-3. Simulatie: 10e-10 tot 10e-9
%         Win                                 % Window to use on audio signal
        Tag           = 'bf_mvdr';    % Tag to find object
        x_s
        x_m
        plotflag = true;
        Update                              % Update callback handle
        UI
        Timer                               % Timer object handle
        TimerPeriod = 0.5;                  % Timer update period in seconds
    end
    methods
        function obj = bf_mvdr(parent, mainObj)
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
            if nargin >= 2
                obj.MainObj = mainObj;
            else
                obj.MainObj.Parent = std_panel(figure, grid2pos([]),obj.Name);
                obj.MainObj.DataBuffer = bf_data(obj.MainObj);
                obj.MainObj.DataBuffer.load([]);
                obj.MainObj.UI.BFChannels = std_selector_ui(obj.MainObj.Parent.Panel,obj.MainObj);
                help bf_mvdr
            end
            
%             obj.Initialize();

            % Graphics Code
            obj.UI = obj.graphicsCode();
            
            % Timer
            obj.Timer = timer('TimerFcn',@obj.timer_Callback,'ExecutionMode', 'fixedRate');
            
            % Debug
%             assignin('base','obj',obj);
        end
        
        function obj = Initialize(obj,~,~)
            obj.MainObj.UI.BFChannels.Update();
            chanNames = obj.MainObj.UI.BFChannels.ChanNames;
            if isempty(chanNames)
                warning('No channels connected');
                obj.UI.txNMics.String = 'Not Initialized: No channels';
                obj.IsInitialized = 0;
                try
                    obj.MainObj.UI.Beamformers.TabGroup1.SelectedTab = obj.MainObj.UI.Beamformers.Tabs{1};
                catch %#ok<CTCH>
                end
                return;
            end
            
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
            
            
%             obj.Win = repmat(sqrt(hanning(2*obj.WindowSize)),1,size(obj.MainObj.UI.BFChannels.ChanNames,1));
%             obj.EP_ss = sparse(obj.NMics*(obj.L_b+1),obj.NMics*(obj.L_b+1));
%             
            obj.Weights = [];
            
            obj.x_m = obj.MainObj.DataBuffer.Locations(obj.MainObj.DataBuffer.names2inds(obj.MicNames),1:3);
            obj.x_s = obj.MainObj.DataBuffer.Locations(obj.MainObj.DataBuffer.names2inds(obj.SourceNames),1:3);
            
            obj.IsInitialized = 1;
            obj.CurrentSample = 1;
            obj.UI.txNMics.String = sprintf('Initialized with %i mics',obj.NMics);
            
            if obj.Directivity
                name1 = [obj.Name ' Directivity'];
                fprintf('Initialized MVDR beamformer with directivity for %i microphones\n',obj.NMics);
            else
                name1 = obj.Name;
                fprintf('Initialized MVDR beamformer for %i microphones\n',obj.NMics);
            end
            
            try
                obj.MainObj.DataBuffer.removeChan(name1);
            catch %#ok<CTCH>
            end
            obj.MainObj.DataBuffer.setLocations(obj.MainObj.DataBuffer.Locations(obj.MainObj.DataBuffer.names2inds(obj.SourceNames),:),name1,1);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            %% Load directivity here
            
            if obj.Directivity
                for ii = 1:obj.NMics
                    phone_pos = obj.MainObj.DataBuffer.Locations(obj.MainObj.DataBuffer.names2inds(obj.MicNames{ii}),:);
                    source_pos = obj.MainObj.DataBuffer.Locations(obj.MainObj.DataBuffer.names2inds(obj.SourceNames),1:3);
                    [g(:,ii), theta(ii), phi(ii), radius(ii)] = directivity(phone_pos, source_pos);
                end
                
                %% plot eindproduct
                if obj.plotflag
                    figure('Name','Smartphone Directivity Impulse Response');
                    n = obj.NMics;
                    ax = {};
                    tax = (1:size(g,1))/obj.MainObj.DataBuffer.Fs;
                    for ii = 1:n
                        ax{ii} = subplot(n,1,ii);
                        plot(tax,g(:,ii));
                        title(sprintf('theta: %0.2f phi: %0.2f, r: %0.3f',theta(ii), phi(ii), radius(ii)));
                    end
                    linkaxes([ax{:}],'xy');
                    maxg = max(max(g));
                    xlim([0 tax(end)]);
                    ylim([-maxg,maxg]);
                    drawnow;
                end
                if size(g,1) < obj.L_b
                    g = [g; zeros(obj.L_b-size(g,1)+1,size(g,2))];
                end
                obj.g = g;
                
            elseif 0
                for ii = 1:obj.NMics
                    obj.g(:,ii) = directivity([0 0 0 0 0 0],[0 0 0]);
                end
            else
                obj.g = 1;
            end
            
            
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            obj.IsInitialized = 1;
        end
        
        %% Button Process Callback
        function pbProcessAtOnce_Callback(obj,~,~)
            if obj.IsInitialized
                currentWin = obj.MainObj.DataBuffer.getAudioData(obj.MicNames);
                [ymvdr, W] = mvdrbfBAP(obj.MainObj.DataBuffer.Fs, obj.MainObj.DataBuffer.SpeedSound, obj.L_b, obj.L_be, obj.x_m, obj.x_s, currentWin, obj.epsil, obj.delta_s, 0, obj.g);
                ymvdr = ymvdr./max(abs(ymvdr));
                
                if obj.Directivity
                    name1 = [obj.Name ' Directivity'];
                    fprintf('Processed %i samples using MVDR beamformer with directivity from %i microphones\n',size(ymvdr,1),obj.NMics);
                else
                    name1 = obj.Name;
                    fprintf('Processed %i samples using MVDR beamformer form %i microphones\n',size(ymvdr,1),obj.NMics);
                end
                obj.MainObj.DataBuffer.addSamples(ymvdr, name1,1);
                obj.Weights = W;
                
                % white noise gain
                fprintf('    White noise gain = %f dB\n', 10*log10(W'*W));
            end
        end
        
        %% Check box Continuous Update Callback
        function cbContinuousUpdate_Callback(obj,~,~)
            period1 = str2double(obj.UI.edPeriod.String);
            if period1 > 0.025 && period1 < 3600
                obj.TimerPeriod = period1;
            else
                obj.UI.edPeriod.String = obj.TimerPeriod;
            end
            % Timer updates
            if obj.UI.cbContinuousUpdate.Value && strcmp(obj.Timer.Running,'off')
                obj.Timer.Period = obj.TimerPeriod;
                start(obj.Timer);
            elseif strcmp(obj.Timer.Running,'on')
                stop(obj.Timer);
            end
        end
        
        function value = timer_Callback(obj,~,~)
            obj.pbProcess_Callback();
        end
            
        %% UI Selection Callback
        function selectionChanged_Callback(obj,~,~)
            obj.Directivity = obj.UI.cbDirectivity.Value;
            obj.plotflag = obj.UI.cbPlotDirectivity.Value;
            % Window size
            windowSize = str2double(obj.UI.edWindowSize.String);
            if isnumeric(windowSize) && isfinite(windowSize)
                if windowSize > 1/obj.MainObj.DataBuffer.Fs;
                    obj.WindowSize = round(windowSize*obj.MainObj.DataBuffer.Fs);
                    obj.UI.edWindowSize.String = mat2str(windowSize);
                end
            end
            delta_s = str2double(obj.UI.edDeltaS.String); %#ok<*PROP>
            if isnumeric(delta_s) && ~isempty(delta_s)
                if delta_s <= 1 && delta_s >= 0;
                    obj.delta_s = delta_s;
                    obj.UI.edDeltaS.String = mat2str(delta_s);
                end
            end
            epsil = str2double(obj.UI.edEpsil.String);
            if isnumeric(epsil) && ~isempty(epsil)
                if epsil <= 1 && epsil >= 0;
                    obj.epsil = epsil;
                    obj.UI.edEpsil.String = mat2str(epsil);
                end
            end
            speedSound = str2double(obj.UI.edSpeedSound.String);
            if isnumeric(speedSound) && ~isempty(speedSound)
                if speedSound <= 100000 && speedSound >= 0;
                    obj.MainObj.DataBuffer.SpeedSound = speedSound;
                    obj.UI.edSpeedSound.String = mat2str(speedSound);
                end
            end
        end
        
        %% MVDR Beamformer Graphics Code
        
        function UI = graphicsCode(obj)
            % GRAPHICSCODE Graphics Code
            % DSB Beamformer UI panel
            x=3;y=8;
            UI.txNMics = uicontrol(obj.Parent,'Style','text',...
                'String','Not Initialized','FontWeight','Bold',...
                'Units','normalized','Position',grid2pos([1,1,1,1,1,y]));
            UI.txWindowSize = uicontrol(obj.Parent,'Style','text',...
                'String','Window size in seconds:',...
                'Units','normalized','Position',grid2pos([1,2,2,1,x,y]));
            UI.edWindowSize = uicontrol(obj.Parent,'Style','edit',...
                'String',mat2str(obj.WindowSize/obj.MainObj.DataBuffer.Fs),...
                'Callback',@obj.selectionChanged_Callback,...
                'Units','normalized','Position',grid2pos([3,2,1,1,x,y]));
            UI.txDeltaS = uicontrol(obj.Parent,'Style','text',...
                'String','Weighing factor of current and previous EP_ss:',...
                'Units','normalized','Position',grid2pos([1,3,2,1,x,y]));
            UI.edDeltaS = uicontrol(obj.Parent,'Style','edit',...
                'String',mat2str(obj.delta_s),...
                'Callback',@obj.selectionChanged_Callback,...
                'Units','normalized','Position',grid2pos([3,3,1,1,x,y]));
            UI.txEpsil = uicontrol(obj.Parent,'Style','text',...
                'String','Regularization factor',...
                'Units','normalized','Position',grid2pos([1,4,2,1,x,y]));
            UI.edEpsil = uicontrol(obj.Parent,'Style','edit',...
                'String',mat2str(obj.epsil),...
                'Callback',@obj.selectionChanged_Callback,...
                'Units','normalized','Position',grid2pos([3,4,1,1,x,y]));
            UI.txSpeedSound = uicontrol(obj.Parent,'Style','text',...
                'String','Speed of sound','Units','Normalized',...
                'Position',grid2pos([1,5, 2,1, x,y]));
            UI.edSpeedSound = uicontrol(obj.Parent,'Style','edit',...
                'String',obj.MainObj.DataBuffer.SpeedSound,'Units','Normalized',...
                'Position',grid2pos([3,5, 1,1, x,y]),...
                'Callback',@obj.selectionChanged_Callback);
            UI.cbDirectivity = uicontrol(obj.Parent,'Style','checkbox',...
                'String','Use Microphone directivity','Value',obj.Directivity,...
                'Callback',@obj.selectionChanged_Callback,...
                'Units','normalized','Position',grid2pos([1,6,1,1,2,y]));
            UI.cbPlotDirectivity = uicontrol(obj.Parent,'Style','checkbox',...
                'String','Plot Directivity IR','Value',obj.plotflag,...
                'Callback',@obj.selectionChanged_Callback,...
                'Units','normalized','Position',grid2pos([2,6,1,1,2,y]));
%             UI.cbContinuousUpdate = uicontrol(obj.Parent,'Style','checkbox',...
%                 'String','Continuous Processing, Period:','Value',0,'Callback',@obj.cbContinuousUpdate_Callback,...
%                 'Units','normalized','Position',grid2pos([1,7,2,1,x,y]));
%             UI.edPeriod = uicontrol(obj.Parent,'Style','edit',...
%                 'String',mat2str(obj.TimerPeriod),'Callback',@obj.cbContinuousUpdate_Callback,...
%                 'Units','normalized','Position',grid2pos([3,7,1,1,x,y]));
            UI.pbInitialize = uicontrol(obj.Parent,'Style','pushbutton',...
                'String','Initialize','Callback',@obj.Initialize,...
                'Units','normalized','Position',grid2pos([1,8,1,1,x,y]));
            UI.pbProcess = uicontrol(obj.Parent,'Style','pushbutton',...
                'String','Process','Callback',@obj.pbProcess_Callback,...
                'Units','normalized','Position',grid2pos([2,8,1,1,x,y]), 'Enable', 'off');
            UI.pbProcessAtOnce = uicontrol(obj.Parent,'Style','pushbutton',...
                'String','Process at once','Callback',@obj.pbProcessAtOnce_Callback,...
                'Units','normalized','Position',grid2pos([3,8,1,1,x,y]));
        end
        
        % Delete function
        function delete(obj)
            stop(obj.Timer);
            delete(obj.Timer);
        end
        
    end
end

function varargout = mvdrcoreBAP(L_b,Nmics,X,EP_ss,epsilon,D,varargin)
% Author: dr. Jorge Martinez (J.A.MartinezCastaneda@TuDelft.nl)
% This is used for realtime
% Inputs:
% L_b  - length of positive half of fft spectrum   default: 2048
% Nmics - number of microphones
% X - input signal
% EP_ss - Estimated Power default: sparse(zeros(Nmics*(L_b+1),Nmics*(L_b+1)))
% epsilon - Regularization factor, default: regfactmvdr =10^-1;
% D - delays, default: repmat(a,L_b+1,1).*exp(-1i.*k*dn); a = 1./(4*pi.*dn); dn = distcalc(x_m,x_s);
% varargin - Directivities

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

function [ymvdr, W] = mvdrbfBAP(fs,c,L_b,L_be,x_m,x_s,xinput,epsil,delta_s,rtflag, g)
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
    % delta_s -          default: delta_s = 0.90;
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
        wait_h = waitbar(0,'Calculating PSDs','Name','Please wait');
        for te = 1:sim_lb-1
            auxte = ((1:2*L_b) + (te-1)*L_b ).';
            X_s = fft(xinput(auxte,1:Nmics).*win);

            EP_ss= pwest(L_b,Nmics,X_s,EP_ss,delta_s,te == 1);
            waitbar(te/sim_lb,wait_h);
        end
        close(wait_h);
        [W, ~]= mvdrcoreBAP(L_b,Nmics,X_s,EP_ss,epsilon,D, g);
    end



    wait_h = waitbar(0,'Applying the beamformer','Name','Please wait');
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
            Xmvdr = mvdrcore(L_b,Nmics,X,EP_ss,epsilon,D, g);
        else
            X = X(1:L_b+1,:).';
            MX = mat2cell(X,Nmics,ones(L_b+1,1));
            Xblk = sparse(blkdiag(MX{:}));
            Xmvdr = W'*Xblk;
            Xmvdr = [Xmvdr.' ; zeros(L_b-1,1)];
        end

        ovl= ifft(Xmvdr,'symmetric');
        ymvdr(auxt) = ymvdr(auxt) + ovl.*win(:,1);


        waitbar(t/sim_lb,wait_h);
    end

    close(wait_h);

    return
end






















%         
%         function value = update(obj,~,~)
% %             disp('Update recieved')
%             c = obj.c;
%             L_b = obj.L_b; %#ok<*PROP>
%             L_be = obj.L_be;
%             x_m = obj.x_m;
%             x_s = obj.x_s;
%             epsil = obj.epsil;
%             delta_s = obj.delta_s;
%             win = obj.Win;
%             ymvdr = [];
%             W = [];
%             EP_ss = obj.EP_ss;
%             
%             chanNames = [obj.MicNames obj.SourceNames];
%             chanInds = obj.MainObj.DataBuffer.names2inds(chanNames);
%             
%             value = 0;
%             if obj.IsInitialized
%                 while obj.CurrentSample + obj.WindowSize*2 <= min(obj.MainObj.DataBuffer.CurrentSample(chanInds))
%                     value = value + 1;
%                     % Load data from buffer
%                     xinput = obj.MainObj.DataBuffer.getAudioData(chanNames,obj.CurrentSample,obj.CurrentSample+obj.WindowSize*2-1);
% 
%                     % Call process function
%                     tic
%                     [ymvdr, W, EP_ss] = MVDR(fs,c,L_b,L_be,x_m,x_s,xinput,epsil,delta_s,EP_ss,win);
%                     toc
%                     % TODO return data to buffer or save in property
%     %                 disp(dataOut);
%                     obj.CurrentSample = obj.CurrentSample + obj.WindowSize;
% 
%                     % Write back to buffer
%                     obj.MainObj.DataBuffer.addSamples(dataOut,obj.Name,1);
%                 end
%                 obj.MainObj.DataBuffer.addSamples(ymvdr, obj.Name,1)
%                 obj.Weights = [obj.Weights W];
%                 obj.EP_ss = EP_ss;
%             end
%         end
%         



%         
%         %% Button Process Callback
%         function pbProcess_Callback(obj,~,~)
%             if obj.IsInitialized
%                 if obj.CurrentSample ~= obj.MainObj.DataBuffer.CurrentSample(obj.MainObj.DataBuffer.names2inds(obj.Name))
%                     disp('wrong number of output samples')
%                 end
%                 obj.CurrentSample = obj.CurrentSample + obj.WindowSize;
%                 if obj.CurrentSample > obj.WindowSize
%                     currentWin = obj.MainObj.DataBuffer.getAudioData(obj.MicNames,obj.CurrentSample-obj.WindowSize,obj.CurrentSample-1);
%                 else
%                     obj.CurrentSample = obj.CurrentSample - obj.WindowSize;
%                     warning('bf_dsb: Not enough samples available');
%                     return;
%                 end
%                 if obj.CurrentSample > 2*obj.WindowSize
%                     prevWin = obj.MainObj.DataBuffer.getAudioData(obj.MicNames,obj.CurrentSample-2*obj.WindowSize,obj.CurrentSample-obj.WindowSize-1);
%                 else
%                     prevWin = zeros(obj.WindowSize,obj.NMics);
%                 end
%                 while obj.CurrentSample + obj.WindowSize*2 < min(obj.MainObj.DataBuffer.CurrentSample(obj.MainObj.DataBuffer.names2inds(obj.MainObj.UI.BFChannels.ChanNames)))
% 
%                     ydsb = dsb(currentWin, prevWin, obj.MainObj.DataBuffer.Fs, obj.x_s', obj.x_m', obj.MainObj.DataBuffer.SpeedSound, obj.InverseWeighing);
%                     obj.MainObj.DataBuffer.addSamples(ydsb(1:obj.WindowSize,:), obj.Name);
% 
%                     obj.CurrentSample = obj.CurrentSample + obj.WindowSize;
%                     prevWin = currentWin;
%                     currentWin = obj.MainObj.DataBuffer.getAudioData(obj.MicNames,obj.CurrentSample-obj.WindowSize,obj.CurrentSample-1);
%                 end
% 
%                 ymvdr = mvdrbfBAP(currentWin, prevWin, obj.MainObj.DataBuffer.Fs, obj.x_s', obj.x_m', obj.MainObj.DataBuffer.SpeedSound, obj.InverseWeighing);
%                 if obj.Directivity
%                     name1 = [obj.Name ' Directivity'];
%                 else
%                     name1 = obj.Name;
%                 end
%                 obj.MainObj.DataBuffer.addSamples(ymvdr, name1);
%             end
%         end
% 
% function [ymvdr, W, EP_ss] = MVDR(fs,c,L_b,L_be,x_m,x_s,xinput,epsil,delta_s,EP_ss,win)
% %     % Get constants
% %     fs = obj.Fs;
% %     c = obj.c;
% %     L_b = obj.L_b; %#ok<*PROP>
% %     L_be = obj.L_be;
% % %             EP_ss = obj.EP_ss;
% %     delta_s = obj.delta_s;
% %     epsil = obj.epsil;
% %     win = obj.Win;
% %     Nmics = obj.NMics;
% %     x_m = obj.mics_pos;
% %     x_s = obj.sources_pos;
% 
%     % Algorithm. Author: dr. Jorge Martinez (J.A.MartinezCastaneda@TuDelft.nl)
%     Nmics = size(x_m,1);
%     k =((0:L_b).'.*pi.*fs./L_b)./c;
%     dn = distcalc(x_m,x_s);
%     a = 1./(4*pi.*dn);
%     D = repmat(a,L_b+1,1).*exp(-1i.*k*dn);
%     sim_l = size(xinput,1);
%     epsilon = speye(Nmics*(L_b+1)).*epsil;
%     mLb = L_b/L_be;
%     ymvdr = zeros(sim_l,1);
%     sim_lb=ceil(sim_l/L_b)-1;
% 
%     for t = 1:sim_lb-1
%         auxt=((1:2*L_b)+(t-1)*L_b).';
%         X = fft(xinput(auxt,1:Nmics).*win);
%         for te = 1:mLb-1
%             if 2*L_b + (t-1)*L_b + (te+1)*L_be < sim_l;
%                 auxte = ((1:2*L_b) + (t-1)*L_b + (te-1)*L_be).';
%                 X_s = fft(xinput(auxte,1:Nmics).*win);
% 
%                 EP_ss = pwest(L_b,Nmics,X_s,EP_ss,delta_s,te+t == 2);
%             end
%         end
%         [W, Xmvdr] = mvdrcoreBAP(L_b,Nmics,X,EP_ss,epsilon,D);
%         ovl= ifft(Xmvdr,'symmetric');
%         ymvdr(auxt) = ymvdr(auxt) + ovl.*win(:,1);
%     end
% 
% end
