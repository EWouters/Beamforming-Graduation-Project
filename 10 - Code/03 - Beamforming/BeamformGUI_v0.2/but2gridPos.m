%% but2gridPos
%  Function to calculate normalized positions on Grid
function pos = but2gridPos(ind, tot, tabPos)
    %% Example1:
    %   pos = but2gridPos(1,1,1);figure;uicontrol('Style','PushButton','Units','normalized','Position',pos);
    %% Example2:
    %   figure;
    %   uicontrol('Style','ToggleButton','Units','normalized','Position',but2gridPos(1,2,0));
    %   uicontrol('Style','ToggleButton','Units','normalized','Position',but2gridPos(2,2,0));

    %% Import constants
    c.sHor = 1/1000;                        % Space between horizontal items
    c.sVer = 1/1000;                        % Space between vertical items
    c.butHeight = 1/10;                     % Height of a button
    c.butWidth = 1/3.5;                     % Width  of a button

    %% Calculation
    initWidth = 1;
    widthUnit  = (initWidth -(tot+1)*c.sHor)/tot;
    left = 1-initWidth + c.sHor + (ind-1)*(widthUnit+c.sHor);
    if tabPos
        bottom = c.sVer;
    else
        bottom = 1-c.butHeight-c.sVer;
    end
    pos = [left bottom widthUnit c.butHeight];
end