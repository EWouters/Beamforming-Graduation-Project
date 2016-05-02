% Smartphone Settings Selection UI Class.
%  Example1
%   obj = source_ui
%  Example2
%   Parent = figure
%   obj = source_ui(Parent)

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
            obj.BFCom.phones(2) = obj.BFCom.phones(1);
            
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
                'Position',grid2pos([0,n-1, 1,1, m,n]));
            obj.UI.TextStreaming = uicontrol(obj.Parent,'Style','text',...
                'String','Streaming:','Units','Normalized',...
                'Position',grid2pos([2,n-1, 1,1, m,n]));
            obj.UI.ListPhonesA = uicontrol(obj.Parent,'Style','listbox',...
                'String',{'not loaded'},'Units','Normalized',...
                'Position',grid2pos([0,0, 1,n-1, m,n]));
            obj.UI.ListPhonesS = uicontrol(obj.Parent,'Style','listbox',...
                'String',{},'Units','Normalized',...
                'Position',grid2pos([2,0, 1,n-1, m,n]));
            obj.UI.PbUpdate = uicontrol(obj.Parent,'Style','pushbutton',...
                'String','Update','Units','Normalized',...
                'Position',grid2pos([1,n-2, 1,1, m,n]),'Callback',@obj.pbUpdate_Callback);
            obj.UI.PbConnect = uicontrol(obj.Parent,'Style','pushbutton',...
                'String','Connect ->','Units','Normalized',...
                'Position',grid2pos([1,n-3, 1,1, m,n]),'Callback',@obj.pbConnect_Callback);
            obj.UI.PbDisconnect = uicontrol(obj.Parent,'Style','pushbutton',...
                'String','<-- Disconnect','Units','Normalized',...
                'Position',grid2pos([1,n-4, 1,1, m,n]),'Callback',@obj.pbDisconnect_Callback);

            %% Update phone IDs
%             obj.UI{1}.ListPhonesA.String = obj.Smartphones.IDsA;
%             obj.UI{1}.ListPhonesS.String = obj.Smartphones.IDsC;
        end
        %% PushButton Get Phone IDs Callback
        function pbUpdate_Callback(obj,~,~)
            if obj.Mitm.is_running
                obj.UI.ListPhonesA.String = obj.Mitm.getPhoneIDs();
            else
                obj.Mitm.startSITM();
                if obj.Mitm.is_running
                    obj.UI.ListPhonesA.String = obj.Mitm.getPhoneIDs(obj);
                else
                    warning('Could not connect to JavaSocket (mitm)');
                end
            end
            obj.UI.ListPhonesS.String = obj.BFCom.phones.phoneID;
        end
        %% PushButton Connect Callback
        function pbConnect_Callback(obj,~,~)
            ii = obj.UI{1}.ListPhonesA.Value;
            if ~isempty(obj.Smartphones.IDsA)
                %%
                % Connect callback to midm comes here
                fprintf('Connecting to %s\n',obj.Smartphones.IDsA{ii});
                conSucces = 1;
                %%
                
                
                if conSucces
                    obj.Smartphones.IDsC{end+1} = obj.Smartphones.IDsA{ii};
                    obj.Smartphones.IDsA = {obj.Smartphones.IDsA{1:ii-1}, obj.Smartphones.IDsA{ii+1:end}};
                    if ii > numel(obj.Smartphones.IDsA) && ii > 1
                        obj.UI{1}.ListPhonesA.Value = ii-1;
                    end
                end
            end
            obj.UI{1}.ListPhonesA.String = obj.Smartphones.IDsA;
            obj.UI{1}.ListPhonesS.String = obj.Smartphones.IDsC;
        end
        %% PushButton Disconnect Callback
        function pbDisconnect_Callback(obj,~,~)
            ii = obj.UI{1}.ListPhonesS.Value;
            if ~isempty(obj.Smartphones.IDsC)
                
                
                
                
                %%
                % Connect callback to midm comes here
                fprintf('Disconnecting %s\n',obj.Smartphones.IDsC{ii});
                disconSucces = 1;
                %%
                
                
                if disconSucces
                    obj.Smartphones.IDsA{end+1} = obj.Smartphones.IDsC{ii};
                    obj.Smartphones.IDsC = {obj.Smartphones.IDsC{1:ii-1}, obj.Smartphones.IDsC{ii+1:end}};
                    if ii > numel(obj.Smartphones.IDsC) && ii > 1
                        obj.UI{1}.ListPhonesS.Value = ii-1;
                    end
                end
            end
            obj.UI{1}.ListPhonesA.String = obj.Smartphones.IDsA;
            obj.UI{1}.ListPhonesS.String = obj.Smartphones.IDsC;
        end
    end
end