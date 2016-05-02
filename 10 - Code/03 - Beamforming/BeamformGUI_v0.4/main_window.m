classdef main_window < handle
%% Main Window Class
    %  This class is a main gui window generator
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
        %% Main GUI Window Constuctor
        function obj = main_window(varargin)
            try close all; catch; end
            %% Create figure
            obj.figMain = figure('name',obj.Name,'NumberTitle','off','resize', 'on',...
                'units','normalized','outerposition',[0.00 0.05 1 1-0.05],...
                'CloseRequestFcn',@obj.closeReq_Callback);
            GridSize = [4,2];
            %% Create Settings Panel
            obj.PanSettings = std_panel(obj.figMain, grid2pos([1,1,1,1,GridSize]),...
                {'Source','Channel Mapping','Beamformers',...
                'Directivity','Intelligibility','Recording'});
            obj.PanSettings.Name = 'Settings';
            obj.PanSettings.Panel.Title = 'Settings';
            % Add panels
            obj.PanSettings.UI{1} = source_settings_ui(obj.PanSettings.Tabs{1},obj);
            obj.PanSettings.UI{2} = chan_map_ui(obj.PanSettings.Tabs{2},obj.PanSettings);
            obj.PanSettings.UI{3} = beamformers_ui(obj.PanSettings.Tabs{3},obj);
            obj.PanSettings.UI{4} = directivity_ui(obj.PanSettings.Tabs{4});
            
            %% Create Playback and Recording Panel
            obj.PanPlayRec = std_panel(obj.figMain, grid2pos([1,2,1,1,GridSize]),...
                {'Recording','Playback','Processing'});
            obj.PanPlayRec.Name = 'Playback and Recording';
            obj.PanPlayRec.Panel.Title = 'Playback and Recording';
            % Add panels
            obj.PanPlayRec.UI = rec_play_ui(obj);
            
            %% Create System Representation Panel
            % Plot of current source positions
            obj.PanRep = std_panel(obj.figMain, grid2pos([2,1,1,1,GridSize]));
            obj.PanRep.Name = 'System Representation';
            obj.PanRep.Panel.Title = 'System Representation';
            obj.PanRep.UI = sys_rep_ui(obj.PanRep.Panel,obj);
            
            %% Create Intelligibility Panel
            % Representation of signal quality
            obj.PanIntel = std_panel(obj.figMain, grid2pos([2,2,1,1,GridSize]));
            obj.PanIntel.Name = 'Intelligibility';
            obj.PanIntel.Panel.Title = 'Intelligibility';
            obj.PanRep.UI = intelligibility_ui(obj.PanIntel.Panel,obj);
            
            %% Create Plots Panel
            obj.PanPlots = std_panel(obj.figMain, grid2pos([3,1,2,2,GridSize]),...
                {'Audio Signals','Audio Window','Beampatterns'});
            obj.PanPlots.Name = 'Plots';
            obj.PanPlots.Panel.Title = 'Plots';
            %  Plot1
            obj.PanPlots.UI{1} = plot_audio_ui(obj.PanPlots.Tabs{1},obj.PanSettings.UI{2});
            obj.PanPlots.UI{2} = audio_window_ui(obj.PanPlots.Tabs{2},obj);
            
            
            %% Copy handles of BFCom and Mitm to this class
            obj.BFCom = obj.PanSettings.UI{1}.Smartphones.BFCom;
            obj.Mitm = obj.PanSettings.UI{1}.Smartphones.Mitm;
            obj.Directivity = obj.PanSettings.UI{4}.Directivity;
            obj.Channels = obj.PanSettings.UI{2};
            
            %% Place Main Window handle in workspace
            assignin('base','MainWindow',obj)
        end
        
        %% Close Request function
        function closeReq_Callback(obj,~,~)
            obj.figMain.HandleVisibility  = 'off';
            close all;
            obj.figMain.HandleVisibility  = 'on';
            % Possible to save gui state here
            delete(obj.figMain)
        end
    end
end