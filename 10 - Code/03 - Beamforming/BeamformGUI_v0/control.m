function mw1 = control
%Control function of model. Loads GUI and more...
%   
%
%      Example:
%      control;

%   Copyright 2015 BabForming.

    %% Load GUI
    mw1 = mainWindow;
    mw1.sp1 = settingsPanel(mw1.figMain);
    
%     set(mw1.sp1.panSettings,'Title','Edit the Title')
%     mw1.sp1.pbSource_CB();
    
    disp('GUI Loaded')
    
    %% End of program
    disp('Control Finished')
    disp(mw1)
end