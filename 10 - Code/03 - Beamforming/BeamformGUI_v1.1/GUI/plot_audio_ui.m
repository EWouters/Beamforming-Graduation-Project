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
            
            % Link handle of update callback
            obj.Update = @obj.pbUpdate_Callback;
            
            % Debug
%             assignin('base','obj',obj)
        end
        
        %% Button Update Callback
        function pbUpdate_Callback(obj,~,~)
            if obj.MainObj.DataBuffer.IsInitialized
                yData = obj.MainObj.DataBuffer.getAudioData(obj.MainObj.UI.PlotSettings.ChanNames);
                if ~isempty(yData)
                    xData = (1:length(yData))'/obj.MainObj.DataBuffer.Fs;
                else
                    xData = [];
                end
                newNChan = size(yData,2);
                if obj.GroupPlots ~= obj.UI.cbGroupPlots.Value || obj.NChan ~= newNChan || 1
                    obj.GroupPlots = obj.UI.cbGroupPlots.Value;
                    obj.NChan = newNChan;
                    if ~isempty(obj.UI.Axes); obj.UI.Axes = []; end
                    if obj.GroupPlots
                        obj.UI.Axes{1} = subplot(1,1,1, 'Parent',obj.UI.PanPlots);
                        colors1 = {'black','blue','green','red','cyan','magenta','yellow'};
                        for ii = 1:newNChan
                            obj.UI.Lines(ii) = line('XData', xData, 'YData', yData(:,ii),...
                                'Parent',obj.UI.Axes{1}, 'Color', colors1{max(newNChan-ii,1)});
                        end
                        legend(obj.UI.Axes{1},obj.MainObj.UI.PlotSettings.ChanNames);
                    else
                        obj.UI.Axes = [];
                        for ii = 1:newNChan
                            obj.UI.Axes{ii} = subplot(newNChan,1,ii, 'Parent',obj.UI.PanPlots);
                            obj.UI.Lines(ii) = line('XData', xData, 'YData', yData(:,ii),...
                                'Parent',obj.UI.Axes{ii});
                            legend(obj.UI.Axes{ii},obj.MainObj.UI.PlotSettings.ChanNames{ii});
                        end
                        if ~isempty(yData)
                            linkaxes([obj.UI.Axes{:}],'xy');
                        end
                    end
                else
                    for ii = 1:obj.NChan
                        set(obj.UI.Lines(ii), 'XData', xData, 'YData', yData(:,ii));
                    end
                end
                if ~isempty(yData)
                    xlim1 = xData(end);
                    ylim1 = max([abs(yData(:));1e-4]);
                    for ii = 1:length(obj.UI.Axes)
                        set(obj.UI.Axes{ii}, 'XLim', [0 xlim1]);
                        set(obj.UI.Axes{ii}, 'YLim', [-ylim1 ylim1]);
                        ylabel(obj.UI.Axes{ii},'Amplitude')
                    end
                    xlabel(obj.UI.Axes{end},'Time (s)')
                end
            else
                warning('Cannot update plot, data buffer is not initialized')
            end
        end
        %% Button Play Callback
        function pbPlay_Callback(obj,~,~)
            if obj.MainObj.DataBuffer.IsInitialized
                firstSample = ceil(max(1,obj.UI.Axes{1}.XLim(1)*obj.MainObj.DataBuffer.Fs));
                lastSample = floor(min(obj.MainObj.DataBuffer.TotalSamples,obj.UI.Axes{1}.XLim(2)*obj.MainObj.DataBuffer.Fs));
                obj.MainObj.DataBuffer.play(obj.MainObj.UI.PlotSettings.ChanNames, firstSample, lastSample);
            else
                warning('Cannot play data, data buffer is not initialized')
            end
        end
        
        %% Plot Audio Graphics Code
        
        function UI = graphicsCode(obj)
            % GRAPHICSCODE Graphics Code
            % Plot Audio UI panel
            x=3;y=10; % Grid size
            UI.PanPlots = uipanel(obj.Parent, 'Position',grid2pos([1,1,1,y-1,1,y]));
            UI.Axes{1} = axes('Parent',UI.PanPlots);
            UI.Lines(1) = line('XData', [], 'YData', [], 'Parent',UI.Axes{1});
            UI.cbGroupPlots = uicontrol(obj.Parent,'Style','checkbox',...
                'String','Group Plots','Value',obj.GroupPlots,'Callback',@obj.pbUpdate_Callback,...
                'Units','normalized','Position',grid2pos([1,y,1,1,x,y]));
            UI.pbPlay = uicontrol(obj.Parent,'Style','pushbutton',...
                'String','Play','Callback',@obj.pbPlay_Callback,...
                'Units','normalized','Position',grid2pos([2,y,1,1,x,y]));
            UI.pbUpdate = uicontrol(obj.Parent,'Style','pushbutton',...
                'String','Update','Callback',@obj.pbUpdate_Callback,...
                'Units','normalized','Position',grid2pos([3,y,1,1,x,y]));
        end
        
    end
end
