classdef std_window
%% Standard Window Class
    %  This class is a standard gui window generator
    %% Constants
    properties (Constant)
%         Consts1 = consts;	% Constant property from another class
    end
    %% Properties
    properties
        figMain
        GridSize = [1,2];          % Size of grid
        Pan1
        Pan2
    end
    %% Methods
    methods
        %% Standard Window Constuctor
        function obj = std_window(varargin)
            % Create figure
            obj.figMain = figure('name','Beamformer Main Window','NumberTitle','off','resize', 'on',...
                'units','normalized','outerposition',[0.00 0.05 1 1-0.05]);
            
            if nargin
                if numel(varargin{1}) == 2
                    obj.GridSize = varargin{1};
                else
                    warning('Gridsize invalid: %s',mat2str(varargin{1}));
                end
            end
            if nargin > 1
                if ishandle(varargin{2})
                    obj.Pan1 = varargin{2};
                else
                    warning('First panel invalid: %s',mat2str(varargin{2}));
                    obj.Pan1 = std_panel(obj.figMain, grid2pos([1,1,1,1,obj.GridSize]));
                end
            else
                obj.Pan1 = std_panel(obj.figMain, grid2pos([1,1,1,1,obj.GridSize]));
            end
            if nargin > 2
                if ishandle(varargin{3})
                    obj.Pan2 = varargin{3};
                else
                    warning('First panel invalid: %s',mat2str(varargin{2}));
                    obj.Pan2 = std_panel(obj.figMain, grid2pos([1,2,1,1,obj.GridSize]), 5,'Title','Standard Panel');
                end
            else
                obj.Pan2 = std_panel(obj.figMain, grid2pos([1,2,1,1,obj.GridSize]), 5,'Title','Standard Panel');
            end
        end
    end
end