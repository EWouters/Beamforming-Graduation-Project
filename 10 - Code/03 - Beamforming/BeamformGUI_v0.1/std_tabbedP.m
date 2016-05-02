classdef std_tabbedP < std_panel
    %% Standard Tabbed Panel Class
    %  This class is an addition to the std_panel class. It has
    %  functionality to for multiple panels which can be in one panel with
    %  tabs. It can be filled with any graphical object
    
    %% Properties
    properties
    end
    %% Methods
    methods
        %% Constuctor
        function obj = std_tabbed(varargin)
            disp(varargin)
            % Number of tabs
            % cell with properties per tab
            obj@std_panel(varargin)
        end
    end
end