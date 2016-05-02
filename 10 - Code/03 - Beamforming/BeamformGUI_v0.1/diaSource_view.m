function s = diaSource_view(figHandle)
%Opens a dialog to set the settings for the Source.
%   s = diaSource(handle) returns a structure with the fields and handles 
%       and has ui elements to manipulate them
%
%      Example:
%      f = figure;
%      s = diaSource_view(f);

%   Copyright 2015 BabForming.

    %% Import Constants
    c = consts;

    %% Graphics code
    % Create dialog
%     diaSour = dialog('Position',[300 0 500 600],'Name','Source Settings');
    % Buttongroup
    bgDiaType = uibuttongroup(diaSour,'Title','Type','Position',[c.sHor 1/2+2*c.sVer+c.butHeight 1-2*c.sHor 1/2-3*c.sVer-c.butHeight],'SelectionChangeFcn', @switchContent);
    % Radiobuttons
    rb1 = uicontrol(bgDiaType,'Style','radiobutton','String','Local',...
                'Units','normalized','Tag','local',...
                'Position',[.1 .7 .3 .2]);
    rb2 = uicontrol(bgDiaType,'Style','radiobutton','String','Wifi',...
                'Units','normalized','Tag','wifi',...
                'Position',[.1 .5 .3 .2]);
    rb3 = uicontrol(bgDiaType,'Style','radiobutton','String','Audio',...
                'Units','normalized','Tag','audio',...
                'Position',[.1 .3 .3 .2]);
    
    % Detailsgroup for local
    bgDiaDetLoc   = uipanel(diaSour,'Title','Local Details','Position',[c.sHor 2*c.sVer+c.butHeight 1-2*c.sHor 1/2-2*c.sVer],'Visible','off');
    % Detailsgroup for wifi
    bgDiaDetWifi  = uipanel(diaSour,'Title','Wifi Details' ,'Position',[c.sHor 2*c.sVer+c.butHeight 1-2*c.sHor 1/2-2*c.sVer],'Visible','off');
    % Detailsgroup for Audio
    bgDiaDetAudio = uipanel(diaSour,'Title','Audio Details','Position',[c.sHor 2*c.sVer+c.butHeight 1-2*c.sHor 1/2-2*c.sVer],'Visible','off');
    
    % Buttons on the downside of the dialog
    pbCan = uicontrol('Parent',diaSour,...
        'units', 'normalized',...
        'Position',[1-2*(c.sHor+c.butWidth) c.sVer c.butWidth c.butHeight],...
        'String','Cancel',...
        'Callback','delete(gcf)');
    pbSave = uicontrol('Parent',diaSour,...
        'units', 'normalized',...
        'Position',[1-1*c.sHor-c.butWidth c.sVer c.butWidth c.butHeight],...
        'String','Save',...
        'Callback',@pbSave_CB);
    
    
    
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