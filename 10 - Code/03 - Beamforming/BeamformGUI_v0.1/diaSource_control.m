function s = diaSource_control(settings)
%Opens a dialog to set the settings for the Source.
%   s = diaSource(settings) displays current settings 
%       and has ui elements to manipulate them
%
%      Example:
%     settings.type = 'local';
%     settings.local.fileName = 'Example.wav';
%     settings.local.pathName = 'D:\android-beamforming\10 - Code\03 - Beamforming\BeamformGUI_v1\';
%     s = diaSource(settings);

%   Copyright 2015 BabForming.

    %% Import Constants
    c = consts;

    %% Default settings
    defaults.type = 'local';
    defaults.local.fileName = 'Example.wav';
    defaults.local.pathName = 'D:\android-beamforming\10 - Code\03 - Beamforming\BeamformGUI_v1\';
    defaults.wifi.numDevices = 2;
    defaults.wifi.IP = [ 192, 168, 1, 1;...
                         192, 168, 1, 2];
    defaults.wifi.connected = [0, 0];
    defaults.audio.comport = 12;
    defaults.audio.numChannels = 2;
    
    %% Check whether the settings argument has correct structure (not water proof)
    if ~isstruct(settings) || ~isfield(settings,'type') || ~isfield(settings,settings.type)
        disp('Invalid settings for Source:'); disp(settings); disp('Loading defaults');
        settings = defaults;
%         s.type = defaults.type;
%         s.details = defaults.(defaults.type);
    end
    s = settings;


    
    
%                 [fileName, pathName] = ...
%                     uigetfile({'*.wav','Waveform Audio File Format (*.wav)';...
%                     '*.mat','MAT-files (*.mat)'; ...
%                     '*.*','All Files (*.*)';...
%                     },'Select source audio file');
%                 details.fileName = fileName;
%                 details.pathName = pathName;
                
                
                
    %% Load settings to dialog
    switch settings.type
        case 'local'
            set(bgDiaDetLoc  ,'Visible','On' ); set(rb1,'Value',1);
            set(bgDiaDetWifi ,'Visible','Off'); set(rb2,'Value',0);
            set(bgDiaDetAudio,'Visible','Off'); set(rb3,'Value',0);
        case 'wifi'
            set(bgDiaDetLoc  ,'Visible','Off'); set(rb1,'Value',0);
            set(bgDiaDetWifi ,'Visible','On' ); set(rb2,'Value',1);
            set(bgDiaDetAudio,'Visible','Off'); set(rb3,'Value',0);
        case 'audio'
            set(bgDiaDetLoc  ,'Visible','Off'); set(rb1,'Value',0);
            set(bgDiaDetWifi ,'Visible','Off'); set(rb2,'Value',0);
            set(bgDiaDetAudio,'Visible','On' ); set(rb3,'Value',1);
    end
    
    %% Nested Functions
    % pbSave Callback
    function pbSave_CB(~,~)
        % Put all information into s struct
        s.type = get(get(bgDiaType,'SelectedObject'),'Tag');
        
        % TODO
        s.local.fileName = 'Example.wav';
        s.local.pathName = 'D:\android-beamforming\10 - Code\03 - Beamforming\BeamformGUI_v1\';
        s.wifi.numDevices = 2;
        s.wifi.IP = [ 192, 168, 1, 1;...
                      192, 168, 1, 2];
        s.wifi.connected = [0, 0];
        s.audio.comport = 12;
        s.audio.numChannels = 2;
        % Close figure
        delete(gcf);
    end
    
    function switchContent(~,~)
        % switch to applicable content
        settings.type = get(get(bgDiaType,'SelectedObject'),'Tag');
        switch settings.type
            case 'local'
                set(bgDiaDetLoc  ,'Visible','On' );
                set(bgDiaDetWifi ,'Visible','Off');
                set(bgDiaDetAudio,'Visible','Off');
            case 'wifi'
                set(bgDiaDetLoc  ,'Visible','Off');
                set(bgDiaDetWifi ,'Visible','On' );
                set(bgDiaDetAudio,'Visible','Off');
            case 'audio'
                set(bgDiaDetLoc  ,'Visible','Off');
                set(bgDiaDetWifi ,'Visible','Off');
                set(bgDiaDetAudio,'Visible','On' );
        end
    end
end