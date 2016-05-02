%BKSTEP
%   This function provides an interface between Matlab and the 
%   Bruel & Kjaerl Type 9640 turntable. A connection via GPIB is made
%   and commands are sent to the BK5997 controller.
%
%   List of valid commands:
%   [error, value] = bkstep('init');            
%       initializes the controller
%       value = 0
%
%   [error, value] = bkstep('set zero');
%       resets the zero angle
%       value = 0
%
%   [error, value] = bkstep('acceleration',x);
%       set the acceleration to x = [1,2,...,9,10]
%       value = x
%
%   [error, value] = bkstep('max 360',x);
%       limits the turntable to a maximum turn of 360 degrees
%       to prevent cable problems etc.
%       x == 0 -> off, x == 1 -> on
%       value = x
%
%   [error, value] = bkstep('turn relative',x);
%       turns the turntable x (-360<x<360) degrees
%       relative to the current position
%       value = x (corrected if necessary)
%
%   [error, value] = bkstep('turn absolute',x);
%       turns the turntable to x (0<=x<360) degrees
%       value = x (corrected if necessary)
%
%   [error, value] = bkstep('turn continuous',x,y);
%       turns the turntable with a speed of x seconds/revolution
%       where -720.0<x<-22.7 or 22.7<x<720.0
%       y == 0 -> off, y == 1 -> on
%       on:     value = x (corrected if necessary)
%       off:    value = 0
%
%   Example:
%   bkstep('init');                 % init turntable system
%   bkstep('set zero');             % set zero reference
%   bkstep('acceleration',3);       % set acceleration to 3
%   bkstep('turn relative',98);     % turn 98 degrees clockwise
%   bkstep('turn relative',-22);    % turn 22 degrees anticlockwise
%   bkstep('turn absolute',0);      % return to 0 degrees
%
%   Possible error values:
%   error == 0:     no error
%   error == 1:     command not recognized
%   error == 2:     could not connect to turntable controller
%   error == 3:     turntable timeout/turntable did not stop 
%                   after relative turn
%
%   Marcel Korver
%   (demarcellus(at)gmail(dot)com)

%%%% Tim:
% C-code omzetten m.b.v. mex. Check dit:
% http://nl.mathworks.com/help/matlab/ref/mex.html?refresh=true 

% Foutmelding:
% na invoeren 'mex bkstep.c'
% Error using mex
% No supported compiler or SDK was found.
% For options, visit 
% http://www.mathworks.com/support/compilers/R2014a/win64.