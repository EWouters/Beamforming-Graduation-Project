classdef sys_rep_ui < handle
    % SYS_REP_UI Holds the gui elements for the system representation
    %
    %   SYS_REP_UI() create ui in new figure
    %   SYS_REP_UI(PARENT) create ui in parent panel
    %   SYS_REP_UI(PARENT, MAINOBJ) create ui with handle to main object
    %
    % Example 1:
    %   obj = sys_rep_ui
    %
    % Example 2:
    %   Parent = figure
    %   obj = sys_rep_ui(Parent)
    %
    % SYS_REP_UI Methods:
    %   sys_rep_ui             - Constructor
    %   pbUpdate_Callback      - Update channel names
    %   pbUpdateTable_Callback - Update Table
    %   graphicsCode           - Graphics Generation Code
    %
    % SYS_REP_UI Properties:
    %   Parent      - Handle of panel to place ui in
    %   MainObj     - Handle of main object
    %   Name        - Name of UI
    %   NChan       - Number of channels
    %   TablePos    - Table Position [left bottom width height z]
    %   TablePosStr - String with table properties
    %   UI          - Cell UIs for the options
    %   Update      - Update callback handle
    %   Tag         - Tag to find object
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
        Parent                          % Handle of panel to place ui in
        MainObj                         % Handle of main object
        Name = 'System Representation'; % Name of UI
        NChan = 0;                      % Number of channels
        TablePos = [-1,-1,3,2,-0.01];   % Table Position [left bottom width height z]
        TablePosStr = {'left','bottom','width','height','z [m]'}; % String with table properties
        UI                              % Cell UIs for the options
        Update                          % Update callback handle
        Tag = 'sys_rep_ui';             % Tag to find object
    end
    %% Methods
    methods
        %  System Representation Constuctor
        function obj = sys_rep_ui(parent, mainObj)
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
        
        %% Update Channels Callback function
        function pbUpdate_Callback(obj,~,~)
            % Update system representation
            chanNames = obj.MainObj.DataBuffer.ChanNames;
            locations = obj.MainObj.DataBuffer.Locations;
            
            typeStr = {'Phone','Mic','Source','Noise','Other'};
            markerStr = {'bo','rx','g>','cp','ms'};
            phoneNames = [];
            micNames = [];
            sourceNames = [];
            noiseNames = [];
            otherNames = [];
            for ii = 1:length(chanNames)
                if strfind(chanNames{ii},':')
                    phoneNames = [phoneNames ii];
                elseif strfind(chanNames{ii},'Mic')
                    micNames = [micNames ii];
                elseif strfind(chanNames{ii},'Source')
                    sourceNames = [sourceNames ii];
                elseif strfind(chanNames{ii},'Noise')
                    noiseNames = [noiseNames ii];
                else
                    otherNames = [otherNames ii];
                end
            end
            typeNames = {phoneNames micNames sourceNames noiseNames otherNames};
            phoneNames = chanNames(phoneNames);
            micNames = chanNames(micNames);
            sourceNames = chanNames(sourceNames);
            noiseNames = chanNames(noiseNames);
            otherNames = chanNames(otherNames);
            typeInds = [~isempty(phoneNames) ~isempty(micNames) ~isempty(sourceNames) ~isempty(noiseNames) ~isempty(otherNames)];
            
            for ii = 1:length(typeStr)
                toDelete = findobj('Tag',['tag' typeStr{ii}]);
                if ~isempty(toDelete)
                    delete(toDelete);
                end
                if typeInds(ii)
                    obj.UI.Plots{ii} = scatter3(locations(typeNames{ii},1),locations(typeNames{ii},2),locations(typeNames{ii},3),...
                        markerStr{ii},'Parent',obj.UI.Axes,'Tag',['tag' typeStr{ii}]);
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
%             if ~isempty(xData1) && length(xData2) > 1
%                 legend([obj.UI.Plots{typeInds}],typeStr(typeInds))%,grid2pos([5.02,1.43, 0.4,0.2, 5,5]))
%             else
%                 legend([obj.UI.Plots{1}],'Mics','Location',grid2pos([5.02,1.43, 0.4,0.2, 5,5]))
%                 disp('TODOTODOTODOTODO legend without source location')
%             end
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
        
        %% System Representation Graphics Code
        
        function UI = graphicsCode(obj)
            % GRAPHICSCODE Graphics Code
            % System Representation UI panel
            m=length(obj.TablePosStr)+4;n=7;
            UI.Table{1} = uicontrol(obj.Parent,'Style','checkbox',...
                'String','Table','Units','Normalized','Value',1,...
                'Position',grid2pos([1,n, 2,1, m,n, 0.01]),'Callback',@obj.pbUpdate_Callback);
            for ii = 1:m-4
                UI.Table{ii+1} = uicontrol(obj.Parent,'Style','edit',...
                    'String',obj.TablePos(ii),'Units','Normalized',...
                    'Position',grid2pos([ii+2,2*n, 1,1, m,2*n, 0,0,0.003,0]),'Callback',@obj.pbUpdateTable_Callback);
                UI.Table{ii+m-3} = uicontrol(obj.Parent,'Style','text',...
                    'String',obj.TablePosStr{ii},'Units','Normalized',...
                    'Position',grid2pos([ii+2,2*n-1, 1,1, m,2*n]),'Callback',@obj.pbUpdateTable_Callback);
            end
            UI.Table{12} = uicontrol(obj.Parent,'Style','pushbutton',...
                'String','Update','Units','Normalized',...
                'Position',grid2pos([m-1,n, 2,1, m,n, 0.02,0,0,0.02]),'Callback',@obj.pbUpdate_Callback);
            UI.Panel = uipanel('Parent',obj.Parent, 'Position', grid2pos([1,1,m,n-1,m,n, 0,0,0,0.023]));
            UI.Axes = axes('Parent',UI.Panel);
%             UI.Axes.Title.String = {'Mic position denote by blue Os, and source of interest denoted by red Xs', ...
%                 'and interfering source denoted by green triangles'};
            hold(UI.Axes,'on')
            view(UI.Axes,3)
            UI.Axes.XLabel.String = 'X [m]';
            UI.Axes.YLabel.String = 'Y [m]';
            UI.Axes.ZLabel.String = 'Z [m]';
            UI.Axes.XGrid = 'on';
            UI.Axes.YGrid = 'on';
            UI.Axes.ZGrid = 'on';
%             setProperties(UI.Axes, 'equal')
%             axis equal  %   For equal axis
%             view (3)    %   3d view
%             plot3(1,1,0,'bo','Parent',UI.Axes)
%             obj.pbUpdate_Callback();
        end
        
    end
end

function [xData, yData, zData] =  pos2patch(pos1)
    % pos1: [l,b,w,h]
    xData = [pos1(1), pos1(1)+pos1(3), pos1(1)+pos1(3), pos1(1)];
    yData = [pos1(2), pos1(2), pos1(2)+pos1(4), pos1(2)+pos1(4)];
    zData = [pos1(5), pos1(5), pos1(5), pos1(5)];
end