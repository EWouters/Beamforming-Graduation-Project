%% Plot Audio Window UI Class
%  Example:
%   f = figure
%   obj = audio_window_ui(f)

%   Copyright 2015 BabForming.

classdef audio_window_ui < handle
%% Panel Plot Audio Signals Class
    %  This class holds the gui elements for the audio signals panel
    %% Properties
    properties
        Parent              % Handle of parent
        MainObj            % Handle of Channel Map
        NChan = 0;
        PanPlot
        Name = 'Signal Window'; % Name of UI
        Fs = 48000;
        TotalSamples
        WindowSize          % Window Size in samples
        FirstSample
        GroupPlots = 1;     % Boolean for whether to group the plots to one axis
        Axes                % Handle of axes
        Lines               % Hanlde of plot
        UI
        Update
    end
    %% Methods
    methods
        %% Plot Audio Signals Constuctor
        function obj = audio_window_ui(parent, MainObj)
            %% Parse Input
            % figure Handle
            if ishandle(parent)
                obj.Parent = parent;
            else
                error('First argument needs to be a handle');
            end
            obj.MainObj = MainObj;
            %% Graphics Code
            m=10;
            n=6;
            obj.PanPlot = uipanel(obj.Parent, 'Position',grid2pos([1,1,1,m-1,1,m]));
            obj.UI{1} = uicontrol(obj.Parent,'Style','pushbutton',...
                'String','Update','Callback',@obj.pbUpdate_Callback,...
                'Units','normalized','Position',grid2pos([n,m,1,1,n,m]));
            obj.UI{2} = uicontrol(obj.Parent,'Style','checkbox',...
                'String','Group Signals','Value',obj.GroupPlots,'Callback',@obj.pbUpdate_Callback,...
                'Units','normalized','Position',grid2pos([1,m,1,1,n,m]));
            obj.UI{3} = uicontrol(obj.Parent,'Style','slider',...
                'Callback',@obj.pbUpdateData_Callback,'Min',1,'Max',2,'Value',1,...
                'Units','normalized','Position',grid2pos([2,m,n-3,1,n,m]));
            obj.UI{4} = uicontrol(obj.Parent,'Style','text',...
                'String','Window size [s]',...
                'Units','normalized','Position',grid2pos([n-1,m*2-1,1,1,n,m*2]));
            obj.UI{5} = uicontrol(obj.Parent,'Style','edit',...
                'String','5','Callback',@obj.pbUpdateData_Callback,...
                'Units','normalized','Position',grid2pos([n-1,m*2,1,1,n,m*2]));
            
            %% Plot Code
%             yData = obj.MainObj.Channels.getData();
%             xData = (1:length(yData))/obj.MainObj.Channels.Fs;
            obj.Axes{1} = axes('Parent',obj.PanPlot);
            obj.Lines(1) = line('XData', [], 'YData', [], 'Parent',obj.Axes{1});
            
%             assignin('base','obj',obj)
        end
        
        %% Button Update Callback
        function pbUpdate_Callback(obj,~,~)
            obj.Fs = obj.MainObj.Channels.Fs;
            % Slider
            windowSize = str2double(obj.UI{5}.String);
            if isnumeric(windowSize) && isfinite(windowSize)
                obj.WindowSize = windowSize*obj.Fs;
                obj.UI{5}.String = mat2str(windowSize);
            end
            obj.FirstSample = round(obj.UI{3}.Value);
            [yData, obj.TotalSamples] = obj.MainObj.Channels.getWindow(obj.MainObj.Channels.SelectedSource,...
                obj.FirstSample,obj.WindowSize);
            xData = ((1:length(yData))'+obj.FirstSample)/obj.Fs;
            if obj.TotalSamples
                obj.UI{3}.Max = max(obj.TotalSamples-obj.WindowSize-1,2);
                step1 = min(obj.WindowSize/2/obj.TotalSamples,0.05);
                obj.UI{3}.SliderStep = [step1 min(step1,0.1)];
            end
            if ~isempty(yData)
                % Plots
                newNChan = size(yData,2);
                if obj.GroupPlots ~= obj.UI{2}.Value || obj.NChan ~= newNChan
                    obj.GroupPlots = obj.UI{2}.Value;
                    obj.NChan = newNChan;
                    if ~isempty(obj.Axes); delete([obj.Axes{:}]); end
                    obj.MainObj.Channels.UpdateChans();
                    if obj.GroupPlots
                        obj.Axes{1} = subplot(1,1,1, 'Parent',obj.PanPlot);
                        colors1 = {'black','blue','green','red','cyan','magenta','yellow'};
                        for ii = 1:newNChan
                            obj.Lines(ii) = line('XData', xData, 'YData', yData(:,ii),...
                                'Parent',obj.Axes{1}, 'Color', colors1{mod(newNChan-ii+1,length(colors1))});
                        end
                        legend(obj.Axes{1},obj.MainObj.Channels.ChanNames);
                    else
                        obj.Axes = {};
                        for ii = 1:newNChan
                            obj.Axes{ii} = subplot(newNChan,1,ii, 'Parent',obj.PanPlot);
                            obj.Lines(ii) = line('XData', xData, 'YData', yData(:,ii),...
                                'Parent',obj.Axes{ii});
                            legend(obj.Axes{ii},obj.MainObj.Channels.ChanNames{ii});
                        end
                        linkaxes([obj.Axes{:}],'xy');
                    end
                else
                    for ii = 1:obj.NChan
                        set(obj.Lines(ii), 'XData', xData, 'YData', yData(:,ii));
                    end
                end
                ylim1 = max(abs(yData(:)));
                set(obj.Axes{1}, 'XLim', [xData(1)-2/obj.Fs xData(end)], 'YLim', [-ylim1 ylim1]);
            else
                warning('yData is empty (audio window)')
            end
        end
        
        %% Button Update Callback
        function pbUpdateData_Callback(obj,~,~)
            % Slider
            windowSize = str2double(obj.UI{5}.String);
            if isnumeric(windowSize) && isfinite(windowSize)
                obj.WindowSize = windowSize*obj.Fs;
                obj.UI{5}.String = mat2str(windowSize);
            end
            obj.FirstSample = round(obj.UI{3}.Value);
            [yData, obj.TotalSamples] = obj.MainObj.Channels.getWindow(obj.MainObj.Channels.SelectedSource,...
                obj.FirstSample,obj.WindowSize);
            if obj.TotalSamples
                obj.UI{3}.Max = max(obj.TotalSamples-obj.WindowSize-1,2);
                step1 = min(obj.WindowSize/2/obj.TotalSamples,1);
                obj.UI{3}.SliderStep = [step1 step1];
            end
            if obj.FirstSample+obj.WindowSize < obj.TotalSamples
                xData = ((1:length(yData))'+obj.FirstSample)/obj.Fs;
                for ii = 1:obj.NChan
                    set(obj.Lines(ii), 'XData', xData, 'YData', yData(:,ii));
                end
                if ~isempty(yData)
                    ylim1 = max(abs(yData(:)));
                    set(obj.Axes{1}, 'XLim', [xData(1)-2/obj.Fs xData(end)], 'YLim', [-ylim1 ylim1]);
                end
            else
                warning('Sample window is above number of samples')
            end
        end
    end
end
