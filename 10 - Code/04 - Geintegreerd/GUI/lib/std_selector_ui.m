classdef std_selector_ui < handle
    % STD_SELECTOR_UI Holds the gui elements for the source settings selection panel
    %
    %   STD_SELECTOR_UI() create ui in new figure
    %   STD_SELECTOR_UI(PARENT) create ui in parent panel
    %   STD_SELECTOR_UI(PARENT, MAINOBJ) create ui with handle to main object
    %
    % Example 1:
    %   obj = std_selector_ui
    %
    % Example 2:
    %   Parent = figure
    %   obj = std_selector_ui(Parent)
    %
    % STD_SELECTOR_UI Methods:
    %   pbUpdate_Callback - PushButton Update channel names Callback
    %   pbAdd_Callback    - PushButton Add Callback
    %   pbRemove_Callback - PushButton Remove Callback
    %
    % STD_SELECTOR_UI Properties:
    %   Parent    - Handle of panel to place ui in
    %   MainObj   - Handle of main object
    %   Name      - Name of UI
    %   ChanNames - Channel names
    %   UI        - Cell UIs for the options
    %   Tag       - Tag to find object
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
        Name = 'Standard Selector';     % Name of UI
        ChanNames = {};                 % Channel names
        Inds = [];
        UI                              % Cell UIs for the options
        Update
        Tag = 'std_selector_ui';        % Tag to find object
    end
    % Methods
    methods
        %% UI Constuctor
        function obj = std_selector_ui(parent, mainObj, name)
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
            end
            if nargin >= 3
                obj.Name = name;
            end
            
            % Graphics Code
            obj.UI = obj.graphicsCode();
            obj.pbUpdate_Callback();
            
            % Link handle of update callback
            obj.Update = @obj.pbUpdate_Callback;
            
            % Debug
%             assignin('base','obj',obj)
        end
        %% PushButton Update Channel Names Callback
        function pbUpdate_Callback(obj,~,~)
            for ii = 1:size(obj.ChanNames,2)
                res = strcmp(obj.ChanNames{ii},obj.MainObj.DataBuffer.ChanNames);
                if sum(res) ~= 1
                    obj.ChanNames(ii) = [];
                else
                    obj.Inds(ii) = find(res~=0, 1, 'first');
                end
            end
            if obj.UI.ListAvailable.Value > length(obj.MainObj.DataBuffer.ChanNames) && ~isempty(obj.MainObj.DataBuffer.ChanNames)
                obj.UI.ListAvailable.Value = length(obj.MainObj.DataBuffer.ChanNames);
            end
            if obj.UI.ListConnected.Value > length(obj.ChanNames) && ~isempty(obj.ChanNames)
                obj.UI.ListConnected.Value = length(obj.ChanNames);
            end
            obj.UI.ListAvailable.String = obj.MainObj.DataBuffer.ChanNames;
            obj.UI.ListConnected.String = obj.ChanNames;
            if ~isempty(obj.UI.ListAvailable.String)
                obj.UI.PbAdd.Enable = 'on';
            else
                obj.UI.PbAdd.Enable = 'off';
            end
            if ~isempty(obj.UI.ListConnected.String)
                obj.UI.PbRemove.Enable = 'on';
                obj.UI.PbClear.Enable = 'on';
            else
                obj.UI.PbRemove.Enable = 'off';
                obj.UI.PbClear.Enable = 'off';
            end
        end
        %% PushButton Add Callback
        function pbAdd_Callback(obj,~,~)
            if ~isempty(obj.UI.ListAvailable.String) && ~isempty(obj.MainObj.DataBuffer.ChanNames)
                % Start Mitm Streaming
                if any(strcmp(obj.UI.ListAvailable.String{obj.UI.ListAvailable.Value},obj.UI.ListConnected.String))
                    return;
                end
                obj.ChanNames{end+1} = obj.UI.ListAvailable.String{obj.UI.ListAvailable.Value};
                fprintf('Added %s to %s\n',obj.UI.ListAvailable.String{obj.UI.ListAvailable.Value},obj.Name);
                % Increment selection
                if obj.UI.ListAvailable.Value < length(obj.UI.ListAvailable.String)
                    obj.UI.ListAvailable.Value = obj.UI.ListAvailable.Value + 1;
                else
                    obj.UI.ListAvailable.Value = 1;
                end
            else
                warning('Cannot add channel, no channels found.')
            end
            obj.pbUpdate_Callback();
        end
        %% PushButton Remove Callback
        function pbRemove_Callback(obj,~,~)
            if ~isempty(obj.UI.ListConnected.String) && ~isempty(obj.ChanNames)
                fprintf('Removed %s from %s\n',obj.UI.ListConnected.String{obj.UI.ListConnected.Value},obj.Name);
                obj.ChanNames(obj.UI.ListConnected.Value) = [];
                % Decrement selection
                if obj.UI.ListConnected.Value > 1
                    obj.UI.ListConnected.Value = obj.UI.ListConnected.Value - 1;
                end
            else
                warning('Cannot remove channel, no channels connected.')
            end
            obj.pbUpdate_Callback();
        end
        
        %% PushButton Add Channel Callback
        function pbAddChannel_Callback(obj,~,~)
            prompt = 'Enter name for new channel: ';
            str = input(prompt,'s');
            if ~isempty(str)
                obj.MainObj.DataBuffer.setChanNames(str,1);
                fprintf('Added new channel %s with %i zeros\n',str,obj.MainObj.DataBuffer.TotalSamples);
            end
            obj.pbUpdate_Callback();
        end
        
        %% PushButton Add File Callback
        function pbAddFile_Callback(obj,~,~)
            obj.MainObj.DataBuffer.load([]);
            obj.pbUpdate_Callback();
        end
        
        %% PushButton Clear Callback
        function pbClear_Callback(obj,~,~)
            if ~isempty(obj.ChanNames) && obj.UI.ListConnected.Value && obj.UI.ListConnected.Value <= size(obj.ChanNames,2)
                % Start Mitm Streaming
                fprintf('Permanently deleted data from channel %s\n',obj.UI.ListConnected.String{obj.UI.ListConnected.Value});
                obj.MainObj.DataBuffer.removeChan(obj.ChanNames(:,obj.UI.ListConnected.Value));
                % Decrement selection
                if obj.UI.ListConnected.Value > size(obj.ChanNames,2)
                    obj.UI.ListConnected.Value = size(obj.ChanNames,2);
                end
            else
                warning('Cannot clear channel, no channels connected.')
            end
%             obj.pbUpdate_Callback();
        end
        
        %% Load File Graphics Code
        
        function UI = graphicsCode(obj)
            % GRAPHICSCODE Graphics Code
            % Standard Selector UI panel
            x=3;y=6;
            UI.TextAvailable = uicontrol(obj.Parent,'Style','text',...
                'String','Available Channels:','Units','Normalized',...
                'Position',grid2pos([1,1, 1,1, x,y]));
            UI.TextConnected = uicontrol(obj.Parent,'Style','text',...
                'String','Connected Channels:','Units','Normalized',...
                'Position',grid2pos([3,1, 1,1, x,y]));
            UI.ListAvailable = uicontrol(obj.Parent,'Style','listbox',...
                'String',{'not loaded'},'Units','Normalized',...
                'Position',grid2pos([1,2, 1,y-2, x,y]));
            UI.ListConnected = uicontrol(obj.Parent,'Style','listbox',...
                'String',{},'Units','Normalized',...
                'Position',grid2pos([3,2, 1,y-2, x,y]));
            UI.PbUpdate = uicontrol(obj.Parent,'Style','pushbutton',...
                'String','Update','Units','Normalized',...
                'Position',grid2pos([2,2, 1,1, x,y]),'Callback',@obj.pbUpdate_Callback);
            UI.PbAdd = uicontrol(obj.Parent,'Style','pushbutton',...
                'String','Connect -->','Units','Normalized',...
                'Position',grid2pos([2,3, 1,1, x,y]),'Callback',@obj.pbAdd_Callback);
            UI.PbRemove = uicontrol(obj.Parent,'Style','pushbutton',...
                'String','<-- Remove','Units','Normalized',...
                'Position',grid2pos([2,4, 1,1, x,y]),'Callback',@obj.pbRemove_Callback);
            UI.PbAddFile = uicontrol(obj.Parent,'Style','pushbutton',...
                'String','Add File','Units','Normalized',...
                'Position',grid2pos([1,y, 1,1, x,y]),'Callback',@obj.pbAddFile_Callback);
            UI.PbAddChannel = uicontrol(obj.Parent,'Style','pushbutton',...
                'String','Add channel','Units','Normalized',...
                'Position',grid2pos([2,y, 1,1, x,y]),'Callback',@obj.pbAddChannel_Callback);
            UI.PbClear = uicontrol(obj.Parent,'Style','pushbutton',...
                'String','Clear Channel from buffer','Units','Normalized',...
                'Position',grid2pos([3,y, 1,1, x,y]),'Callback',@obj.pbClear_Callback);
        end
        
    end
end