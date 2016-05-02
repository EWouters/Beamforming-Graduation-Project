function s = settings_control(figHandle,)
%Settings panel control.
%   s = settings_control returns a structure with the fields and handles
%       and creates a panel
%
%      Example:
%      f = figure;
%      s = settings_control(f);

%   Copyright 2015 BabForming.

    %% Import constants
    c = consts;

    %% Fields
	s.panSettings = panSettings;
    s.pbSource = pbSource;
    s.pbChannels = pbChannels;
    s.pbLocalization = pbLocalization;
    s.pbBeamformers = pbBeamformers;
    s.pbIntelligibility = pbIntelligibility;
    
    %% Methods
    s.pbSource_CB = @pbSource_Callback;
    s.pbChannels_CB = @pbChannels_Callback;
    s.pbLocalization_CB = @pbLocalization_Callback;
    s.pbBeamformers_CB = @pbBeamformers_Callback;
    s.pbIntelligibility_CB = @pbIntelligibility_Callback;
    
    %% Nested Functions
    
end

%% Functions