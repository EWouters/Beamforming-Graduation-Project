function s = diaChannels(settings)
%Opens a dialog to set the settings for the channels.
%   s = diaChannels(settings) displays current settings 
%       and has ui elements to manipulate them
%
%      Example:
%      settings.f = 4;
%      s = diaChannels(settings);

%   Copyright 2015 BabForming.

    diaChan = dialog('Position',[300 300 250 150],'Name','Settings: Channels');
    txt = uicontrol('Parent',diaChannels,...
        'Style','text',...
        'Position',[20 80 210 40],...
        'String','Click the close button when you''re done.');
    btn = uicontrol('Parent',diaChannels,...
        'Position',[85 20 70 25],...
        'String','Close',...
        'Callback','delete(gcf)');
    
    %% Return settings
    s = settings;
end