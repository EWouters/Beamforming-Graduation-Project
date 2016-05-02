classdef main_window < handle
% MAIN_WINDOW  Beamforming main window.
%   obj = MAIN_WINDOW(A) Start Beamforming main window.
%
%   This class is a main gui window generator.
%
%   Beamformer scripts:
%   DSB_BF.m                Delay-Sum-Beamformer.
%   MVDR_BF.m               Minimum variance distortionless response Beamformer.
%   MVDR_Directivity_BF.m   MVDR Beamformer with microphone Directivity.
%   Delft_BF.m              Delft Beamformer algorithm.                        TODO
%
%   Quality estimation scripts:
%   pesq.m
%
%   Communication Classes:
%   bfcom.m                 Communication class for beamformers.
%   mitm.m                  Communication class for the Smartphone App.
%
%   User Interface Classes:
%   main_window.m           Start Beamforming main window.
%   
%   
%   Written for the BSc graduation project Acoustic Enhancement via
%   Beamforming Using Smartphones.  
%
%   Team:           S. Bosma                R. Brinkman
%                   T. de Rooij             R. Smeding
%                   N. van Wijngaarden      E. Wouters
%
%   Supervisor:     Jorge Martínez Castañeda
%   TODO: add other supervisors
%
%   Contact: E.H.Wouters@student.tudelft.nl
%
%   See also MITM, BFCOM, STD_PANEL, BFDSB, SMARTPHONE_SETTINGS_UI.
    
    %% Properties
    properties (Constant)
        % Constants
        Name = 'Beamformer Main Window'
    end
    properties
        % Properties
        figMain             % Main figure handle.
        UI                  % Holds handles to user elements
        Microphones         % Handle of class to configure the microphone array
        SysRep              % Handle of class to which holds all positions and orientations
        Channels            % Handle of class to map 
        Speakers            % Handle of class to configure the Speakers
        Simulation          % Handle of class to estimate the signal that the microphones sould pick up
        Directivity         % Handle of class to load the directivity measurements for the microphones
        Beamformers         % Handle of class to configure the beamformers 
        PlayRec             % 
        Intelligibility     % Handle of class to configure intelligibility
        PlotAudio           % Handle of class to plot the whole audio signal
        Window              % Handle of class to plot a window of the data
        Smartphones         % Handle of class to manage connections to the smartphones
        Mitm                % Handle of class to manage the server for smartphones
        BFCom               % Handle of class to manage the callbacks from smartphones
    end
    %% Methods
    methods
        % Main GUI Window Constuctor
        function obj = main_window(varargin)
            try close all; catch; end % Try to close all other windows
            % Create figure
            obj.figMain = figure('name',obj.Name,'NumberTitle','off','resize', 'on',...
                'units','normalized','outerposition',[0.00 0.05 1 1-0.05],...
                'CloseRequestFcn',@obj.closeReq_Callback);
            GridSize = [4,2]; % Set grid size
            % Create Settings Panel
            obj.UI.Settings = std_panel(obj.figMain, grid2pos([1,1,1,1,GridSize]),...
                {'Microphones','Channel Mapping','Speakers','Beamformers',...
                'Directivity'});
            obj.UI.Settings.Name = 'Settings';
            obj.UI.Settings.Panel.Title = 'Settings';
            % Add panels
            obj.Microphones = microphone_settings_ui(obj.UI.Settings.Tabs{1},obj);
            obj.Channels = chan_map_ui(obj.UI.Settings.Tabs{2},obj);
            obj.Speakers = speakers_ui(obj.UI.Settings.Tabs{3},obj);
            obj.Beamformers = beamformers_ui(obj.UI.Settings.Tabs{4},obj);
            obj.Directivity = directivity_ui(obj.UI.Settings.Tabs{5},obj);
            
            %% Create Playback and Recording Panel
            obj.UI.PlayRec = std_panel(obj.figMain, grid2pos([1,2,1,1,GridSize]));
            obj.UI.PlayRec.Name = 'Playback and Recording';
            obj.UI.PlayRec.Panel.Title = 'Playback and Recording';
            % Add panel
            obj.PlayRec = rec_play_ui(obj.UI.PlayRec.Panel,obj);
            
            %% Create System Representation Panel
            % Plot of current source positions
            obj.UI.Rep = std_panel(obj.figMain, grid2pos([2,1,1,1,GridSize]));
            obj.UI.Rep.Name = 'System Representation';
            obj.UI.Rep.Panel.Title = 'System Representation';
            obj.SysRep = sys_rep_ui(obj.UI.Rep.Panel,obj);
            
            %% Create Intelligibility Panel
            % Representation of signal quality
            obj.UI.Intel = std_panel(obj.figMain, grid2pos([2,2,1,1,GridSize]));
            obj.UI.Intel.Name = 'Intelligibility';
            obj.UI.Intel.Panel.Title = 'Intelligibility';
            obj.Intelligibility = intelligibility_ui(obj.UI.Intel.Panel,obj);
            
            %% Create Plots Panel
            obj.UI.Plots = std_panel(obj.figMain, grid2pos([3,1,2,2,GridSize]),...
                {'Audio Signals','Audio Window','Beampatterns'});
            obj.UI.Plots.Name = 'Plots';
            obj.UI.Plots.Panel.Title = 'Plots';
            %  Plot1
            obj.PlotAudio = plot_audio_ui(obj.UI.Plots.Tabs{1},obj);
            obj.Window = audio_window_ui(obj.UI.Plots.Tabs{2},obj);
            
            
            %% Copy handles of BFCom and Mitm to this class
            obj.Smartphones = obj.Microphones.Smartphones;
            obj.BFCom = obj.Smartphones.BFCom;
            obj.Mitm = obj.Smartphones.Mitm;
            
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