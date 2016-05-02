function s = settings_view(figHandle, pos)
%Settings panel instantiator.
%   s = settings_view returns a structure with the fields and handles
%       and creates gui elements
%
%      Example:
%      f = figure;
%      s = settingsPanel(f);

%   Copyright 2015 BabForming.

    disp('Settings panel instantiated');

    %% Import constants
    c = consts;
    
    %% Create a Panel and add some buttons
    %   [left bottom width height]
%     figHandle = figure;pos = [c.sHor 1-c.sVer-1/c.nVer 1/c.nHor-c.sHor 1/c.nVer]
    panSettings = uipanel(figHandle,'Title','Settings','Position',pos);
    pbSource = uicontrol(panSettings,'Style','pushbutton','String','Source',...
        'Units','normalized',...
        'Position',[c.sHor 1-1*(c.sVer+c.butHeight) c.butWidth c.butHeight],...
        'Callback',@pbSource_Callback);
    pbChannels = uicontrol(panSettings,'Style','pushbutton','String','Channels',...
        'Units','normalized',...
        'Position',[c.sHor 1-2*(c.sVer+c.butHeight) c.butWidth c.butHeight],...
        'Callback',@pbChannels_Callback);
    pbLocalization = uicontrol(panSettings,'Style','pushbutton','String','Localization',...
        'Units','normalized',...
        'Position',[c.sHor 1-3*(c.sVer+c.butHeight) c.butWidth c.butHeight],...
        'Callback',@pbLocalization_Callback);
    pbBeamformers = uicontrol(panSettings,'Style','pushbutton','String','Beamformers',...
        'Units','normalized',...
        'Position',[c.sHor 1-4*(c.sVer+c.butHeight) c.butWidth c.butHeight],...
        'Callback',@pbBeamformers_Callback);
    pbIntelligibility = uicontrol(panSettings,'Style','pushbutton','String','Intelligibility',...
        'Units','normalized',...
        'Position',[c.sHor 1-5*(c.sVer+c.butHeight) c.butWidth c.butHeight],...
        'Callback',@pbIntelligibility_Callback);
    pbRecord = uicontrol(panSettings,'Style','pushbutton','String','Record Audio',...
        'Units','normalized',...
        'Position',[c.sHor 1-6*(c.sVer+c.butHeight) c.butWidth c.butHeight],...
        'Callback',@pbRecord_Callback);
    pbSaveLoad = uicontrol(panSettings,'Style','pushbutton','String','Save/Load',...
        'Units','normalized',...
        'Position',[c.sHor 1-6*(c.sVer+c.butHeight) c.butWidth c.butHeight],...
        'Callback',@pbSaveLoad_Callback);
    

    %% Fields
	s.panSettings = panSettings;
    s.pbSource = pbSource;
    s.pbChannels = pbChannels;
    s.pbLocalization = pbLocalization;
    s.pbBeamformers = pbBeamformers;
    s.pbIntelligibility = pbIntelligibility;
    s.pbRecord = pbRecord;
    s.pbSaveLoad = pbSaveLoad;
    
    %% Methods
    s.pbSource_CB = @pbSource_Callback;
    s.pbChannels_CB = @pbChannels_Callback;
    s.pbLocalization_CB = @pbLocalization_Callback;
    s.pbBeamformers_CB = @pbBeamformers_Callback;
    s.pbIntelligibility_CB = @pbIntelligibility_Callback;
    s.pbRecord_CB = @pbRecord_Callback;
    s.pbSaveLoad_CB = @pbSaveLoad_Callback;
    
    %% Nested Functions
    function pbSource_Callback(~,~)
        disp('pb Source pressed');
        set(s.panSettings,'Title','Edit the Title') 
    end
    function pbChannels_Callback(~,~)
        disp('pb Channels pressed');
    end
    function pbLocalization_Callback(~,~)
        disp('pb Localization pressed');
    end
    function pbBeamformers_Callback(~,~)
        disp('pb Beamformers pressed');
    end
    function pbIntelligibility_Callback(~,~)
        disp('pb Intelligibility pressed');
    end
    function pbRecord_Callback(~,~)
        disp('pb Record pressed');
    end
    function pbSaveLoad_Callback(~,~)
        disp('pb SaveLoad pressed');
    end
end

%% Functions