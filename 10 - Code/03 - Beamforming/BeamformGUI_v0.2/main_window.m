classdef main_window
%% Main Window Class
    %  This class is a standard gui window generator
    %% Constants
    properties (Constant)
%         Consts1 = consts;	% Constant property from another class
    end
    %% Properties
    properties
        figMain
        Settings
        PanSettings
        PanPlayRec
        PanRep
        PanIntel
        PanPlots
        BFCom
        Mitm
    end
    %% Methods
    methods
        %% Standard Window Constuctor
        function obj = main_window(varargin)
            %% Import Settings
            obj.Settings = bfSettings('Default');
            
            %% Create figure
            obj.figMain = figure('name','Beamformer Main Window','NumberTitle','off','resize', 'on',...
                'units','normalized','outerposition',[0.00 0.05 1 1-0.05]);
            GridSize = [4,2];
            %% Create Settings Panel
            obj.PanSettings = std_panel(obj.figMain, grid2pos([0,1,1,1,GridSize]),8);
            obj.PanSettings.Name = 'Settings';
            obj.PanSettings.Panel.Title = 'Settings';
            % Set tab titles
            obj.PanSettings.Tabs{1}.Title = 'Source';
            obj.PanSettings.Tabs{1}.Title = 'Channel Mapping';
            obj.PanSettings.Tabs{2}.Title = 'Beamformers';
            obj.PanSettings.Tabs{5}.Title = 'Directivity';
            obj.PanSettings.Tabs{7}.Title = 'Intelligibility';
            obj.PanSettings.Tabs{8}.Title = 'Recording';
            % Add panels
            obj.PanSettings.UI{1} = source_settings_ui(obj.PanSettings.Tabs{1});
            
            %% Create Source Panel
            obj.PanPlayRec = std_panel(obj.figMain, grid2pos([0,0,1,1,GridSize]));
            obj.PanPlayRec.Name = 'Playback and Recording';
            obj.PanPlayRec.Panel.Title = 'Playback and Recording';
            
            %% Create Localization Panel
            obj.PanRep = std_panel(obj.figMain, grid2pos([1,1,1,2,GridSize]));
            obj.PanRep.Name = 'System Representation';
            obj.PanRep.Panel.Title = 'System Representation';
            obj.PanRep.UI = loc_ui(obj.PanRep.Panel);
            
            %% Create Intelligibility Panel
            obj.PanIntel = std_panel(obj.figMain, grid2pos([1,0,1,1,GridSize]));
            obj.PanIntel.Name = 'Intelligibility';
            obj.PanIntel.Panel.Title = 'Intelligibility';
            
            %% Create Plots Panel
            obj.PanPlots = std_panel(obj.figMain, grid2pos([2,0,2,3,GridSize]),2);
            obj.PanPlots.Name = 'Plots';
            obj.PanPlots.Panel.Title = 'Plots';
            % Set tab titles
            obj.PanPlots.Tabs{1}.Title = 'Audio Signals';
            obj.PanPlots.Tabs{2}.Title = 'Plot 1';
            %  Plot1
            obj.PanPlots.UI{1} = plot1_ui(obj.PanPlots.Tabs{1});
            
            
        end
        function b = test_bfcom(obj,str)
            obj.BFCom.Tag = str;
            b = obj.BFCom;
        end
    end
end