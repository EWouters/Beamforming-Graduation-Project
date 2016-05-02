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
            obj.MainObj.UI.BFChannels.Update();
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
            obj.MainObj.DataBuffer.setChanNames(obj.Name, 1);
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
        
        %% Button Process Callback
        function pbProcess_Callback(obj,~,~)
            if obj.IsInitialized
                if obj.CurrentSample ~= obj.MainObj.DataBuffer.CurrentSample(obj.MainObj.DataBuffer.names2inds(obj.Name))
                    disp('wrong number of output samples')
                end
                obj.CurrentSample = obj.CurrentSample + obj.WindowSize;
                if obj.CurrentSample > obj.WindowSize
                    currentWin = obj.MainObj.DataBuffer.getAudioData(obj.MicNames,obj.CurrentSample-obj.WindowSize,obj.CurrentSample-1);
                else
                    obj.CurrentSample = obj.CurrentSample - obj.WindowSize;
                    warning('bf_dsb: Not enough samples available');
                    return;
                end
                if obj.CurrentSample > 2*obj.WindowSize
                    prevWin = obj.MainObj.DataBuffer.getAudioData(obj.MicNames,obj.CurrentSample-2*obj.WindowSize,obj.CurrentSample-obj.WindowSize-1);
                else
                    prevWin = zeros(obj.WindowSize,size(obj.MicNames,2));
                end
                while obj.CurrentSample + obj.WindowSize*2 < min(obj.MainObj.DataBuffer.CurrentSample(obj.MainObj.DataBuffer.names2inds(obj.MainObj.UI.BFChannels.ChanNames)))

                    ydsb = dsb(currentWin, prevWin, obj.MainObj.DataBuffer.Fs, obj.x_s', obj.x_m', obj.MainObj.DataBuffer.SpeedSound, obj.InverseWeighing);
                    obj.MainObj.DataBuffer.addSamples(ydsb(1:obj.WindowSize,:), obj.Name);

                    obj.CurrentSample = obj.CurrentSample + obj.WindowSize;
                    prevWin = currentWin;
                    currentWin = obj.MainObj.DataBuffer.getAudioData(obj.MicNames,obj.CurrentSample-obj.WindowSize,obj.CurrentSample-1);
                end

                ydsb = dsb(currentWin, prevWin, obj.MainObj.DataBuffer.Fs, obj.x_s', obj.x_m', obj.MainObj.DataBuffer.SpeedSound, obj.InverseWeighing);
                obj.MainObj.DataBuffer.addSamples(ydsb, obj.Name);
            end
        end
        
        %% Button Process Callback
        function pbProcessAtOnce_Callback(obj,~,~)
            if obj.IsInitialized
                currentWin = obj.MainObj.DataBuffer.getAudioData(obj.MicNames);
                ydsb = dsb(currentWin, zeros(obj.WindowSize,size(obj.MicNames,2)), obj.MainObj.DataBuffer.Fs, obj.x_s', obj.x_m', obj.MainObj.DataBuffer.SpeedSound, obj.InverseWeighing);
                obj.MainObj.DataBuffer.addSamples(ydsb, obj.Name,1,1);
                fprintf('Processed %i samples using DSB beamformer form %i microphones\n',size(ydsb,1),obj.NMics);
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

