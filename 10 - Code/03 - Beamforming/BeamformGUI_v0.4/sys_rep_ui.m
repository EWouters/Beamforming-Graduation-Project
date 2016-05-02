classdef sys_rep_ui < handle
    %% System Representation Interface Class 
    %  This class will hold the ui elements for the system representation
    %% Constants
    properties (Constant)
        Name = 'System Representation';
    end
    %% Properties
    properties
        MainObj
        Parent              % Handle of parent
        TablePos = [-1,-1,3,2,-0.1];
        TablePosStr = {'left','bottom','width','height','z [m]'};
        SelectedSource = 0;
        NChan = 0;
        UI
    end
    %% Methods
    methods
        %%  System Representation Constuctor
        function obj = sys_rep_ui(parent, MainObj)
            %% Parse Input
            % figure Handle
            if ishandle(parent)
                obj.Parent = parent;
            else
                error('First argument needs to be a handle');
            end
            obj.MainObj = MainObj;
            %% Graphics Code
            m=length(obj.TablePosStr)+4;n=7;
            obj.UI.Table{1} = uicontrol(obj.Parent,'Style','checkbox',...
                'String','Table','Units','Normalized','Value',1,...
                'Position',grid2pos([1,n, 2,1, m,n, 0.01]),'Callback',@obj.pbUpdate_Callback);
            for ii = 1:m-4
                obj.UI.Table{ii+1} = uicontrol(obj.Parent,'Style','edit',...
                    'String',obj.TablePos(ii),'Units','Normalized',...
                    'Position',grid2pos([ii+2,2*n, 1,1, m,2*n, 0,0,0.003,0]),'Callback',@obj.pbUpdateTable_Callback);
                obj.UI.Table{ii+m-3} = uicontrol(obj.Parent,'Style','text',...
                    'String',obj.TablePosStr{ii},'Units','Normalized',...
                    'Position',grid2pos([ii+2,2*n-1, 1,1, m,2*n]),'Callback',@obj.pbUpdateTable_Callback);
            end
            obj.UI.Table{12} = uicontrol(obj.Parent,'Style','pushbutton',...
                'String','Update','Units','Normalized',...
                'Position',grid2pos([m-1,n, 2,1, m,n, 0.02,0,0,0.02]),'Callback',@obj.pbUpdate_Callback);
            obj.UI.Panel = uipanel('Parent',obj.Parent, 'Position', grid2pos([1,1,m,n-1,m,n, 0,0,0,0.023]));
            obj.UI.Axes = axes('Parent',obj.UI.Panel);
%             obj.UI.Axes.Title.String = {'Mic position denote by blue Os, and source of interest denoted by red Xs', ...
%                 'and interfering source denoted by green triangles'};
            hold(obj.UI.Axes,'on')
            view(obj.UI.Axes,3)
            obj.UI.Axes.XLabel.String = 'X [m]';
            obj.UI.Axes.YLabel.String = 'Y [m]';
            obj.UI.Axes.ZLabel.String = 'Z [m]';
            obj.UI.Axes.XGrid = 'on';
            obj.UI.Axes.YGrid = 'on';
            obj.UI.Axes.ZGrid = 'on';
%             setProperties(obj.UI.Axes, 'equal')
%             axis equal  %   For equal axis
%             view (3)    %   3d view
%             plot3(1,1,0,'bo','Parent',obj.UI.Axes)
%             obj.pbUpdate_Callback();
            
%             assignin('base','obj',obj)
        end
        
        %% Update Channels Callback function
        function pbUpdate_Callback(obj,~,~)
            % Update system representation
            % Mics:
            xData1 = obj.MainObj.PanSettings.UI{2}.LocData(:,2);
            yData1 = obj.MainObj.PanSettings.UI{2}.LocData(:,3);
            zData1 = obj.MainObj.PanSettings.UI{2}.LocData(:,4);
            obj.UI.Plots{1} = scatter3(xData1,yData1,zData1,...
                'bo','Parent',obj.UI.Axes,'Tag','sys_rep_mics');
            % Sources:
            xData2 = obj.MainObj.PanSettings.UI{1}.Simulation.SourcePos(:,1);
            yData2 = obj.MainObj.PanSettings.UI{1}.Simulation.SourcePos(:,2);
            zData2 = obj.MainObj.PanSettings.UI{1}.Simulation.SourcePos(:,3);
            
            % Clear axis
%             axes(obj.UI.Axes);
%             cla;
            % Plot markers
            obj.UI.Plots{2} = scatter3(xData2(1),yData2(1),zData2(1),...
                'rx','Parent',obj.UI.Axes,'Tag','sys_rep_source');
            if length(xData2) > 1
                obj.UI.Plots{3} = scatter3(xData2(2:end),yData2(2:end),zData2(2:end),...
                    'g>','Parent',obj.UI.Axes,'Tag','sys_rep_noise');
            else
                toDel1 = findobj('Tag','sys_rep_noise');
                if ~isempty(toDel1)
                    delete(toDel1)
                end
            end
            %Plot a plane to illustrate a table
            toDel2 = findobj('Tag','sys_rep_table');
            if ~isempty(toDel2)
                delete(toDel2)
            end
            if obj.UI.Table{1}.Value
                grey = [0.4,0.4,0.4];
                [xData3, yData3, zData3] = pos2patch(obj.TablePos);
                obj.UI.Plots{4} = patch(xData3, yData3, zData3,...
                    grey, 'Parent',obj.UI.Axes,'Tag','sys_rep_table');
            end
            axes(obj.UI.Axes);
            axis equal
            if ~isempty(xData1) && length(xData2) > 1
                legend([obj.UI.Plots{1:3}],'Mics','Source','Noise','Location',grid2pos([5.02,1.43, 0.4,0.2, 5,5]))
            else
%                 legend([obj.UI.Plots{1}],'Mics','Location',grid2pos([5.02,1.43, 0.4,0.2, 5,5]))
                disp('TODOTODOTODOTODO legend without source location')
            end
        end
        
        %% Update Table Callback function
        function pbUpdateTable_Callback(obj,~,~)
            % Update Table position
            % Read values from edit texts
            for ii = 1:length(obj.TablePosStr)
                obj.TablePos(ii) = str2double(obj.UI.Table{ii+1}.String);
                obj.UI.Table{ii+1}.String = mat2str(obj.TablePos(ii)); % Write back verified data
            end
        end
    end
end

function [xData, yData, zData] =  pos2patch(pos1)
    % pos1: [l,b,w,h]
    xData = [pos1(1), pos1(1)+pos1(3), pos1(1)+pos1(3), pos1(1)];
    yData = [pos1(2), pos1(2), pos1(2)+pos1(4), pos1(2)+pos1(4)];
    zData = [pos1(5), pos1(5), pos1(5), pos1(5)];
end