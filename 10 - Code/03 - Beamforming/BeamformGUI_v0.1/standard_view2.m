classdef standard_view < handle
    %% Example 1
    %  panExample = standard_view
    %  panExample.panel.Title = 'This is the title';
    %% Example 2
    %  f = figure
    %  panExample(1) = standard_view(f, [[0,0],[1,1]])
    %  panExample(2) = standard_view(f, [[1,0],[1,1]])
    %  panExample(1).panel.Title = 'This is the title';
    %% Example 2
    %  f = figure
    %  panExample(1) = standard_view(f, [[0,0],[1,1],[2,1],1,1])
    %  panExample(2) = standard_view(f, [[1,0],[1,1],[2,1],1,1])
    %  panExample(1).panel.Title = 'This is the title';
    %% Example 3
    %  f = figure;panExample1 = standard_view(f, [[0,0],[1,1],[2,1],1]);panExample2 = standard_view(f, [[1,0],[1,1],[2,1],1]);panExample1.panel.Title = 'This is the title';

    %% Properties
    properties
        defaults            % Default settings
        defParent           % Default parent handle
        defPos              % Default position
        Panel               % Panel handle
        Name                % Name of panel
    end
    
    %% Methods
    methods
        %% Constructor
        function obj = standard_view(varargin)
            %% Parse input
            % figure Handle
            if nargin == 0
                obj.defParent = figure(...
                'Name',obj.Name,'NumberTitle','off','resize', 'on');
            elseif ishandle(varargin{1})
                obj.defParent = varargin{1};
            else
                warning('First argument needs to be a handle');
            end
            % grid position
            if nargin >= 1
                obj.defPos = [0,0,1,1,1,1,0,0];
                s = numel(varargin{2});
                if isnumeric(varargin{2}) && any(s==[2 4 6 7 8])
                    obj.defPos(1:s) = varargin{2}(1:s);
                else
                    warning(['Second argument must be numeric ',...
                            'and must have 2,4,6,7 or 8 elements']);
                end
            end
            
            %% Graphics code
            obj.Panel = uipanel('Parent',obj.defParent,'Position', obj.defPos, varargin{3:end});
            obj.Panel.pbPop = uicontrol(obj.Panel,'Style','pushbutton','String','Pop out',...
                'Units','normalized',...
                'Position',[1-c.sHor-c.butWidth/2 1-1*(c.sVer+c.butHeight/2) c.butWidth/2 c.butHeight/2],...
                'Callback',@pbPop_Callback);
            obj.pop = @pbPop_Callback;  % return handle to pop action
            obj.Name = 'Name';
        end
    end
end

    %% Import constants
    c = consts;
    

    % Position
    if nargin < 2
        obj.defPos = grid2pos([0,0],[1,1],[1,1]);
    else
        if numel(varargin{2}) >= 4
            startC = varargin{2}(1:2);
            sizeC = varargin{2}(3:4);
        else
            startC = [0,0];
            sizeC = [1,1];
        end
        if numel(varargin{2}) >= 6
            maxC = varargin{2}(5:6);
        else
            maxC = [1,1];
        end
        if numel(varargin{2}) > 6
            args = varargin{2}(7:end);
        else
            args = {};
        end
        obj.defPos = grid2pos(startC, sizeC, maxC, args);
    end
    

    
    %% Pop out logic
    function pbPop_Callback(~,~)
        if strcmp(obj.pbPop.String,'Pop out')
            obj.pbPop.String = 'Pop back';
            obj.defParent = obj.Panel.Parent;
            obj.popParent = figure('CloseRequestFcn','warning(''Please Pop back into main window'')',...
                'Name',obj.Name,'NumberTitle','off','resize', 'on');
            obj.Panel.Parent = obj.popParent;
            obj.Panel.Position = grid2pos([0,0],[1,1],[1,1]);
%             obj.pbRetrieve = uicontrol(obj.defParent,'Style','pushbutton','String','Retrieve window',...
%                 'Units','normalized',...
%                 'Position',[1-c.sHor-c.butWidth/2 1-1*(c.sVer+c.butHeight/2) c.butWidth/2 c.butHeight/2],...
%                 'Callback','obj.pop()');
        else
            obj.pbPop.String = 'Pop out';
            obj.Panel.Parent = obj.defParent;
            obj.Panel.Position = obj.defPos;
            delete(obj.popParent);
%             obj = rmfield(obj,'pbRetrieve');
        end
    end
    
%     %% Check if window is docked
%     figHandle = gcf;
%     if figHandle.WindowStyle == 'docked'
%         disp('booo')
%     end
    
    
end