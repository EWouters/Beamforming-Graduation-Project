classdef main_window
%% Main Window Class
    %  This class is a standard gui window generator
    %% Constants
    properties (Constant)
        Name = 'Beamformer Main Window'
    end
    %% Properties
    properties
        figMain
        PanSettings % Change to only pan
        PanPlayRec
        PanRep
        PanIntel
        PanPlots
        BFCom
        Mitm
        Directivity
        Channels
    end
    %% Methods
    methods
        %% Standard Window Constuctor
        function obj = main_window(varargin)
            %% Create figure
            obj.figMain = figure('name',obj.Name,'NumberTitle','off','resize', 'on',...
                'units','normalized','outerposition',[0.00 0.05 1 1-0.05]);
            GridSize = [4,2];
            %% Create Settings Panel
            obj.PanSettings = std_panel(obj.figMain, grid2pos([1,1,1,1,GridSize]),6);
            obj.PanSettings.Name = 'Settings';
            obj.PanSettings.Panel.Title = 'Settings';
            % Set tab titles
            obj.PanSettings.Tabs{1}.Title = 'Source';
            obj.PanSettings.Tabs{2}.Title = 'Channel Mapping';
            obj.PanSettings.Tabs{3}.Title = 'Beamformers';
            obj.PanSettings.Tabs{4}.Title = 'Directivity';
            obj.PanSettings.Tabs{5}.Title = 'Intelligibility';
            obj.PanSettings.Tabs{6}.Title = 'Recording';
            % Add panels
            obj.PanSettings.UI{1} = source_settings_ui(obj.PanSettings.Tabs{1},obj);
            obj.PanSettings.UI{2} = chan_map_ui(obj.PanSettings.Tabs{2},obj.PanSettings);
            obj.PanSettings.UI{4} = directivity_ui(obj.PanSettings.Tabs{4});
            
            %% Create Playback and Recording Panel
            obj.PanPlayRec = std_panel(obj.figMain, grid2pos([1,2,1,1,GridSize]),3);
            obj.PanPlayRec.Name = 'Playback and Recording';
            obj.PanPlayRec.Panel.Title = 'Playback and Recording';
            % Set tab titles
            obj.PanPlayRec.Tabs{1}.Title = 'Recording';
            obj.PanPlayRec.Tabs{2}.Title = 'Playback';
            obj.PanPlayRec.Tabs{3}.Title = 'Processing';
            % Add panels
            obj.PanPlayRec.UI = rec_play_ui(obj);
            
            %% Create System Representation Panel
            % Plot of current source positions
            obj.PanRep = std_panel(obj.figMain, grid2pos([2,1,1,1,GridSize]));
            obj.PanRep.Name = 'System Representation';
            obj.PanRep.Panel.Title = 'System Representation';
            
            %% Create Intelligibility Panel
            % Representation of signal quality
            obj.PanIntel = std_panel(obj.figMain, grid2pos([2,2,1,1,GridSize]));
            obj.PanIntel.Name = 'Intelligibility';
            obj.PanIntel.Panel.Title = 'Intelligibility';
            
            %% Create Plots Panel
            obj.PanPlots = std_panel(obj.figMain, grid2pos([3,1,2,2,GridSize]),2);
            obj.PanPlots.Name = 'Plots';
            obj.PanPlots.Panel.Title = 'Plots';
            % Set tab titles
            obj.PanPlots.Tabs{1}.Title = 'Audio Signals';
            obj.PanPlots.Tabs{2}.Title = 'Beampatterns';
            %  Plot1
            obj.PanPlots.UI{1} = plot_audio_ui(obj.PanPlots.Tabs{1},obj.PanSettings.UI{2});
            
            %% Copy handles of BFCom and Mitm to this class
            obj.BFCom = obj.PanSettings.UI{1}.Smartphones.BFCom;
            obj.Mitm = obj.PanSettings.UI{1}.Smartphones.Mitm;
            obj.Directivity = obj.PanSettings.UI{4}.Directivity;
            obj.Channels = obj.PanSettings.UI{2};
        end
    end
end