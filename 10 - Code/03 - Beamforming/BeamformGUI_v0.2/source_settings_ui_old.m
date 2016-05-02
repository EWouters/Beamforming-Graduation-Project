% Source Settings Selection UI Class.
%  Example1
%   obj = source_ui
%  Example2
%   Parent = figure
%   obj = source_ui(Parent)

%   Copyright 2015 BabForming.

classdef source_settings_ui_old < handle
%% Source Settings Selection UI Class
    %  This class holds the gui elements for the source settings selection panel
    %% Properties
    properties
        Parent              % Handle of parent
        Name = 'Source Settings'; % Name of UI
        RbgOptions = {'Smartphones','File','Simulation','USB audio inteface'};
        SelectedSource = 1; % Selected Source
        Smartphones
        File
        Simulation
        USB
        UI                  % Cell UIs for the options
        BFCom
    end
    %% Methods
    methods
        %% UI Constuctor
        function obj = source_settings_ui(varargin)
            % Set defaults
            obj.File.Path = [pwd,'\files'];
            obj.File.Name = 'Source1.wav';
            obj.Smartphones.IDsA = {'ID1','ID2','ID3','ID4','ID5','ID6','ID7'};
            obj.Smartphones.IDsC = {};
            
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
            % Radio button options
            ButtonGroup1 = uibuttongroup(obj.Parent,'Position',grid2pos([1,1, 1,1, 1,3]),...
                'Title','Select Audio Source',...
                'SelectionChangedFcn',@obj.ButtonGroup1_SeclectionChanged);
            n = numel(obj.RbgOptions);
            for ii = 1:n
                uicontrol(ButtonGroup1,'Style','radiobutton',...
                    'String',obj.RbgOptions{ii},'Units','Normalized',...
                    'Position',grid2pos([1,ii, 1,1, 1,n, 0.01]),...
                    'Tag',mat2str(ii));
                obj.UI{ii}.Panel = uipanel(obj.Parent,'Position',grid2pos([1,2, 1,2, 1,3]),...
                    'Title',[obj.RbgOptions{ii} ' details'],'Visible','Off');
            end
            obj.UI{obj.SelectedSource}.Panel.Visible = 'On';
            
            %% Smartphones UI panel
            obj.UI{1}.ListPhonesA = uicontrol(obj.UI{1}.Panel,'Style','listbox',...
                'String',{},'Units','Normalized',...
                'Position',grid2pos([1,1, 1,1, 3,1]));
            obj.UI{1}.ListPhonesC = uicontrol(obj.UI{1}.Panel,'Style','listbox',...
                'String',{},'Units','Normalized',...
                'Position',grid2pos([3,1, 1,1, 3,1]));
            obj.UI{1}.PbUpdate = uicontrol(obj.UI{1}.Panel,'Style','pushbutton',...
                'String','Update','Units','Normalized',...
                'Position',grid2pos([2,2, 1,1, 3,5]),'Callback',@obj.pbUpdate_Callback);
            obj.UI{1}.PbConnect = uicontrol(obj.UI{1}.Panel,'Style','pushbutton',...
                'String','Connect ->','Units','Normalized',...
                'Position',grid2pos([2,3, 1,1, 3,5]),'Callback',@obj.pbConnect_Callback);
            obj.UI{1}.PbDisconnect = uicontrol(obj.UI{1}.Panel,'Style','pushbutton',...
                'String','<-- Disconnect','Units','Normalized',...
                'Position',grid2pos([2,4, 1,1, 3,5]),'Callback',@obj.pbDisconnect_Callback);
            %% File UI panel
            n=5;m=7;
            obj.UI{2}.TextPath = uicontrol(obj.UI{2}.Panel,'Style','text',...
                'String','File Path','Units','Normalized',...
                'Position',grid2pos([1,1, 1,1, m,n]));
%             set(obj.UI{2}.TextPath,'VerticalAlignment','middle')
            obj.UI{2}.EditPath = uicontrol(obj.UI{2}.Panel,'Style','edit',...
                'String',fullfile(obj.File.Path,obj.File.Name),'Units','Normalized',...
                'Position',grid2pos([2,1, 5,1, m,n]));
            obj.UI{2}.PbPath = uicontrol(obj.UI{2}.Panel,'Style','pushbutton',...
                'String','Add','Callback',@obj.pbPath_Callback,...
                'Units','normalized','Position',grid2pos([6,1, 1,1, m,n]));
            obj.UI{2}.TextFileHeader = uicontrol(obj.UI{2}.Panel,'Style','listbox',...
                'Units','Normalized','Position',grid2pos([1,2, 1,4, 1,n]),...
                'String',{'File header:','not loaded'});
            %% Simulation Panel
            
            %% USB audio interface UI panel
            obj.USB = scarlett_ui(obj.UI{4}.Panel);
            
            %% Update phone IDs
            obj.UI{1}.ListPhonesA.String = obj.Smartphones.IDsA;
            obj.UI{1}.ListPhonesC.String = obj.Smartphones.IDsC;
        end
        %% ButtonGroup1 Selection Changed function
        function ButtonGroup1_SeclectionChanged(obj,~,cbd)
            obj.UI{obj.SelectedSource}.Panel.Visible = 'Off';
            obj.SelectedSource = str2double(cbd.NewValue.Tag);
            obj.UI{obj.SelectedSource}.Panel.Visible = 'On';
        end
        %% ButtonGroup1 Selection Changed function
        function pbPath_Callback(obj,~,~)
            [name1,path1] = uigetfile(...
                {'*.wav','Waveform Audio File Format (*.wav)';...
                '*.mat','MAT-files (*.mat)';...
                '*.*',  'All Files (*.*)'},...
                'Select File',obj.UI{2}.EditPath.String);
%             fullfile(obj.File.Path,obj.File.Name)
            if ~ischar(name1) || ~ischar(path1)
                warning('Invalid file selected.');
            else
                obj.File.Name = name1;
                obj.File.Path = path1;
                obj.UI{2}.EditPath.String = fullfile(path1,name1);
                obj.UI{2}.TextFileHeader.String = printInfo(path1,name1);
            end
        end
        
        %% PushButton Get Phone IDs Callback
        function pbUpdate_Callback(obj,~,~)
            obj.UI{1}.ListPhonesA.String = obj.Smartphones.IDsA;
            obj.UI{1}.ListPhonesC.String = obj.Smartphones.IDsC;
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
            obj.UI{1}.ListPhonesC.String = obj.Smartphones.IDsC;
        end
        %% PushButton Disconnect Callback
        function pbDisconnect_Callback(obj,~,~)
            ii = obj.UI{1}.ListPhonesC.Value;
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
                        obj.UI{1}.ListPhonesC.Value = ii-1;
                    end
                end
            end
            obj.UI{1}.ListPhonesA.String = obj.Smartphones.IDsA;
            obj.UI{1}.ListPhonesC.String = obj.Smartphones.IDsC;
        end
    end
end