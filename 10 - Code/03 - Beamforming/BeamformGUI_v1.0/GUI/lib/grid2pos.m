%% grid2Pos
% Function to calculate normalized positions on Grid
% Example 1
%   figure
%   uipanel('Position', grid2pos([1,1, 1,1, 2,2, 1/10]),'Title','A')
%   uipanel('Position', grid2pos([2,1, 1,1, 2,2, 1/10]),'Title','B')
%   uipanel('Position', grid2pos([1,2, 1,1, 2,2, 1/10]),'Title','C')
%   uipanel('Position', grid2pos([2,2, 1,1, 2,2, 1/10]),'Title','D')
%%
function pos = grid2pos(grid1)
    % Format:
    % [x,y, xNum,yNum, xSize,ySize, l,r,b,t, xSpace,ySpace]
%     grid1 = [1,1, 2,1, 2,2];
    pos = [1,1, 1,1, 1,1, 0,0,0,0, 1/1000,1/1000];
    n = numel(grid1);
    if n > 0 && n < 12
        pos = [grid1 pos(n+1:end)];
    end
    x      = pos(1)-1;  y      = pos(2)-1;
    xNum   = pos(3);    yNum   = pos(4);
    xSize  = pos(5);    ySize  = pos(6);
    xSpace = pos(11);   ySpace = pos(12);
    
    % Calculation
    xInit = 1-pos(7)-pos(8);
    yInit = 1-pos(9)-pos(10);
    xUnit = (xInit-(xSize+1)*xSpace) / xSize;
    yUnit = (yInit-(ySize+1)*ySpace) / ySize;
    width  = (xUnit+xSpace)*xNum - xSpace;
    height = (yUnit+ySpace)*yNum - ySpace;
    left   = pos(7) +xSpace+ x*(xUnit+xSpace);
    bottom = 1-(pos(10)+ySpace+ y*(yUnit+ySpace)) - height*(1-pos(9));
    
    pos = [left bottom width height];
    
    %% Error checking
    if bottom+height > 1 || left+width > 1 || any(abs(pos)~=pos)
        fprintf('\tgrid = %s\n',mat2str(grid1));
        fprintf('\tpos  = %s\n',mat2str(pos));
        error('Position out of bounds');
    end
end