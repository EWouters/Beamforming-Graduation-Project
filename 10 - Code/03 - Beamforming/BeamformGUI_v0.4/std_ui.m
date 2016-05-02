% Standard UI Class.
%  Example1
%   obj = std_ui([],'UI_Name',{'el1','el2'},{[1,1,1,1,1,2],[1,2,1,1,1,2]},{'edit','text'},{{'String','Callback'},{'String','Callback'}},{{'sd1','disp(''hoi'')'},{'sd2','disp(''hoi2'')'}})
%  Example2
%   parent = []
%   name = 'std_ui'
%   tags = {'el1','el2'}
%   positions = {[0,0,1,1,1,2],[0,1,1,1,1,2]}
%   styles = {'edit','pushbutton'}
%   pns = {{'String','Callback'},{'String','Callback'}}
%   pvs = {{'sd1','disp(''hoi'')'},{'sd2','disp(''hoi2'')'}}
%   obj = std_ui(parent, name, tags, positions, styles, pns, pvs)

%   Callbacks need to be assigned to @obj.Parent.tagButton1_Callback

%   Copyright 2015 BabForming.

classdef std_ui < handle
%% Standard UI Class
    %  This class holds the gui elements for the standard panel
    %% Properties
    properties
        Parent              % Handle of parent
        Name = 'std_ui';    % Name of UI
        UI                  % Field with UI handles
        Callbacks           % Field with Callback handles
        Defaults
    end
    %% Methods
    methods
        %% UI Constuctor
        function obj = std_ui(parent, name, tags, positions, styles, pns, pvs, varargin)
            %% Parse Input
            % figure Handle
            if nargin == 0
                obj.Parent = figure('Name',obj.Name,'NumberTitle','off','resize','on');
            else
                if ishandle(parent)
                    obj.Parent = parent;
                else
                    warning('First argument needs to be a handle new figure created.');
                    obj.Parent = figure('Name',obj.Name,'NumberTitle','off','resize','on');
                end
            end
            % Name
            if nargin > 1
                if ischar(name); obj.Name = name; end
            end
            %% Graphics Code
            n = length(tags);
            if n == length(styles) && n == length(pns) && n == length(pvs) && n == length(positions)
                for ii = 1:n
                    obj.UI{ii} = uicontrol(obj.Parent,...
                        'Units','Normalized',...
                        'Position',grid2pos(positions{ii}),...
                        'Style',styles{ii},pns{ii},pvs{ii});
                end
            else
                error('Could not create ui. The lengths of ''positions'', ''styles'' and ''props'' need to be equal')
            end
            
        end
    end
end