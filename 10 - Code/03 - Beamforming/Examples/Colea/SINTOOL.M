function singen

% Copyright (c) 1995 Philipos C. Loizou

global  sinF S0 sinFr sinDur sinAmp siAm siFr siDu

if isempty(sinFr)
 sinFr=1000;
 sinDur=500;
 sinAmp=1000;
end

pos = get(0, 'screensize');
xpos=pos(3)/3; 
ypos=pos(4)/3;
wi=150; 
he=200;

if isempty(sinF)
	sinF = figure('Units', 'pixels', 'Position', [xpos ypos wi he],...
	'Menubar','none','NumberTitle','off','Name',...
	'sine wave setting');
else
	figure(sinF);
	return;
end


%---------------- Define the buttons -----------------------
dp=35; % he/5
top=he-dp-10;
inc=30;
lft=dp;
wit=41;

uicontrol('Style','Text','String','Freq','Position',[3 top lft+21 20],'BackgroundColor',...
	 [0 0 0],'ForeGroundColor','y');
siFr=uicontrol('Style','edit','String',int2str(sinFr),'Position',[lft+25 top wit 20],...
	'Callback','setsin(''freq'')','BackgroundColor',[1 1 1]);
uicontrol('Style','Text','String','Hz','Position',[lft+25+wit+3 top 20 20],'BackgroundColor',...
	 [0 0 0],'ForeGroundColor','y');
top=top-inc;
uicontrol('Style','Text','String','Duration','Position',[3 top lft+21 20],'BackgroundColor',...
	 [0 0 0],'ForeGroundColor','y');
siDu=uicontrol('Style','edit','String',int2str(sinDur),'Position',[lft+25 top wit 20],...
	'Callback','setsin(''dur'')','BackgroundColor',[1 1 1]);
uicontrol('Style','Text','String','msec','Position',[lft+25+wit+4 top 40 20],'BackgroundColor',...
	 [0 0 0],'ForeGroundColor','y');
top=top-inc;
uicontrol('Style','Text','String','Amplit','Position',[3 top lft+21 20],'BackgroundColor',...
	 [0 0 0],'ForeGroundColor','y');
siAm=uicontrol('Style','edit','String',int2str(sinAmp),'Position',[lft+25 top wit 20],...
	'Callback','setsin(''amp'')','BackgroundColor',[1 1 1]);
lft=lft+12;
top=top-inc;
uicontrol('Style','pushb','String','Apply','Position',[lft-10 top wit+15 20],...
	'Callback','singen');
top=top-inc;
uicontrol('Style','pushb','String','Close','Position',[lft-10 top wit+15 20],...
	'Callback','closem(''sinF'')');


