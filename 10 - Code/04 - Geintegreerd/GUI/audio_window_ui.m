classdef audio_window_ui < handle
    % AUDIO_WINDOW_UI Holds the gui elements for the audio window panel
    %
    %   AUDIO_WINDOW_UI() create ui in new figure
    %   AUDIO_WINDOW_UI(PARENT) create ui in parent panel
    %   AUDIO_WINDOW_UI(PARENT, MAINOBJ) create ui with handle to main object
    %
    % Example 1:
    %   obj = audio_window_ui
    %
    % Example 2:
    %   Parent = figure
    %   obj = audio_window_ui(Parent)
    %
    % AUDIO_WINDOW_UI Methods:
    %   audio_window_ui       - Constructor
    %   pbUpdate_Callback     - Update channels in buffer
    %   pbUpdateData_Callback - Update Data in plot
    %   pbPlay_Callback       - Play selected audiodata
    %   graphicsCode          - Graphics Generation Code
    %
    % AUDIO_WINDOW_UI Properties:
    %   Parent        - Handle of panel to place ui in
    %   MainObj       - Handle of main object
    %   Name          - Name of UI
    %   NChan         - Number of channels
    %   TotalSamples  - Total length of the audio data in buffer in samples
    %   WindowSize    - Window Size in samples
    %   CurrentSample - Current Sample is first sample of window
    %   GroupPlots    - Boolean for whether to group the plots to one axis
    %   Axes          - Handle of axis
    %   Lines         - Hanlde of plot
    %   UI            - Cell UIs for the options
    %   Update        - Update callback handle
    %   Tag           - Tag to find object
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
        Parent                  % Handle of parent
        MainObj                 % Handle of main object
        Name = 'Signal Window'; % Name of UI
        NChan = 0;              % Number of channels
        TotalSamples = 0;       % Total length of the audio data in buffer in samples
        WindowSize = 1;         % Window Size in samples
        CurrentSample = 1;      % Current Sample is first sample of window
        GroupPlots = 1;         % Boolean for whether to group the plots to one axis
        Axes                    % Handle of axes
        Lines                   % Hanlde of plot
        UI                      % Cell UIs for the options
        Update                  % Update callback handle
        Timer                   % Timer object handle
        TimerPeriod = 0.5;      % Timer update period in seconds
    end
    %% Methods
    methods
        %% Plot Audio Signals Constuctor
        function obj = audio_window_ui(parent, mainObj)
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
                obj.MainObj.DataBuffer = bf_data(obj.MainObj);
                obj.MainObj.UI.PlotSettings = std_selector_ui(figure,obj.MainObj);
                obj.MainObj.DataBuffer.setNChan(1);
                obj.MainObj.DataBuffer.setTotalSamples(48000);
                help audio_window_ui
            end
            
            % Graphics Code
            obj.UI = obj.graphicsCode();
            obj.edWindowSize_Callback();
            
            % Link handle of update callback
            obj.Update = @obj.pbUpdate_Callback;
            
            % Plot Code
            obj.Axes{1} = axes('Parent',obj.UI.PanPlots);
            obj.Lines(1) = line('Parent',obj.Axes{1});
            
            % Timer
            obj.Timer = timer('TimerFcn',@obj.timer_Callback,'ExecutionMode', 'fixedRate');
            
            % Debug
%             assignin('base','obj',obj);
        end
        
        %% Button Update Callback
        function pbUpdate_Callback(obj,~,~)
            % get channel names
            obj.MainObj.UI.PlotSettings.Update();
            chanNames = obj.MainObj.UI.PlotSettings.ChanNames;
            if isempty(chanNames)
                try
                    obj.MainObj.UI.Settings.TabGroup1.SelectedTab = obj.MainObj.UI.Settings.Tabs{5};
                catch %#ok<CTCH>
                end
                return;
            end
            if obj.MainObj.DataBuffer.IsInitialized
                % stop timer if running
                if strcmp(obj.Timer.Running,'on')
                    stop(obj.Timer);
                end
                % Plots
                newNChan = size(chanNames,2);
                obj.GroupPlots = obj.UI.cbGroupPlots.Value;
                obj.NChan = newNChan;
                if ~isempty(obj.Axes); 
                    delete([obj.Axes{:}]); 
                    obj.Axes = {};
                    obj.Lines = [];
                end
                colors1 = {'black','blue','green','red','cyan','magenta','yellow'};
                nColors = length(colors1);
                if obj.GroupPlots
                    obj.Axes{1} = subplot(1,1,1, 'Parent',obj.UI.PanPlots);
                    for ii = 1:newNChan
                        obj.Lines(ii) = line('Parent',obj.Axes{1}, 'Color', colors1{mod(newNChan-ii,nColors)+1});
                    end
                    legend(obj.Axes{1},obj.MainObj.UI.PlotSettings.ChanNames);
                else
                    for ii = 1:newNChan
                        obj.Axes{ii} = subplot(newNChan,1,ii, 'Parent',obj.UI.PanPlots);
                        obj.Lines(ii) = line('Parent',obj.Axes{ii}, 'Color', colors1{mod(newNChan-ii,nColors)+1});
                        legend(obj.Axes{ii},obj.MainObj.UI.PlotSettings.ChanNames{ii});
                    end
                    linkaxes([obj.Axes{:}],'xy');
                end
                if ~isempty(obj.Axes)
                    ylabel(obj.Axes{end},'Amplitude');
                    xlabel(obj.Axes{end},'Time (s)');
                end
                % Update the data
                obj.slCurrentSample_Callback();
                % Restart timer if continuous update was enabled
                if obj.UI.cbContinuousUpdate.Value && strcmp(obj.Timer.Running,'off')
                    obj.Timer.Period = obj.TimerPeriod;
                    start(obj.Timer);
                end
            else
                obj.CurrentSample = 1;
                obj.TotalSamples = 0;
                obj.UI.slCurrentSample.Value = obj.UI.slCurrentSample.Min;
                for ii = 1:length(obj.Axes{:})
                    axes(obj.Axes{ii}); %#ok<LAXES>
                    cla;
                end
                obj.Lines = [];
                warning('audio_window_ui:Buffer not initialized')
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
        
        %% Button Update Data Callback
        function pbUpdateData_Callback(obj,~,~)
            if obj.NChan ~= size(obj.MainObj.UI.PlotSettings.ChanNames,2)
                obj.pbUpdate_Callback(obj);
            end
            obj.TotalSamples = min(obj.MainObj.DataBuffer.CurrentSample(obj.MainObj.DataBuffer.names2inds(obj.MainObj.UI.PlotSettings.ChanNames)));
            if obj.CurrentSample+obj.WindowSize < obj.TotalSamples
                yData = obj.MainObj.DataBuffer.getAudioData( ...
                    obj.MainObj.UI.PlotSettings.ChanNames, ...
                    obj.CurrentSample,obj.CurrentSample+obj.WindowSize);
                xData = ((1:length(yData))'+obj.CurrentSample)/obj.MainObj.DataBuffer.Fs;
                lines1 = obj.Lines;
                for ii = 1:obj.NChan
                    set(lines1(ii), 'XData', xData, 'YData', yData(:,ii));
                end
                if ~isempty(yData)
                    ylim1 = max([abs(yData(:));1e-4]);
                    set(obj.Axes{1}, 'XLim', [xData(1)-2/obj.MainObj.DataBuffer.Fs xData(end)], 'YLim', [-ylim1 ylim1]);
%                     set(obj.Axes{1}, 'XLim', [xData(1)-2/obj.MainObj.DataBuffer.Fs xData(end)]);
                end
            else
                obj.CurrentSample = 1;
                warning('Sample window index is above current sample index of channels buffer')
            end
            drawnow;
        end
        
        function value = timer_Callback(obj,~,~)
%             disp('Update recieved')
            value = 0;
            while obj.CurrentSample + obj.TimerPeriod*obj.MainObj.DataBuffer.Fs+obj.WindowSize < min(obj.MainObj.DataBuffer.CurrentSample(obj.MainObj.DataBuffer.names2inds(obj.MainObj.UI.PlotSettings.ChanNames))) && ...
                    obj.UI.cbContinuousUpdate.Value
                value = value + 1;
                % Load data from buffer
                obj.CurrentSample = obj.CurrentSample + obj.TimerPeriod*obj.MainObj.DataBuffer.Fs;
                obj.slCurrentSample_Callback([],[],obj.CurrentSample);
            end
        end
        
        %% Button Play Callback
        function pbPlay_Callback(obj,~,~)
            if obj.MainObj.DataBuffer.IsInitialized
                firstSample = ceil(max(1,obj.Axes{1}.XLim(1)*obj.MainObj.DataBuffer.Fs));
                lastSample = floor(min(obj.MainObj.DataBuffer.TotalSamples,obj.Axes{1}.XLim(2)*obj.MainObj.DataBuffer.Fs));
                obj.MainObj.DataBuffer.play(obj.MainObj.UI.PlotSettings.ChanNames, firstSample, lastSample);
            else
                warning('Cannot play data, data buffer is not initialized')
            end
        end
        
        %% Slider Callback
        function slCurrentSample_Callback(obj,~,~,sample)
            % Slider
            if obj.MainObj.DataBuffer.IsInitialized
                obj.TotalSamples = min(obj.MainObj.DataBuffer.CurrentSample(obj.MainObj.DataBuffer.names2inds(obj.MainObj.UI.PlotSettings.ChanNames)));
                if nargin < 4
                    obj.CurrentSample = round(obj.UI.slCurrentSample.Value);
                else
                    obj.CurrentSample = sample;
                end
                if obj.TotalSamples > obj.WindowSize-1
                    obj.UI.slCurrentSample.Max = max(obj.TotalSamples-obj.WindowSize-1,2);
                    obj.UI.slCurrentSample.Value = obj.CurrentSample;
                    step1 = min(obj.WindowSize/2/obj.TotalSamples,1);
                    obj.UI.slCurrentSample.SliderStep = [step1 step1];
                    obj.pbUpdateData_Callback();
                end
            else
                obj.TotalSamples = 0;
                obj.CurrentSample = 1;
                obj.UI.slCurrentSample.Value = obj.CurrentSample;
                step1 = min(obj.WindowSize/2/obj.TotalSamples,1);
                obj.UI.slCurrentSample.SliderStep = [step1 step1];
            end
        end
        
        %% Window size Callback
        function edWindowSize_Callback(obj,~,~)
            % Window size
            windowSize = str2double(obj.UI.edWindowSize.String);
            if isnumeric(windowSize) && isfinite(windowSize)
                if windowSize > 1/obj.MainObj.DataBuffer.Fs;
                    obj.WindowSize = round(windowSize*obj.MainObj.DataBuffer.Fs);
                    obj.UI.edWindowSize.String = mat2str(windowSize);
                end
            end
            obj.slCurrentSample_Callback();
        end
        
        %% Audio Window Graphics Code
        
        function UI = graphicsCode(obj)
            % GRAPHICSCODE Graphics Code
            % Audio Window UI panel
            x=4;y=20;
            UI.PanPlots = uipanel(obj.Parent, 'Position',grid2pos([1,1,1,y-2.5,1,y]));
            UI.cbGroupPlots = uicontrol(obj.Parent,'Style','checkbox',...
                'String','Group Plots','Value',obj.GroupPlots,'Callback',@obj.pbUpdate_Callback,...
                'Units','normalized','Position',grid2pos([1,y-2.8,1,1,x,y]));
            UI.slCurrentSample = uicontrol(obj.Parent,'Style','slider',...
                'Callback',@obj.slCurrentSample_Callback,'Min',1,'Max',2,'Value',1,...
                'Units','normalized','Position',grid2pos([1,y-1.8,1,0.8,1,y]));
            UI.txWindowSize = uicontrol(obj.Parent,'Style','text',...
                'String','Window size',...
                'Units','normalized','Position',grid2pos([1,y-1,2,1,x,y]));
            UI.edWindowSize = uicontrol(obj.Parent,'Style','edit',...
                'String','1','Callback',@obj.edWindowSize_Callback,...
                'Units','normalized','Position',grid2pos([3,y-1,1,1,x,y]));
            UI.cbContinuousUpdate = uicontrol(obj.Parent,'Style','checkbox',...
                'String','Continuous Update, Period:','Value',0,'Callback',@obj.cbContinuousUpdate_Callback,...
                'Units','normalized','Position',grid2pos([1,y,2,1,x,y]));
            UI.edPeriod = uicontrol(obj.Parent,'Style','edit',...
                'String',mat2str(obj.TimerPeriod),'Callback',@obj.cbContinuousUpdate_Callback,...
                'Units','normalized','Position',grid2pos([3,y,1,1,x,y]));
            UI.pbPlay = uicontrol(obj.Parent,'Style','pushbutton',...
                'String','Play','Callback',@obj.pbPlay_Callback,...
                'Units','normalized','Position',grid2pos([4,y-1,1,1,x,y]));
            UI.pbUpdate = uicontrol(obj.Parent,'Style','pushbutton',...
                'String','Update Channels','Callback',@obj.pbUpdate_Callback,...
                'Units','normalized','Position',grid2pos([4,y,1,1,x,y]));
        end
        
        % Delete function
        function delete(obj)
            stop(obj.Timer);
            delete(obj.Timer);
        end
        
    end
end
