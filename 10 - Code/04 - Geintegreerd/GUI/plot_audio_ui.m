classdef plot_audio_ui < handle
%% Panel Plot Audio Signals Class
    % PLOT_AUDIO_UI Holds the gui elements for the audio signals panel
    %
    %   PLOT_AUDIO_UI() create ui in new figure
    %   PLOT_AUDIO_UI(PARENT) create ui in parent panel
    %   PLOT_AUDIO_UI(PARENT, MAINOBJ) create ui with handle to main object
    %
    % Example 1:
    %   obj = plot_audio_ui
    %
    % Example 2:
    %   Parent = figure
    %   obj = plot_audio_ui(Parent)
    %
    % PLOT_AUDIO_UI Methods:
    %   plot_audio_ui     - Constructor
    %   pbUpdate_Callback - Update channel names
    %   pbPlay_Callback   - Play selected audiodata
    %   graphicsCode      - Graphics Generation Code
    %
    % PLOT_AUDIO_UI Properties:
    %   Parent     - Handle of panel to place ui in
    %   MainObj    - Handle of main object
    %   Name       - Name of UI
    %   NChan      - Number of channels
    %   GroupPlots - Boolean for whether to group the plots to one axis
    %   UI         - Cell UIs for the options
    %   Update     - Update callback handle
    %   Tag        - Tag to find object
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
        Parent                 % Handle of parent
        MainObj                % Handle of main object
        Name = 'Plot Audio Signals'; % Name of UI
        NChan = 0;             % Number of channels
        GroupPlots = 1;        % Boolean for whether to group the plots to one axis
        PlotSpect = 1;
        FrequencyWindow1 = 0;
        FrequencyWindow2 = 3000;
        Axes
        SpectAxes
        Lines
        UI                     % Cell UIs for the options
        Update                 % Update callback handle
        Tag = 'plot_audio_ui'; % Tag to find object
    end
    %% Methods
    methods
        %% Plot Audio Signals Constuctor
        function obj = plot_audio_ui(parent, mainObj)
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
            end
            
            % Graphics Code
            obj.UI = obj.graphicsCode();
            
            % Plot code
            obj.Axes{1} = axes('Parent',obj.UI.PanPlots);
            obj.Lines(1) = line('Parent',obj.Axes{1});
            
            % Link handle of update callback
            obj.Update = @obj.pbUpdate_Callback;
            
            % Debug
%             assignin('base','obj',obj)
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
            
            if obj.MainObj.DataBuffer.IsInitialized && ~isempty(chanNames)
                newNChan = size(chanNames,2);
                obj.GroupPlots = obj.UI.cbGroupPlots.Value;
                obj.PlotSpect = obj.UI.cbPlotSpect.Value;
                obj.NChan = newNChan;
                if ~isempty(obj.Axes); 
                    delete([obj.Axes{:}]); 
                    obj.Axes = {};
                    obj.Lines = [];
                end
                if ~isempty(obj.SpectAxes); 
                    delete([obj.SpectAxes{:}]); 
                    obj.SpectAxes = {};
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
                        if obj.PlotSpect
                            obj.Axes{ii} = subplot(newNChan,2,ii*2-1, 'Parent',obj.UI.PanPlots);
                            ylabel(obj.Axes{ii},'Amplitude');
                            obj.Lines(ii) = line('Parent',obj.Axes{ii});
                            legend(obj.Axes{ii},obj.MainObj.UI.PlotSettings.ChanNames{ii});
                            
                            obj.SpectAxes{ii} = subplot(newNChan,2,ii*2, 'Parent',obj.UI.PanPlots);
                            
                            xlim(obj.SpectAxes{ii},[obj.FrequencyWindow1 obj.FrequencyWindow2])
%                             ylim(obj.SpectAxes{ii},[0 obj.WindowSize/obj.Fs]);
                            view(obj.SpectAxes{ii},-90,90);
                            set(obj.SpectAxes{ii},'ydir','reverse');    
%                             set(obj.Axes{ii}, 'YTick', []);
                        else
                            obj.Axes{ii} = subplot(newNChan,1,ii, 'Parent',obj.UI.PanPlots);
                            ylabel(obj.Axes{ii},'Amplitude');
                            obj.Lines(ii) = line('Parent',obj.Axes{ii});
                            legend(obj.Axes{ii},obj.MainObj.UI.PlotSettings.ChanNames{ii});
                        end
                    end
                    if ~isempty(obj.Axes)
                        linkaxes([obj.Axes{:}],'xy');
                    end
%                     if ~isempty(obj.SpectAxes)
%                         linkaxes([obj.SpectAxes{:}],'xy');
%                     end
                end
                if ~isempty(obj.Axes)
                    ylabel(obj.Axes{end},'Amplitude');
                    xlabel(obj.Axes{end},'Time (s)');
                end
                if ~isempty(obj.SpectAxes)
                    ylabel(obj.SpectAxes{end},'Frequency');
                    xlabel(obj.SpectAxes{end},'Time (s)');
                end
                % Update the data
                obj.pbUpdateData_Callback();
            else
                obj.MainObj.UI.Settings.TabGroup1.SelectedTab = obj.MainObj.UI.Settings.Tabs{5};
                for ii = 1:length(obj.Axes{:})
                    axes(obj.Axes{ii}); %#ok<LAXES>
                    cla;
                    axes(obj.SpectAxes{ii}); %#ok<LAXES>
                    cla;
                end
                obj.Lines = [];
                warning('Cannot update plot, data buffer is not initialized')
            end
        end
        
        %% Button Update Data Callback
        function pbUpdateData_Callback(obj,~,~)
            if obj.NChan ~= size(obj.MainObj.UI.PlotSettings.ChanNames,2)
                obj.pbUpdate_Callback(obj);
            end
            yData = obj.MainObj.DataBuffer.getAudioData(obj.MainObj.UI.PlotSettings.ChanNames);
            fs = obj.MainObj.DataBuffer.Fs;
            if ~isempty(yData)
                xData = (1:length(yData))'/fs;
                xlims = [xData(1)-2/fs xData(end)];
                for ii = 1:obj.NChan
                    set(obj.Lines(ii), 'XData', xData, 'YData', yData(:,ii));
                end
                ylim1 = max([abs(yData(:));1e-4]);
                set(obj.Axes{1}, 'XLim', xlims, 'YLim', [-ylim1 ylim1]);
                
                if ~obj.GroupPlots && obj.PlotSpect
                    bit = 2;
                    for ii = 1:obj.NChan
                        yData1 = get(obj.Lines(ii), 'YData');
                        axes(obj.SpectAxes{ii});
                        spectrogram(yData1(1:(2^bit):end),2^9/(2^bit),2^7/(2^bit),2^12/(2^bit),fs/(2^bit))
                        xlim(obj.SpectAxes{ii},[obj.FrequencyWindow1 obj.FrequencyWindow2]);
                        ylim(obj.SpectAxes{ii},xlims);
                        view(obj.SpectAxes{ii},-90,90);
                        set(obj.SpectAxes{ii},'ydir','reverse');
%                         set(gca, 'YTick', []);
                    end
                    
                end
            else
                warning('data is empty');
            end
            drawnow;
        end
        
        %% Button Play Callback
        function pbPlay_Callback(obj,~,~)
            if obj.MainObj.DataBuffer.IsInitialized
                firstSample = ceil(max(1,obj.Axes{1}.XLim(1)*obj.MainObj.DataBuffer.Fs));
                lastSample = floor(min(obj.MainObj.DataBuffer.TotalSamples,obj.Axes{1}.XLim(2)*obj.MainObj.DataBuffer.Fs));
                obj.MainObj.DataBuffer.play(obj.MainObj.UI.PlotSettings.ChanNames, firstSample, lastSample);
            else
                warning('Cannot play data, data buffer is not initialized');
            end
        end
        
        %% Plot Audio Graphics Code
        
        function UI = graphicsCode(obj)
            % GRAPHICSCODE Graphics Code
            % Plot Audio UI panel
            x=3;y=10; % Grid size
            UI.PanPlots = uipanel(obj.Parent, 'Position',grid2pos([1,1,1,y-1,1,y]));
            UI.cbGroupPlots = uicontrol(obj.Parent,'Style','checkbox',...
                'String','Group Plots','Value',obj.GroupPlots,'Callback',@obj.pbUpdate_Callback,...
                'Units','normalized','Position',grid2pos([1,y+0.01,1,0.48,x,y]));
            UI.cbPlotSpect = uicontrol(obj.Parent,'Style','checkbox',...
                'String','Plot Spectograms','Value',obj.PlotSpect,'Callback',@obj.pbUpdate_Callback,...
                'Units','normalized','Position',grid2pos([1,y+0.51,1,0.48,x,y]));
            UI.pbPlay = uicontrol(obj.Parent,'Style','pushbutton',...
                'String','Play','Callback',@obj.pbPlay_Callback,...
                'Units','normalized','Position',grid2pos([2,y,1,1,x,y]));
            UI.pbUpdate = uicontrol(obj.Parent,'Style','pushbutton',...
                'String','Update','Callback',@obj.pbUpdate_Callback,...
                'Units','normalized','Position',grid2pos([3,y,1,1,x,y]));
        end
        
    end
end
