classdef bf_dsb < handle
    % BF_DSB Standard processing object. This file is a template to
    % make a processing object like a beamformer or an intelligibility measure
    %
    %   BF_DSB() create processing object
    %   BF_DSB(MAINOBJ) create processing object with handle to main object
    %
    % BF_DSB Methods:
    %   update  - Function to get a data window and call process function if
    %   there is data available to process
    %   process - Function where processing is done
    %
    % BF_DSB Properties:
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
        Parent                              % Handle of parent
        MainObj                             % Handle of main object
        Name          = 'DSB Beamformer';   % Name of Processor
        MicNames      = {};                 % Channel names
        SourceNames   = {};                 % Channel names
        NMics         = 0;
        
        freq = 1500;                %frequency of interest
%         theta1 = pi; %pi/2;%hoek in radialen
%         theta2 = 2*pi/9;
        L = 2^(ceil(log2(sptf)));
        
        
        
        
        
        InverseWeighing = 1;
        IsInitialized = 0;
        CurrentSample = 1;                  % Current sample
        WindowSize    = 2048;               % Size of window to process, twice this length is taken and multiplied by the window
        Weights       = [];                 % Weights matrix
        UI                                  % Cell UIs for the options
        Update                              % Update callback handle
        Timer                               % Timer object handle
        TimerPeriod = 0.5;                  % Timer update period in seconds
        Tag           = 'bf_dsb';           % Tag to find object
        x_s
        x_m
    end
    methods
        function obj = bf_dsb(parent, mainObj)
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
                help bf_dsb
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
            obj.Weights = [];
            
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
            
            obj.x_m = obj.MainObj.DataBuffer.Locations(obj.MainObj.DataBuffer.names2inds(obj.MicNames),1:3);
            obj.x_s = obj.MainObj.DataBuffer.Locations(obj.MainObj.DataBuffer.names2inds(obj.SourceNames),1:3);
            
            obj.IsInitialized = 1;
            obj.CurrentSample = 1;
            obj.UI.txNMics.String = sprintf('Initialized with %i mics',obj.NMics);
            try
                obj.MainObj.DataBuffer.removeChan(obj.Name);
            catch %#ok<CTCH>
            end
            obj.MainObj.DataBuffer.setLocations(obj.MainObj.DataBuffer.Locations(obj.MainObj.DataBuffer.names2inds(obj.SourceNames),:),obj.Name,1);
        end
        
        %% Button Process Callback
        function pbProcessAtOnce_Callback(obj,~,~)
            if obj.IsInitialized
                currentWin = obj.MainObj.DataBuffer.getAudioData(obj.MicNames);
                ymvdr2 = MVDR2(currentWin, obj.MainObj.DataBuffer.Fs, obj.x_s', obj.x_m', obj.MainObj.DataBuffer.SpeedSound, obj.WindowSize);
                obj.MainObj.DataBuffer.addSamples(ymvdr2, obj.Name,1,1);
                fprintf('Processed %i samples using MVDR2 beamformer form %i microphones\n',size(ymvdr2,1),obj.NMics);
            end
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
            obj.MainObj.DataBuffer.SpeedSound = str2double(obj.UI.edSpeedSound.String);
            obj.InverseWeighing = obj.UI.cbInverseWeighing.Value;
        end
        
        %% DSB Beamformer Graphics Code
        
        function UI = graphicsCode(obj)
            % GRAPHICSCODE Graphics Code
            % DSB Beamformer UI panel
            x=3;y=6;
            UI.txNMics = uicontrol(obj.Parent,'Style','text',...
                'String','Not Initialized','FontWeight','Bold',...
                'Units','normalized','Position',grid2pos([1,1,1,1,1,y]));
            UI.cbInverseWeighing = uicontrol(obj.Parent,'Style','checkbox',...
                'String','Inverse distance weiging','Value',obj.InverseWeighing,...
                'Callback',@obj.selectionChanged_Callback,...
                'Units','normalized','Position',grid2pos([1,2,1,1,1,y]));
            UI.txWindowSize = uicontrol(obj.Parent,'Style','text',...
                'String','Window size in seconds:',...
                'Units','normalized','Position',grid2pos([1,3,2,1,x,y]));
            UI.edWindowSize = uicontrol(obj.Parent,'Style','edit',...
                'String',mat2str(obj.WindowSize/obj.MainObj.DataBuffer.Fs),...
                'Callback',@obj.selectionChanged_Callback,...
                'Units','normalized','Position',grid2pos([3,3,1,1,x,y]));
            UI.txSpeedSound = uicontrol(obj.Parent,'Style','text',...
                'String','Speed of sound','Units','Normalized',...
                'Position',grid2pos([1,4, 2,1, x,y]));
            UI.edSpeedSound = uicontrol(obj.Parent,'Style','edit',...
                'String',obj.MainObj.DataBuffer.SpeedSound,'Units','Normalized',...
                'Position',grid2pos([3,4, 1,1, x,y]),...
                'Callback',@obj.selectionChanged_Callback);
            UI.cbContinuousUpdate = uicontrol(obj.Parent,'Style','checkbox',...
                'String','Continuous Processing, Period:','Value',0,'Callback',@obj.cbContinuousUpdate_Callback,...
                'Units','normalized','Position',grid2pos([1,5,2,1,x,y]));
            UI.edPeriod = uicontrol(obj.Parent,'Style','edit',...
                'String',mat2str(obj.TimerPeriod),'Callback',@obj.cbContinuousUpdate_Callback,...
                'Units','normalized','Position',grid2pos([3,5,1,1,x,y]));
            UI.pbInitialize = uicontrol(obj.Parent,'Style','pushbutton',...
                'String','Initialize','Callback',@obj.Initialize,...
                'Units','normalized','Position',grid2pos([1,6,1,1,x,y]));
            UI.pbProcess = uicontrol(obj.Parent,'Style','pushbutton',...
                'String','Process','Callback',@obj.pbProcess_Callback,...
                'Units','normalized','Position',grid2pos([2,6,1,1,x,y]));
            UI.pbProcessAtOnce = uicontrol(obj.Parent,'Style','pushbutton',...
                'String','Process at once','Callback',@obj.pbProcessAtOnce_Callback,...
                'Units','normalized','Position',grid2pos([3,6,1,1,x,y]));
        end
        
        % Delete function
        function delete(obj)
            stop(obj.Timer);
            delete(obj.Timer);
        end
        
    end
end

function ymvdr2 = MVDR2(signal, fs, x_s, x_m, c, sptf)

nr_frames = floor((length(signal) - sptf) / (sptf/2));
rec_signal = zeros(size(signal(:,1)));
%%%schatten van correlatie matrix
for J = 1 : 10 + 1
    
    win = [sqrt(hanning(sptf)), sqrt(hanning(sptf))];
    frame_noise = noise((sptf/2)*(J-1)+1:(sptf/2)*(J-1)+sptf,:).*(win);
    fft_noise = fft(frame_noise,L);
    
    fft_noise([1,L/2+1],:) = real(fft_noise([1,L/2+1],:));
    part1 = fft_noise(1:L/2+1,:);
    % fft_signal = [part1;conj(flipud(part1(2:end-1,:)))];
    
    
    
    
    for I =1 :L/2+1
        noise_cor(1,1,I,J) =   abs(part1(I,1)).^2;
        noise_cor(2,2,I,J) =   abs(part1(I,2)).^2;
        noise_cor(1,2,I,J) =    part1(I,1)*conj(part1(I,2));
        noise_cor(2,1,I,J) =    part1(I,2)*conj(part1(I,1));
    end
     
end
 noise_cor= mean(noise_cor,4);
%%%



for J = 1 : nr_frames + 1
    
    win = [sqrt(hanning(sptf)), sqrt(hanning(sptf))];
    frame_signal = signal((sptf/2)*(J-1)+1:(sptf/2)*(J-1)+sptf,:).*(win);
    fft_signal = fft(frame_signal,L);
    
    fft_signal([1,L/2+1],:) = real(fft_signal([1,L/2+1],:));
    part1 = fft_signal(1:L/2+1,:);
    fft_signal = [part1;conj(flipud(part1(2:end-1,:)))];
     fft_signal_mat(:,J)= fft_signal(:,1);
    %noise_coh_func = corrcoef(fft_signal, fft_signal');
    
    
    for I = 0 : L/2
        %% BOUWEN VAN DE NOISE COHERENCE FUNCTION
        f_center = I * fs / L;
        %     TAU = f_center*d/c;
        %     noise_coh_func = [1 sin(TAU+0.0001)/(TAU+0.0001); sin(TAU+0.0001)/(TAU+0.0001) 1];
        
        %% Berekenen van de center frequencies en de filter weights
        % De delay die gebruikt gaat worden in de weegcoefficienten voor alle
        % center frequencies
        
        dn = distcalc(x_m,x_s);
        omega=(0:L).'.*pi.*fs./L;
        k = omega./c;

        a = 1./(4*pi.*dn);
        D = repmat(a,L+1,1).*exp(-1i.*k*dn);
        
        % Weight vector
        w = (noise_cor(:,:,I+1)\D) / ((D'/noise_cor(:,:,I+1))*D);
        w= conj(w);
        flabber(:,I+1) = w;
        
        estimate_signal(I+1) = w.'*fft_signal(I+1,:).';
        
            
        
    end
    fft_estimate_signal_mat(:,J)=  estimate_signal;
    estimate_signal=estimate_signal(1:L/2+1);
    estimate_signal([1,L/2+1],:) = real(    estimate_signal([1,L/2+1],:)); % geforceerd
    estimate_signal=[estimate_signal;flipud(conj(estimate_signal(2:end-1)))];
    td_estimate_signal = real(ifft(estimate_signal(1:L)));
    rec_signal((sptf/2)*(J-1)+1:(sptf/2)*(J-1)+sptf) = rec_signal((sptf/2)*(J-1)+1:(sptf/2)*(J-1)+sptf)+td_estimate_signal(1:sptf).*(sqrt(hanning(sptf)));
end