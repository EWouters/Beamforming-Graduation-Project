classdef std_tabbedPanel < std_panel
    %% Standard Tabbed Panel Class
    %  This class is an addition to the std_panel class. It has
    %  functionality to for multiple panels which can be in one panel with
    %  tabs. It can be filled with any graphical object
    
    %% Properties
    properties
        Panel           % Handle of main panel
        Parent          % Handle of parent
        PopParent
        Position        % Position of panel
        Name = 'Name'   % Name of panel
        PbPop           % Push Button to pop out
        pop
    end
    %% Methods
    methods
        %% Constuctor
        function obj = std_tabbed(varargin)
            % Number of tabs
            % cell with properties per tab
            obj@std_panel(varargin)
        end
    end
end