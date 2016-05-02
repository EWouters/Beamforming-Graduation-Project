function pos = grid2pos(startC, sizeC, maxC, varargin)
    % Function to calculate normalized positions on Grid
    %% Example 1
    %   figure
    %   uipanel('Position', grid2pos([1,0], [1,1], [2,2],1),'Title','hoi')
    %   uipanel('Position', grid2pos([0,0], [2,1], [2,2],1),'Title','hoi')
    %   uipanel('Position', grid2pos([0,1], [1,1], [2,2],1),'Title','hoi')
    %   uipanel('Position', grid2pos([1,1], [1,1], [2,2],1),'Title','hoi')
    %% Example 2
    %   figure
    %   uipanel('Position', grid2pos([1,0], [1,1], [2,2],2))
    %   uipanel('Position', grid2pos([0,0], [1,1], [2,2],2))
    %   uipanel('Position', grid2pos([0,1], [1,1], [2,2],2))
    %   uipanel('Position', grid2pos([1,1], [1,1], [2,2],2))
    %% Example 3
    %   figure
    %   uipanel('Position', grid2pos([0,0], [2,1], [2,2]),'Title','A')
    %   uipanel('Position', grid2pos([0,1], [2,1], [2,2]),'Title','B')

    %% Import constants
    c = consts;

    %% Check input arguments
    if length(startC) ~= 2 || length(sizeC) ~= 2 || length(maxC) ~= 2
        error('Invalid grid position')
    end
    if startC(1)+sizeC(1) > maxC(1) || startC(2)+sizeC(2) > maxC(2)
        error('Grid out of bounds')
    end
    if nargin == 4
        if numel(varargin{1}) == 2
            initHeight = 1-varargin{1}(1)*(c.butHeight+c.sVer);
            initWidth = 1-varargin{1}(2)*(c.butWidth+c.sHor);
        elseif numel(varargin{1}) == 1
            initHeight = 1-varargin{1}(1)*(c.butHeight+c.sVer);
            initWidth = 1;
        else
            initHeight = 1;
            initWidth = 1;
        end
    else
        initHeight = 1;
        initWidth = 1;
    end

    %% Calculation
    widthUnit  = (initWidth -(maxC(1)+1)*c.sHor)/maxC(1);
    heightUnit = (initHeight-(maxC(2)+1)*c.sVer)/maxC(2);
    left   = 1-initWidth +c.sHor + startC(1)*(widthUnit +c.sHor);
    bottom = 1-initHeight+c.sVer + startC(2)*(heightUnit+c.sVer);
    pos = [left bottom (widthUnit+c.sHor)*sizeC(1)-c.sHor (heightUnit+c.sVer)*sizeC(2)-c.sVer];

end