% Source Settings Selection UI Class.
%  Example1
%   obj = source_ui
%  Example2
%   Parent = figure
%   obj = source_ui(Parent)

%   Copyright 2015 BabForming.

classdef source_settings_ui < handle
%% Source Settings Selection UI Class
    %  This class holds the gui elements for the source settings selection panel
    %% Properties
    properties
        MainObj
        Parent              % Handle of parent
        Name = 'Source Settings'; % Name of UI
        RbgOptions = {'Smartphones','File','Simulation','USB audio inteface','Computer Mic'};
        SelectedSource = 1; % Selected Source
        Smartphones
        File
        Simulation
        USB
        CompMic
        UI                  % Cell UIs for the options
    end
    %% Methods
    methods
        %% UI Constuctor
        function obj = source_settings_ui(varargin)
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
            if nargin > 1
                obj.MainObj = varargin{2};
            end
            
            %% Graphics Code
            % Radio button options
            RbgSource = uibuttongroup(obj.Parent,'Position',grid2pos([1,1, 1,1, 1,3]),...
                'Title','Select Audio Source',...
                'SelectionChangedFcn',@obj.RbgSource_SeclectionChanged);
            n = numel(obj.RbgOptions);
            for ii = 1:n
                uicontrol(RbgSource,'Style','radiobutton',...
                    'String',obj.RbgOptions{ii},'Units','Normalized',...
                    'Position',grid2pos([1,ii, 1,1, 1,n, 0.01]),...
                    'Tag',mat2str(ii));
                obj.UI{ii}.Panel = uipanel(obj.Parent,'Position',grid2pos([1,2, 1,2, 1,3]),...
                    'Title',[obj.RbgOptions{ii} ' details'],'Visible','Off');
            end
            obj.UI{obj.SelectedSource}.Panel.Visible = 'On';
            
            %% Smartphones UI panel
            obj.Smartphones = smartphone_settings_ui(obj.UI{1}.Panel);
            
            %% File UI panel
            obj.File = load_file_settings_ui(obj.UI{2}.Panel);
            
            %% Simulation Panel
            obj.Simulation = simulation_ui(obj.UI{3}.Panel);
            %% USB audio interface UI panel
            obj.USB = scarlett_ui(obj.UI{4}.Panel);
            
            %% Computer Mic Interface panel
            obj.CompMic = comp_mic_ui(obj.UI{5}.Panel);
        end
        %% RbgSource Selection Changed function
        function RbgSource_SeclectionChanged(obj,~,cbd)
            obj.UI{obj.SelectedSource}.Panel.Visible = 'Off';
            obj.SelectedSource = str2double(cbd.NewValue.Tag);
            obj.UI{obj.SelectedSource}.Panel.Visible = 'On';
            try
                obj.MainObj.PanSettings.UI{2}.pbUpdateChannels_Callback();
            catch ME
                warning('Could not update Channel Map')
                rethrow(ME)
            end
        end
    end
end