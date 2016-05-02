%% grid2Pos
% Function to calculate normalized positions on Grid
% Example 1
%   figure
%   uipanel('Position', grid2pos([1,0, 1,1, 2,2, 1]),'Title','A')
%   uipanel('Position', grid2pos([0,0, 1,1, 2,2, 1]),'Title','B')
%   uipanel('Position', grid2pos([0,1, 1,1, 2,2, 1]),'Title','C')
%   uipanel('Position', grid2pos([1,1, 1,1, 2,2, 1]),'Title','D')
% Example 2
%   figure
%   uipanel('Position', grid2pos([1,0, 1,1, 2,2, 2]))
%   uipanel('Position', grid2pos([0,0, 1,1, 2,2, 2]))
%   uipanel('Position', grid2pos([0,1, 1,1, 2,2, 2]))
%   uipanel('Position', grid2pos([1,1, 1,1, 2,2, 2]))
% Example 3
%   figure
%   uipanel('Position', grid2pos([0,0, 2,1, 2,2]),'Title','A')
%   uipanel('Position', grid2pos([0,1, 1,1, 2,2]),'Title','B')
%   uipanel('Position', grid2pos([1,1, 1,1, 2,2]),'Title','C')
%%
function pos = grid2pos(gridPos)
    % Import constants
    c.sHor = 1/1000;                        % Space between horizontal items
    c.sVer = 1/1000;                        % Space between vertical items
    c.butHeight = 1/10;                     % Height of a button
    c.butWidth = 1/3.5;                     % Width  of a button
    % Check input arguments
    default = [0,0,1,1,1,1,0,0];
    s = length(gridPos);
    if isnumeric(gridPos) && any(s==[2 4 6 7 8])
        gridPos = [gridPos default(s+1:end)];
        if gridPos(1)+gridPos(3) > gridPos(5) || gridPos(2)+gridPos(4) > gridPos(6)
            error('Grid out of bounds: %s',mat2str(gridPos));
        end
    else
        warning(['Arguments must be numeric and must have ',...
                '2,4,6,7 or 8 elements like this:\n',...
                '\t[x,y, xsize,ysize, xmax,ymax, buttonHeights, buttonWidths]',...
                '\n\t%s\n\n',...
                'Defaults have been loaded:\n\t%s'],mat2str(gridPos),mat2str(default));
        gridPos = default;
    end
    %% Calculation
    initHeight = 1-gridPos(7)*(c.butHeight+c.sVer);
    initWidth  = 1-gridPos(8)*(c.butWidth+c.sHor);
    widthUnit  = (initWidth -(gridPos(5)+1)*c.sHor)/gridPos(5);
    heightUnit = (initHeight-(gridPos(6)+1)*c.sVer)/gridPos(6);
    left   = 1-initWidth +c.sHor + gridPos(1)*(widthUnit +c.sHor);
    bottom = 1-initHeight+c.sVer + gridPos(2)*(heightUnit+c.sVer);
    width  = (widthUnit +c.sHor)*gridPos(3)-c.sHor;
    height = (heightUnit+c.sVer)*gridPos(4)-c.sVer;
    pos = [left bottom width height];
end