function isnr(type)

% Copyright (c) 1998 by Philipos C. Loizou
%

global  snrFig snrOp GAUSN


if strcmp(type,'gaussian')
  GAUSN=1;
else	% spetrally shaped noise
  GAUSN=0;
end

pos = get(0, 'screensize'); % get the screensize
sWi = pos(3);
sHe = pos(4);
xpos=(sWi-200)/2;
ypos=(sHe-80)/2;

 if ~isempty(snrFig)
	invalid=0;
	eval('findobj(snrFig);','invalid=1;');
 end

if isempty(snrFig) | invalid==1
     snrFig=figure('Units','Pixels','Position',[xpos ypos 200 80],'MenuBar','None','Name',...
	'SNR Window','NumberTitle','Off');

	snrOp=uicontrol('Style','edit','String','10','Position',[70 20 60 20],...
	'Callback','modify(''noise'')');

	txt='Enter SNR value in dB: ';
	uicontrol('Style','Text','String',txt,'Position',[10 50 160 20],...
	'BackgroundColor',[0 0 0],'ForeGroundColor','y');
else
 figure(snrFig); 
end

