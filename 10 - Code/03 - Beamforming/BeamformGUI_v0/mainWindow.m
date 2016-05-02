function s = mainWindow
%Main window instantiator.
%   s = mainWindow returns a structure with the fields and handles
%       and creates a figure
%
%      Example:
%      s = mainWindow;

%   Copyright 2015 BabForming.

    disp('Main window instantiated');
    
    %% Create a fullscreen figure
    figSize = [0.00 0.05 1 1-0.05];         % size of the figure, normalized [left bottom width height]
    figMain = figure('name','Beamformer Main Window','NumberTitle','off','resize', 'on',...
        'units','normalized','outerposition',figSize);
    

    %% Fields
	s.figMain = figMain;
    
    %% Methods
	s.Pushb1 = @push1Callback;
	s.Pushb2 = @push2Callback;
    
    %% Nested Functions
    function s = push1Callback(g)
        s = g;
    end
end

%% Functions
function s = push2Callback(g)
    s = g;
end