function c = consts
%Object to hold a list of constants.
%   s = consts returns a structure with all constants as fields
%
%      Example:
%      c = consts.pi;

%   Copyright 2015 BabForming.

    %% Fields
    c.pi = pi();
    
    % GUI constants
    c.nHor = 4;                             % Horizontal grid size
    c.nVer = 2;                             % Vertical grid size                    
    c.maxC = [4,2];
    c.sHor = 1/100;                         % Space between horizontal items
    c.sVer = 1/100;                         % Space between vertical items
    c.butHeight = 1/10;                     % Height of a button
    c.butWidth = 1/3.5;                     % Width  of a button

end