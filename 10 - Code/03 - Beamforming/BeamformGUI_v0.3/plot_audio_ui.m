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
        Plot
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
            obj.Plot = std_panel(obj.Parent, grid2pos([1,1,1,m-1,1,m]));
            obj.Plot = obj.Plot.Panel;
            obj.UI{1} = uicontrol(obj.Parent,'Style','pushbutton',...
                'String','Update','Callback',@obj.pbUpdate_Callback,...
                'Units','normalized','Position',grid2pos([2,m,1,1,2,m]));
            obj.UI{2} = uicontrol(obj.Parent,'Style','checkbox',...
                'String','Group Signals','Value',obj.GroupPlots,'Callback',@obj.pbUpdate_Callback,...
                'Units','normalized','Position',grid2pos([1,m,1,1,2,m]));
            
%             %% Plot Code
%             yData = obj.Channels.getData();
%             xData = (1:length(yData))/obj.Channels.Fs;
%             obj.Axes = axes('Parent',obj.Plot);
%             obj.Lines = line('XData', xData, 'YData', yData, 'Parent',obj.Axes);
            
            assignin('base','obj',obj)
        end
        
        %% Button Update Callback
        function pbUpdate_Callback(obj,~,~)
            yData = obj.Channels.getData();
            xData = (1:length(yData))'/obj.Channels.Fs;
            if isempty(yData)
                warndlg('Data is empty')
                return
            end
            newNChan = size(yData,2);
            if obj.GroupPlots ~= obj.UI{2}.Value || obj.NChan ~= newNChan
                obj.NChan = newNChan;
                delete(obj.Axes(:));
                delete(obj.Lines(:));
                if obj.GroupPlots
                    obj.Axes = axes('Parent',obj.Plot);
                    hold on
                    for ii = 1:newNChan
                        obj.Lines(ii) = line('XData', xData, 'YData', yData(:,ii), 'Parent',obj.Axes);
                    end
                    legend(obj.Axes,obj.Channels.ChanNames);
                else
                    for ii = 1:newNChan
                        obj.Axes(ii) = axes('Parent',obj.Plot,'Position',grid2pos([1,ii,1,1,1,newNChan]));
                        obj.Lines(ii) = line('XData', xData, 'YData', yData(:,ii), 'Parent',obj.Axes);
                        legend(obj.Axes(ii),obj.Channels.ChanNames{ii});
                    end
                    linkaxes(obj.Lines,'xy');
                end
            else
                for ii = 1:obj.NChan
                    set(obj.Lines(ii), 'XData', xData, 'YData', yData(:,ii));
                end
            end
            
            
%             
%             
%             if obj.NChan == size(yData,2)
%                 disp('salfkj')
%                 if obj.GroupPlots
%                     for ii = 1:obj.NChan
%                         set(obj.Lines(ii), 'XData', xData, 'YData', yData(:,ii));
%                     end
%                 else
%                     disp('TODO Ungroup')
%                 end
%             else
%                 delete(obj.Axes(:))
%                 delete(obj.Lines(:))
%                 if obj.GroupPlots
%                 else
%                     disp('TODO Number of channels changed')
%                 end
%             end
            
            
            %% play
%             a = audioplayer(yData,obj.Channels.Fs)
%             play(a)
%             assignin('base','audio',yData)
        end
    end
end
