%% Localization UI Class
%  Example:
%   f = figure
%   obj = plot1_ui(f)

%   Copyright 2015 BabForming.

classdef plot1_ui < handle
%% Panel Localization Class
    %  This class holds the gui elements for the plot1 panel
    %% Properties
    properties
        Parent              % Handle of parent
        Settings            % Settings struct
        Name = 'Localization'; % Name of UI
        Axes1               % Handle of axis
        Surf1               % Hanlde of plot
        Defaults
    end
    %% Methods
    methods
        %% Localization Constuctor
        function obj = plot1_ui(varargin)
            % Defaults
            obj.Defaults.test = 'test1';
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
                warning('Default settings used for plot1_ui')
                obj.Settings = obj.Defaults;
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
