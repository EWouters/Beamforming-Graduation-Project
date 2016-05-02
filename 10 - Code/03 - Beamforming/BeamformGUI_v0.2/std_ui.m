% Standard UI Class.
%  Example1
%   obj = std_ui
%  Example2
%   Parent = figure
%   obj = std_ui(Parent)

%   Copyright 2015 BabForming.

classdef std_ui < handle
%% Standard UI Class
    %  This class holds the gui elements for the standard panel
    %% Properties
    properties
        Parent              % Handle of parent
        Settings            % Settings struct
        Name = 'std_ui';    % Name of UI
        Axes1               % Handle of axis
        Surf1               % Hanlde of plot
        Defaults
    end
    %% Methods
    methods
        %% UI Constuctor
        function obj = std_ui(varargin)
            %% Defaults
            obj.Defaults.Str = 'This is the default string';
            obj.Defaults.test = 'test1';
            %% Parse Input
            % figure Handle
            if nargin == 0
                obj.Parent = figure('Name',obj.Name,'NumberTitle','off','resize','on');
            else
                if ishandle(varargin{1})
                    obj.Parent = varargin{1};
                else
                    warning(['First argument needs to be a handle,'...
                        'new figure created.']);
                    obj.Parent = figure('Name',obj.Name,'NumberTitle','off','resize','on');
                end
            end
            % Try to set settings
            try
                obj.Settings = varargin{2};
            catch
                warning('Default settings used for std_ui')
                obj.Settings = obj.Defaults;
            end
            % Name
            if nargin > 2
                if ischar(varargin{3})
                    obj.Name = varargin{3};
                end
            end
            
            %% Graphics Code
            [x,y] = meshgrid(1:30,1:30);
            tri = delaunay(x,y);
            z = peaks(30);
            obj.Axes1 = axes('Parent',obj.Parent);
            obj.Surf1 = trisurf(tri,x,y,z,'Parent',obj.Axes1,'FaceLighting','phong');
        end
    end
end