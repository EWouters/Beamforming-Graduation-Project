classdef smartphone_settings_ui < handle
    % SMARTPHONE_SETTINGS_UI Holds the gui elements for the source settings selection panel
    %
    %   SMARTPHONE_SETTINGS_UI() create ui in new figure
    %   SMARTPHONE_SETTINGS_UI(OBJ) create ui in parent panel
    %   SMARTPHONE_SETTINGS_UI(OBJ, MAINOBJ) create ui with handle to main object
    %
    % Example 1:
    %   obj = smartphone_settings_ui
    %
    % Example 2:
    %   Parent = figure
    %   obj = smartphone_settings_ui(Parent)
    %
    % SMARTPHONE_SETTINGS_UI Methods:
    %   pbStartServer_Callback    - PushButton Start Server Callback.
    %   pbUpdateIDs_Callback      - PushButton Update Phone IDs Callback
    %   pbStartStreaming_Callback - PushButton StartStreaming Callback
    %   pbStopStreaming_Callback  - PushButton StopStreaming Callback
    %
    % SMARTPHONE_SETTINGS_UI Properties:
    %   Parent  - Handle of panel to place ui in
    %   MainObj - Handle of main object
    %   Name    - Name of UI
    %   UI      - Cell UIs for the options
    %   Tag     - Tag to find object
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
    %   See also MITM, BF_DATA, MAIN_WINDOW
    
    %% Properties
    properties
        Parent                          % Handle of panel to place ui in
        MainObj                         % Handle of main object
        Name = 'Smartphone Settings';   % Name of UI
        UI                              % Cell UIs for the options
        Tag = 'smartphone_settings_ui'; % Tag to find object
    end
    % Methods
    methods
        %% UI Constuctor
        function obj = smartphone_settings_ui(parent, mainObj)
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
            
            % Graphics Code
            % Smartphones UI panel
            n=6;m=3;
            obj.UI.TextAvailable = uicontrol(obj.Parent,'Style','text',...
                'String','Available:','Units','Normalized',...
                'Position',grid2pos([1,1, 1,1, m,n]));
            obj.UI.TextStreaming = uicontrol(obj.Parent,'Style','text',...
                'String','Streaming:','Units','Normalized',...
                'Position',grid2pos([3,1, 1,1, m,n]));
            obj.UI.ListConnected = uicontrol(obj.Parent,'Style','listbox',...
                'String',{'not loaded'},'Units','Normalized',...
                'Position',grid2pos([1,2, 1,n-1, m,n]));
            obj.UI.ListStreaming = uicontrol(obj.Parent,'Style','listbox',...
                'String',{},'Units','Normalized',...
                'Position',grid2pos([3,2, 1,n-1, m,n]));
            obj.UI.PbStartServer = uicontrol(obj.Parent,'Style','pushbutton',...
                'String','Start Server','Units','Normalized',...
                'Position',grid2pos([2,2, 1,1, m,n]),'Callback',@obj.pbStartServer_Callback);
            obj.UI.PbUpdate = uicontrol(obj.Parent,'Style','pushbutton',...
                'String','Update','Units','Normalized',...
                'Position',grid2pos([2,3, 1,1, m,n]),'Callback',@obj.pbUpdateIDs_Callback);
            obj.UI.PbStartStreaming = uicontrol(obj.Parent,'Style','pushbutton',...
                'String','Start Streaming ->','Units','Normalized',...
                'Position',grid2pos([2,4, 1,1, m,n]),'Callback',@obj.pbStartStreaming_Callback);
            obj.UI.PbStopStreaming = uicontrol(obj.Parent,'Style','pushbutton',...
                'String','<-- Stop Streaming','Units','Normalized',...
                'Position',grid2pos([2,5, 1,1, m,n]),'Callback',@obj.pbStopStreaming_Callback);
            obj.UI.PbSynchronize = uicontrol(obj.Parent,'Style','pushbutton',...
                'String','Synchronize','Units','Normalized',...
                'Position',grid2pos([2,6, 1,1, m,n]),'Callback','warning(''Synchronisation not implemented yet'')');
            obj.UI.PbStartStreaming.Enable = 'off';
            obj.UI.PbStopStreaming.Enable = 'off';
            
            % Debug
%             assignin('base','obj',obj)
        end
        %% PushButton Start Server Callback
        function pbStartServer_Callback(obj,~,~)
            if ~obj.MainObj.Mitm.is_running
                obj.MainObj.Mitm.startSITM();
                if obj.MainObj.Mitm.is_running
                    obj.UI.PbStartServer.String = 'Stop Server';
                    obj.UI.PbStartStreaming.Enable = 'on';
                    obj.UI.PbStopStreaming.Enable = 'on';
                else
                    warning('Failed to stop server');
                end
            else
                obj.MainObj.Mitm.stop();
                if ~obj.MainObj.Mitm.is_running
                    obj.UI.PbStartServer.String = 'Start Server';
                    obj.UI.PbStartStreaming.Enable = 'off';
                    obj.UI.PbStopStreaming.Enable = 'off';
                else
                    warning('Failed to stop server');
                end
            end
            obj.pbUpdateIDs_Callback();
        end
        %% PushButton Update Phone IDs Callback
        function pbUpdateIDs_Callback(obj,~,~)
            obj.UI.ListConnected.String = obj.MainObj.Mitm.getPhoneIDs();
            obj.UI.ListStreaming.String = obj.MainObj.Mitm.getStreamingIDs();
            if ~isempty(obj.UI.ListStreaming.String)
                if isempty(obj.UI.ListStreaming.String{1})
                    obj.UI.ListStreaming.String = {};
                end
            end
        end
        %% PushButton StartStreaming Callback
        function pbStartStreaming_Callback(obj,~,~)
            if ~isempty(obj.UI.ListConnected.String) && ~isempty(obj.MainObj.Mitm.getPhoneIDs())
                % Start Mitm Streaming
                obj.MainObj.Mitm.startStreaming(obj.UI.ListConnected.String{obj.UI.ListConnected.Value});
                fprintf('Started Streaming from %s\n',obj.UI.ListConnected.String{obj.UI.ListConnected.Value});
                % Increment selection
                if obj.UI.ListConnected.Value < length(obj.UI.ListConnected.String)
                    obj.UI.ListConnected.Value = obj.UI.ListConnected.Value + 1;
                else
                    obj.UI.ListConnected.Value = 1;
                end
            else
                warning('Cannot start streaming when no phones are connected')
            end
            obj.pbUpdateIDs_Callback();
        end
        %% PushButton StopStreaming Callback
        function pbStopStreaming_Callback(obj,~,~)
            if ~isempty(obj.UI.ListStreaming.String) && ~isempty(obj.MainObj.Mitm.getStreamingIDs())
                % Stop Mitm Streaming
                obj.MainObj.Mitm.stopStreaming(obj.UI.ListStreaming.String{obj.UI.ListStreaming.Value});
                fprintf('Stopped Streaming from %s\n',obj.UI.ListStreaming.String{obj.UI.ListStreaming.Value});
                % Decrement selection
                if obj.UI.ListStreaming.Value > length(obj.UI.ListStreaming.String)
                    obj.UI.ListStreaming.Value = obj.UI.ListStreaming.Value - 1;
                else
                    obj.UI.ListStreaming.Value = 1;
                end
            else
                warning('Cannot stop streaming when no phones are streaming')
            end
            obj.pbUpdateIDs_Callback();
        end
    end
end