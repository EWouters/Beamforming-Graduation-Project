function s = consts
%Object to hold a list of constants.
%   s = consts returns a structure with all constants as fields
%
%      Example:
%      s = consts.pi;

%   Copyright 2015 BabForming.

    %% Fields
    s.pi = pi();
    
    % GUI constants
    s.nHor = 4;                             % Horizontal grid size
    s.nVer = 2;                             % Vertical grid size                    
    s.sHor = 1/100;                         % Space between horizontal items
    s.sVer = 1/100;                         % Space between vertical items
    s.butHeight = 1/10;                     % Height of a button
    s.butWidth = 1/3.5;                     % Width  of a button

end