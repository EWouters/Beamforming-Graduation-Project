function handles = tab_view(varargin)

%% Example 1
% tabExample = tab_view
% tabExample.panel.Title = 'This is the title';
%% Example 2
% f = figure
% panExample(1) = standard_view(f, [[0,0],[1,1]])
% panExample(2) = standard_view(f, [[1,0],[1,1]])
% panExample(1).panel.Title = 'This is the title';
%% Example 2
% f = figure
% panExample(1) = standard_view(f, [[0,0],[1,1],[2,1],1,1])
% panExample(2) = standard_view(f, [[1,0],[1,1],[2,1],1,1])
% panExample(1).panel.Title = 'This is the title';
%% Example 3
% f = figure;panExample1 = standard_view(f, [[0,0],[1,1],[2,1],1]);panExample2 = standard_view(f, [[1,0],[1,1],[2,1],1]);panExample1.panel.Title = 'This is the title';


    %% Import constants
    c = consts;
    
    %% Parse input
    % figure Handle
    if nargin == 0
        handles.defParent = figure;
    elseif ishandle(varargin{1})
        handles.defParent = varargin{1};
    else
        error('First argument needs to be a handle');
    end
    if nargin > 1
        if isscalar(varargin{2})
            handles.nOfTabs = varargin{2};
        else
            warning('Invalid number of tabs argument')
            handles.nOfTabs = 1;
        end
    else
        handles.nOfTabs = 1;
    end
    if nargin > 2
        if strcmp(varargin{3},'bottom')
            handles.tabPos = 0;
        else
            handles.tabPos = 1;
        end
    else
        handles.tabPos = 0;
    end
    
    % Position
    handles.defPos = grid2pos([0,0],[1,1],[1,1]);
    handles.viewPos = grid2pos([0,0],[1,1],[1,1],handles.tabPos);
    
    %% Graphics code
    handles.tabs = uibuttongroup('Parent',handles.defParent,'Position', handles.defPos, 'SelectionChangedFcn',@tabs_Callback, varargin{3:end});
    ind = 1; tot = 1;
    handles.buts(ind) = uicontrol('Parent',handles.tabs,'Style','ToggleButton',...
        'Units','normalized','Position',but2gridPos(ind,tot,handles.tabPos));
    handles.view
    
    %% Nested Functions
    function addTab(viewHandle)
        handles.buts(end+1) = uicontrol('Parent',viewHandle,'Style','ToggleButton',...
            'Units','normalized','String',viewHandle.Name,...
            'Position',but2gridPos(length(handles.buts)+1,length(handles.buts)+1,handles.tabPos));
    end

    handles.addTab = @addTab;
end