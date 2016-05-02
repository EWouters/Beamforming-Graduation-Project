function beautiplot(y, varargin)
% plot function which produces READABLE figures
% input parser
p = inputParser;
% Some defaults:
RATIO=1.3; % ratio between width and height
height = 5;     % Width in inches
width = height*RATIO;    % Height in inches
alw = 0.75;    % AxesLineWidth
lw = 1.5;      % LineWidth
msz = 8;       % MarkerSize
fsz = 14;       % FontSize
flnm = '';
checkLim = @(x) (isvector(x)&&length(x)==2);
allowedLocations = {'east', 'northeast','north', 'northwest', 'west', 'southwest', 'south', 'southeast'};
checkLocation = @(x) any(validatestring(x,allowedLocations));

% parse the input
addRequired(p, 'yvals', @isnumeric);
addOptional(p, 'xvals', [], @isnumeric);
addOptional(p, 'axesLineWidth', alw, @isnumeric);
addOptional(p, 'lineWidth', lw, @isnumeric);
addOptional(p, 'height', height, @isnumeric);
addOptional(p, 'width', width, @isnumeric);
addOptional(p, 'markerSize', msz, @isnumeric);
addOptional(p, 'fontSize', fsz, @isnumeric);
addOptional(p, 'fileName', flnm, @ischar);
addOptional(p, 'xlim', [], checkLim);
addOptional(p, 'ylim', [], checkLim);
addOptional(p, 'title', '', @ischar);
addOptional(p, 'legend', '');
addOptional(p, 'location', '', checkLocation);

p.KeepUnmatched = true;
parse(p, y, varargin{:});
if ~isempty(fieldnames(p.Unmatched))
    warning(['Some fields unused:']);
    disp(p.Unmatched);
end

figure()
% apply the settings
set(gcf,'defaultLineLineWidth',p.Results.lineWidth);   % set the default line width to lw
set(gcf,'defaultLineMarkerSize',p.Results.markerSize); % set the default line marker size to msz
set(gcf,'defaultAxesFontSize',p.Results.fontSize);       % set the default font size

if isempty(p.Results.xvals)
    plot(p.Results.yvals);
elseif (isequal(size(p.Results.xvals), size(p.Results.yvals)) || (isvector(p.Results.xvals) && isvector(p.Results.yvals) && numel(p.Results.xvals) == numel(p.Results.yvals)))
    plot(p.Results.xvals, p.Results.yvals);
else
    error('X and Y vector(s) mismatch')
end

% set x and y limits
if ~isempty(p.Results.xlim)
    xlim(p.Results.xlim);
end
if ~isempty(p.Results.ylim)
    ylim(p.Results.ylim);
end

% set title
if ~isempty(p.Results.title)
    title(p.Results.title);
end

% set legend
if ~isempty(p.Results.legend)
    legend(p.Results.legend);
end

% set legend location
if ~isempty(p.Results.location)
    lgnd = findobj(gcf, 'Tag', 'legend');
    lgnd.Location = p.Results.location;
end

% if filename is given, save file
if ~isempty(p.Results.fileName)
    set(gcf,'InvertHardcopy','on');
    set(gcf,'PaperUnits', 'inches');
    papersize = get(gcf, 'PaperSize');
    left = (papersize(1)- p.Results.width)/2;
    bottom = (papersize(2)- p.Results.height)/2;
    myfiguresize = [left, bottom, p.Results.width, p.Results.height];
    set(gcf,'PaperPosition', myfiguresize);
    print(p.Results.fileName,'-dpng','-r300');
end


end