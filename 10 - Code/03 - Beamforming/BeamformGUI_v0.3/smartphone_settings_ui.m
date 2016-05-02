% Smartphone Settings Selection UI Class.
%  Example1
%   obj = smartphone_settings_ui
%  Example2
%   Parent = figure
%   obj = smartphone_settings_ui(Parent)

%   Copyright 2015 BabForming.

classdef smartphone_settings_ui < handle
%% Smartphone Settings Selection UI Class
    %  This class holds the gui elements for the source settings selection panel
    %% Properties
    properties
        Parent              % Handle of parent
        Name = 'Smartphone Settings'; % Name of UI
        UI                  % Cell UIs for the options
        BFCom
        Mitm
    end
    %% Methods
    methods
        %% UI Constuctor
        function obj = smartphone_settings_ui(varargin)
            % Set defaults
            obj.BFCom = bfcom;
%             obj.Mitm = mitm(1337,48000,obj.BFCom);
            obj.Mitm = mitm(obj.BFCom);
            
            %% Parse Input
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
            
            %% Graphics Code
            % Smartphones UI panel
            n=5;m=3;
            obj.UI.TextAvailable = uicontrol(obj.Parent,'Style','text',...
                'String','Available:','Units','Normalized',...
                'Position',grid2pos([1,1, 1,1, m,n]));
            obj.UI.TextStreaming = uicontrol(obj.Parent,'Style','text',...
                'String','Streaming:','Units','Normalized',...
                'Position',grid2pos([3,1, 1,1, m,n]));
            obj.UI.ListPhonesMitm = uicontrol(obj.Parent,'Style','listbox',...
                'String',{'not loaded'},'Units','Normalized',...
                'Position',grid2pos([1,2, 1,n-1, m,n]));
            obj.UI.ListPhonesBFCom = uicontrol(obj.Parent,'Style','listbox',...
                'String',{},'Units','Normalized',...
                'Position',grid2pos([3,2, 1,n-1, m,n]));
            obj.UI.PbStartServer = uicontrol(obj.Parent,'Style','pushbutton',...
                'String','Start Server','Units','Normalized',...
                'Position',grid2pos([2,2, 1,1, m,n]),'Callback',@obj.pbStartServer_Callback);
            obj.UI.PbUpdate = uicontrol(obj.Parent,'Style','pushbutton',...
                'String','Update','Units','Normalized',...
                'Position',grid2pos([2,3, 1,1, m,n]),'Callback',@obj.pbUpdate_Callback);
            obj.UI.PbConnect = uicontrol(obj.Parent,'Style','pushbutton',...
                'String','Connect ->','Units','Normalized',...
                'Position',grid2pos([2,4, 1,1, m,n]),'Callback',@obj.pbConnect_Callback);
            obj.UI.PbDisconnect = uicontrol(obj.Parent,'Style','pushbutton',...
                'String','<-- Disconnect','Units','Normalized',...
                'Position',grid2pos([2,5, 1,1, m,n]),'Callback',@obj.pbDisconnect_Callback);
            obj.UI.PbConnect.Enable = 'off';
            obj.UI.PbDisconnect.Enable = 'off';
            
%             %% Update phone IDs
%             obj.UI.ListPhonesMitm.String = obj.Mitm.getPhoneIDs();
            obj.UI.ListPhonesBFCom.String = obj.BFCom.getPhoneIDs();
        end
        %% PushButton Start Server Callback
        function pbStartServer_Callback(obj,~,~)
                if ~obj.Mitm.is_running
                    obj.Mitm.startSITM();
                    if obj.Mitm.is_running
                        obj.UI.PbStartServer.String = 'Stop Server';
                        obj.UI.PbConnect.Enable = 'on';
                        obj.UI.PbDisconnect.Enable = 'on';
                    else
                        warning('Failed to stop server');
                    end
                else
                    obj.Mitm.stop();
                    if ~obj.Mitm.is_running
                        obj.UI.PbStartServer.String = 'Start Server';
                        obj.UI.PbConnect.Enable = 'off';
                        obj.UI.PbDisconnect.Enable = 'off';
                        
                        %---------
                        % At this moment mitm should make all the phones
                        % call 'lostConnection(phoneID)'
                        %
                        % or
                        %
                        % This call should contain:
                        while ~isempty(obj.BFCom.Phones)
                            obj.Mitm.stopStreaming(obj.BFCom.Phones(1));
                            obj.BFCom.Phones(1) = [];
                        end
                        %---------
                        
                    else
                        warning('Failed to stop server');
                    end
                end
            obj.UI.ListPhonesMitm.String = obj.Mitm.getPhoneIDs();
            obj.UI.ListPhonesBFCom.String = obj.BFCom.getPhoneIDs();
        end
        %% PushButton Get Phone IDs Callback
        function pbUpdate_Callback(obj,~,~)
            obj.UI.ListPhonesMitm.String = obj.Mitm.getPhoneIDs();
            obj.UI.ListPhonesBFCom.String = obj.BFCom.getPhoneIDs();
        end
        %% PushButton Connect Callback
        function pbConnect_Callback(obj,~,~)
            phoneIDs = obj.Mitm.getPhoneIDs();
            if ~isempty(phoneIDs)
                num = obj.UI.ListPhonesMitm.Value;
                % Add Phone to BFCom
                obj.BFCom.newPhone(phoneIDs{num});
%                 obj.Mitm.startStreaming(ids{ii});
                fprintf('[DUMMY]Connecting to %s\n',phoneIDs{num});
                % Increment selection
                if num < length(phoneIDs)
                    obj.UI.ListPhonesMitm.Value = num + 1;
                else
                    obj.UI.ListPhonesMitm.Value = 1;
                end
            end
            obj.UI.ListPhonesMitm.String = obj.Mitm.getPhoneIDs();
            obj.UI.ListPhonesBFCom.String = obj.BFCom.getPhoneIDs();
        end
        %% PushButton Disconnect Callback
        function pbDisconnect_Callback(obj,~,~)
            phoneIDs = obj.BFCom.getPhoneIDs();
            if ~isempty(phoneIDs)
                num = obj.UI.ListPhonesBFCom.Value;
                % Stop Mitm Streaming
                obj.Mitm.stopStreaming(phoneIDs{num});
                obj.BFCom.Phones(num) = [];
                fprintf('[DUMMY]Disconnecting %s\n',phoneIDs{num});
            end
            obj.UI.ListPhonesMitm.String = obj.Mitm.getPhoneIDs();
            obj.UI.ListPhonesBFCom.String = obj.BFCom.getPhoneIDs();
        end
    end
end