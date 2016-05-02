function pos = but2gridPos(ind, tot, tabPos)
    % Function to calculate normalized positions on Grid
    %% Example1:
    %   pos = but2gridPos(1,1,1);figure;uicontrol('Style','PushButton','Units','normalized','Position',pos);
    %% Example2:
    %   figure;
    %   uicontrol('Style','ToggleButton','Units','normalized','Position',but2gridPos(1,2,0));
    %   uicontrol('Style','ToggleButton','Units','normalized','Position',but2gridPos(2,2,0));
    
    %% Import constants
    c = consts;
    
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