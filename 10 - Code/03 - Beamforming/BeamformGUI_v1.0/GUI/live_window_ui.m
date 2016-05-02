%% Plot Audio Window UI Class
%  Example:
%   f = figure
%   obj = audio_window_ui(f)

%   Copyright 2015 BabForming.

classdef live_window_ui < handle
%% Panel Plot Audio Signals Class
    %  This class holds the gui elements for the audio signals panel
    %% Properties
    properties
        Parent              % Handle of parent
        MainObj            % Handle of main object
        PanPlot
        Name = 'Signal Window'; % Name of UI
        FirstSample
        Fs = 48000;
        WindowSize = 0.5*48000;          % Window Size in samples
        FrequencyWindow1 = 0;
        FrequencyWindow2 = 3000;
        AmplitudeAxis
        SpectrogramAxis
        UI
        Timer
        Update
    end
    %% Methods
    methods
        %% Plot Audio Signals Constuctor
        function obj = live_window_ui(parent, mainObj)
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
                obj.MainObj.DataBuffer = bf_data;
                obj.MainObj.UI.PlotSettings = std_selector_ui(figure,obj.MainObj,'Plot Settings');
            end
            
            % Timer
            obj.Timer = timer('TimerFcn',@obj.updateData, 'Period', 0.05,'ExecutionMode', 'fixedRate');
            
            %% Graphics Code
            m=10;n=6;
            obj.PanPlot = uipanel(obj.Parent, 'Position',grid2pos([1,1,1,m-1,1,m]));
            obj.UI.PbUpdate = uicontrol(obj.Parent,'Style','pushbutton',...
                'String','Update','Callback',@obj.pbUpdate_Callback,...
                'Units','normalized','Position',grid2pos([n,m,1,1,n,m]));
            obj.UI.cbContinuousUpdate = uicontrol(obj.Parent,'Style','checkbox',...
                'String','Continuous Update','Value',0,'Callback',@obj.pbUpdate_Callback,...
                'Units','normalized','Position',grid2pos([1,m,1,1,n,m]));
            obj.UI.slWindow = uicontrol(obj.Parent,'Style','slider',...
                'Callback',@obj.pbUpdate_Callback,'Min',1,'Max',2,'Value',1,...
                'Units','normalized','Position',grid2pos([2,m,n-3,1,n,m]));
            obj.UI.txWindowSize = uicontrol(obj.Parent,'Style','text',...
                'String','Window size [s]',...
                'Units','normalized','Position',grid2pos([n-1,m*2-1,1,1,n,m*2]));
            obj.UI.edWindowSize = uicontrol(obj.Parent,'Style','edit',...
                'String',obj.WindowSize/obj.Fs,'Callback',@obj.pbUpdate_Callback,...
                'Units','normalized','Position',grid2pos([n-1,m*2,1,1,n,m*2]));
            
            %% Plot Code
            obj.AmplitudeAxis   = axes('Parent',obj.PanPlot,'Units','Normalized','Position',grid2pos([1.95,2,9,8,10,20]),'Layer','top'); 
            obj.SpectrogramAxis = axes('Parent',obj.PanPlot,'Units','Normalized','Position',grid2pos([1.95,12,9,8,10,20]),'Layer','top'); 
%             grid2pos([1,1.01,1,0.85,1,2, 0.1,0.01])
%             grid2pos([1,2,1,0.85,1,2, 0.1,0.01])
            
            mag = 2^15;
            plot(obj.AmplitudeAxis,0,0);
            ylim(obj.AmplitudeAxis,[-mag mag])
            xlim(obj.AmplitudeAxis,[0 obj.WindowSize/obj.Fs])
            xlabel(obj.AmplitudeAxis,'Time (s)')
            xlim(obj.SpectrogramAxis,[obj.FrequencyWindow1 obj.FrequencyWindow2])
            ylim(obj.SpectrogramAxis,[0 obj.WindowSize/obj.Fs])
            view(obj.SpectrogramAxis,-90,90) 
            set(obj.SpectrogramAxis,'ydir','reverse')       
            set(obj.SpectrogramAxis, 'YTick', []);

            %% Link handle of update callback
            obj.Update = @obj.pbUpdate_Callback;
            
%             assignin('base','obj',obj)
        end
        
        
        %% Button Update Callback
        function pbUpdate_Callback(obj,~,~)
            windowTime = str2double(obj.UI.edWindowSize.String);
            if ~isempty(windowTime) && isfinite(windowTime) && windowTime > 0;
                obj.WindowSize = round(windowTime*obj.Fs);
                obj.UI.txWindowSize = obj.WindowSize/obj.Fs;
            end
            obj.updateData();
            if obj.UI.cbContinuousUpdate.Value
                start(obj.Timer);
            else
                stop(obj.Timer);
            end
        end
        
        %% Button Update Callback
        function updateData(obj,~,~)
            bit = 2; % load every nth sample of the data
            % Get data from buffer
            if obj.MainObj.DataBuffer.IsInitialized
                chanNames = obj.MainObj.DataBuffer.ChanNames{1};
                yData = obj.MainObj.OutputFile.getaudiodata(chanNames,max(1,obj.MainObj.DataBuffer.TotalSamples-obj.WindowSize),obj.MainObj.DataBuffer.TotalSamples);
            else
                warning('No data found')
                obj.UI.cbContinuousUpdate.Value = 0;
                return
            end
%             xData = (max(1,totalSamples-obj.WindowSize):(2^bit):totalSamples)./obj.Fs;
%             disp(yData)
                mag = 1.05;

                plot(obj.AmplitudeAxis,(max(1,size(yData,1)-obj.WindowSize):(2^bit):size(yData,1))./obj.Fs,yData(max(1,size(yData,1)-obj.WindowSize):(2^bit):end))
                mag = max(abs(yData));
                ylim(obj.AmplitudeAxis,[-1.2 1.2]*mag)
                xlim(obj.AmplitudeAxis,[max(0,size(yData,1)-obj.WindowSize)/obj.Fs max(size(yData,1),obj.WindowSize)/obj.Fs])
                xlabel(obj.AmplitudeAxis,'Time (s)')
                
                axes(obj.SpectrogramAxis);
                spectrogram(yData(max(1,size(yData,1)-obj.WindowSize):(2^bit):end),2^9/(2^bit),2^7/(2^bit),2^12/(2^bit),obj.Fs/(2^bit))
                xlim(obj.SpectrogramAxis,[obj.FrequencyWindow1 obj.FrequencyWindow2])
                ylim(obj.SpectrogramAxis,[0 obj.WindowSize/obj.Fs])
                view(obj.SpectrogramAxis,-90,90) 
                set(obj.SpectrogramAxis,'ydir','reverse')
                set(gca, 'YTick', []);
                
                drawnow;
        end

    end
end
