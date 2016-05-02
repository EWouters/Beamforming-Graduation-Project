%% Plot Audio Signals UI Class
%  Example:
%   f = figure
%   obj = plot_audio_ui(f)

%   Copyright 2015 BabForming.

classdef plot_audio_ui < handle
%% Panel Plot Audio Signals Class
    %  This class holds the gui elements for the audio signals panel
    %% Properties
    properties
        Parent              % Handle of parent
        Channels            % Handle of Channel Map
        NChan = 0;
        PanPlot
        Name = 'Plot Audio Signals'; % Name of UI
        GroupPlots = 1;     % Boolean for whether to group the plots to one axis
        Axes                % Handle of axis
        Lines               % Hanlde of plot
        UI
        Update
    end
    %% Methods
    methods
        %% Plot Audio Signals Constuctor
        function obj = plot_audio_ui(varargin)
            % figure Handle
            if nargin == 0
                obj.Parent = figure('Name',obj.Name,'NumberTitle','off','resize','on');
            else
                if ishandle(varargin{1})
                    obj.Parent = varargin{1};
                else
                    warning(['First argument needs to be a handle,'...
                        'new figure created.']);
                    obj.Parent = figure('Name',obj.Name,'NumberTitle','off','resize','on');
                end
            end
            obj.Channels = varargin{2};
            %% Graphics Code
            m=10;
            obj.PanPlot = uipanel(obj.Parent, 'Position',grid2pos([1,1,1,m-1,1,m]));
            obj.UI{1} = uicontrol(obj.Parent,'Style','pushbutton',...
                'String','Update','Callback',@obj.pbUpdate_Callback,...
                'Units','normalized','Position',grid2pos([2,m,1,1,2,m]));
            obj.UI{2} = uicontrol(obj.Parent,'Style','checkbox',...
                'String','Group Signals','Value',obj.GroupPlots,'Callback',@obj.pbUpdate_Callback,...
                'Units','normalized','Position',grid2pos([1,m,1,1,2,m]));
            % TODO Play  window button
            % TODO slider
            % TODO window length
            
            %% Plot Code
%             yData = obj.Channels.getData();
%             xData = (1:length(yData))/obj.Channels.Fs;
            obj.Axes{1} = axes('Parent',obj.PanPlot);
            obj.Lines(1) = line('XData', [], 'YData', [], 'Parent',obj.Axes{1});
            
            %% Link handle of update callback
            obj.Update = @obj.pbUpdate_Callback;
            
%             assignin('base','obj',obj)
        end
        
        %% Button Update Callback
        function pbUpdate_Callback(obj,~,~)
            yData = obj.Channels.getData();
            xData = (1:length(yData))'/obj.Channels.Fs;
            newNChan = size(yData,2);
            if obj.GroupPlots ~= obj.UI{2}.Value || obj.NChan ~= newNChan
                obj.GroupPlots = obj.UI{2}.Value;
                obj.NChan = newNChan;
                if ~isempty(obj.Axes); delete([obj.Axes{:}]); end
                obj.Channels.UpdateChans();
                if obj.GroupPlots
                    obj.Axes{1} = subplot(1,1,1, 'Parent',obj.PanPlot);
                    colors1 = {'black','blue','green','red','cyan','magenta','yellow'};
                    for ii = 1:newNChan
                        obj.Lines(ii) = line('XData', xData, 'YData', yData(:,ii),...
                            'Parent',obj.Axes{1}, 'Color', colors1{mod(newNChan-ii+1,length(colors1))});
                    end
                    legend(obj.Axes{1},obj.Channels.ChanNames);
                else
                    obj.Axes = {};
                    for ii = 1:newNChan
                        obj.Axes{ii} = subplot(newNChan,1,ii, 'Parent',obj.PanPlot);
                        obj.Lines(ii) = line('XData', xData, 'YData', yData(:,ii),...
                            'Parent',obj.Axes{ii});
                        legend(obj.Axes{ii},obj.Channels.ChanNames{ii});
                    end
                    if ~isempty(yData)
                        linkaxes([obj.Axes{:}],'xy');
                    end
                end
            else
                for ii = 1:obj.NChan
                    set(obj.Lines(ii), 'XData', xData, 'YData', yData(:,ii));
                end
            end
            if ~isempty(yData)
                set(obj.Axes{1}, 'XLim', [0 xData(end)]);
                ylim1 = max(abs(yData(:)));
                set(obj.Axes{1}, 'YLim', [-ylim1 ylim1]);
            end
        end
    end
end
