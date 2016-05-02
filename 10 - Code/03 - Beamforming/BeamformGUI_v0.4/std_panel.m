% Standard Panel Class.
%  Example1
%   obj = std_panel;
%  Example2
%   Parent = figure;
%   Grid = [0,0, 1,1, 1,1];
%   numberOfTabs = 5;
%   obj = std_panel(Parent, Grid, numberOfTabs,'Title','Standard Panel');

%   Copyright 2015 BabForming.



classdef std_panel < handle
    %% Standard Panel Class
    %  This class is basically an addition to the panel class. It has
    %  functionallity to pop panels out to their own figure and pop them
    %  back to a main window. It can be filled with any graphical object
    %  Also multiple panels can be in one panel with tabs
    
    %% Constants
    properties (Constant)
        sHor = 1/100;                         % Space between horizontal items
        sVer = 1/100;                         % Space between vertical items
        butHeight = 1/10;                     % Height of a button
        butWidth = 1/3.5;                     % Width of a button
    end
    %% Properties
    properties
        Panel               % Handle of panel(s)
        Parent              % Handle of parent
        PopParent           % Handle of parent figure when popped
        Position = grid2pos([]); % Position of panel
        numberOfTabs = 1;   % Number of tabs
        Name = 'Name';      % Name of panel
        TabNames = 'Tab 1';
        TabGroup1           % Tab Group in default parent
        TabGroup2           % Tab Group in pop parent
        Tabs
        UI
        Tag
        PbPop               % Push Button to pop out (and back in case of single tab)
        PbPopBack           % Push Button to pop back
        PbGetBack           % Push Button to pop back
        PopButPos           % Position of Push button
    end
    %% Methods
    methods
        %% Constuctor
        function obj = std_panel(varargin)
            obj.PopButPos = [1-obj.sHor-obj.butHeight/2 1-1*(obj.sVer+obj.butHeight)/4 obj.butHeight/2 obj.butHeight/4];
            %% Parse input
            % figure Handle
            if nargin == 0
                obj.Parent = figure('Name',obj.Name,'NumberTitle','off','resize', 'on');
            else
                if ishandle(varargin{1})
                    obj.Parent = varargin{1};
                else
                    warning(['First argument needs to be a handle,'...
                        'new figure created.']);
                    obj.Parent = figure('Name',obj.Name, 'NumberTitle','off',...
                        'resize', 'on', 'Tag','std panel figure');
                end
            end
            % grid position
            if nargin >= 2
                obj.Position = varargin{2};
            end
            % tabs
            if nargin >= 3
                if isnumeric(varargin{3}) && numel(varargin{3}) == 1 ...
                        && varargin{3} > 0
                    obj.numberOfTabs = varargin{3};
                    for ii = 1:obj.numberOfTabs
                        obj.TabNames{ii} = sprintf('Tab %i',ii);
                    end
                elseif ischar(varargin{3}) || iscellstr(varargin{3})
                    obj.numberOfTabs = length(varargin{3});
                    obj.TabNames = varargin{3};
                end
            end
            
            %% Graphics code
            obj.Panel = uipanel('Parent',obj.Parent,'Position', obj.Position, varargin{4:end});
            if obj.numberOfTabs > 1
                obj.TabGroup1 = uitabgroup('Parent',obj.Panel);
                for ii = 1:obj.numberOfTabs
                    obj.Tabs{ii} = uitab(obj.TabGroup1, 'Title', obj.TabNames{ii});
                end
            end
%             PopUIMenu = uicontextmenu('Parent',obj.Panel);
%             PopMenu = uimenu('Parent',obj.Panel,'Label','Pop Out');
            obj.PbPop = uicontrol(obj.Panel,'Style','pushbutton','String','^',...
                'Units','normalized','Callback',@obj.pbPop_Callback,...
                'Position',obj.PopButPos,'FontWeight','bold');
            
            
%             assignin('base','obj',obj)
        end
        %% Pop out function
        function pbPop_Callback(obj,~,~)
            if obj.numberOfTabs == 1
                % Single Tab
                if strcmp(obj.PbPop.String,'^')
                    obj.PbPop.String = '~';
                    obj.Parent = obj.Panel.Parent;
                    obj.PopParent = figure('CloseRequestFcn',@obj.pbPop_Callback,...
                        'Name',obj.Name,'NumberTitle','off','resize', 'on',...
                        'Tag','pop figure');
                    obj.Panel.Parent = obj.PopParent;
                    obj.Panel.Position = grid2pos([]);
                else
                    obj.PbPop.String = '^';
                    obj.Panel.Parent = obj.Parent;
                    obj.Panel.Position = obj.Position;
                    delete(obj.PopParent);
                end
            else
                % Multiple Tabs
                if isempty(obj.PopParent)
                    obj.PopParent = figure('CloseRequestFcn',@obj.closeReq_Callback,...
                        'Name',obj.Name,'NumberTitle','off','resize', 'on');
                    obj.TabGroup2 = uitabgroup('Parent',obj.PopParent);
                    obj.PbPopBack = uicontrol(obj.PopParent,'Style','pushbutton','String','~',...
                        'Units','normalized','Callback',@obj.pbPopBack_Callback,...
                        'Position',obj.PopButPos);
                end
                obj.TabGroup1.SelectedTab.Parent = obj.TabGroup2;
                if isempty(obj.TabGroup1.Children)
                    obj.PbGetBack = uicontrol(obj.Parent,'Style','pushbutton','String','Get Tabs back',...
                        'Units','normalized','Callback',@obj.closeReq_Callback,...
                        'Position',(obj.Panel.Position+[0.001,0.001,-0.002,-0.002]).*[1 1 1 0.975],...
                        'BackgroundColor',get(obj.Parent,'Color'));
                end
            end
        end
        
        %% Pop back function
        function pbPopBack_Callback(obj,~,~)
            obj.TabGroup2.SelectedTab.Parent = obj.TabGroup1;
            delete(obj.PbGetBack)
            if isempty(obj.TabGroup2.Children)
                delete(obj.PopParent);
                obj.TabGroup1.SelectedTab = obj.TabGroup1.Children(end);
                obj.PopParent = [];
            end
        end
        
        %% Close Request function
        function closeReq_Callback(obj,~,~)
            delete(obj.PbGetBack)
            while ~isempty(obj.TabGroup2.Children)
                obj.TabGroup2.SelectedTab.Parent = obj.TabGroup1;
            end
            delete(obj.PopParent);
            obj.TabGroup1.SelectedTab = obj.TabGroup1.Children(end);
            obj.PopParent = [];
        end
    end
end
