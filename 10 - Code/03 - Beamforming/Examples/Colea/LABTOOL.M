function labtool

%
% Copyright (c) 1995 Philipos C. Loizou
%

global nChannels filename bvi avi Srate 
global  labFig


pos = get(0, 'screensize');
xpos=pos(3)/3; 
ypos=pos(4)/3;
wi=200;
he=200;

if isempty(labFig)
	labFig = figure('Units', 'pixels', 'Position', [xpos ypos wi he],...
	'Menubar','none','NumberTitle','off','Name','Label Editor');
else
	figure(labFig);
end


%---------------- Define the buttons for adding, deleting, etc labels -----------------------
dp=35; 
top=he-dp-10;
inc=30;
lft=20;
wit=70;
tp=top-65;

uicontrol('Style','Frame','Position',[8 50 wit+20 tp+65-50],...
	'BackgroundColor','b');
uicontrol('Style','Text','String','Edit','Position',[9 tp+63 wit+18 22],...
	'ForegroundColor',[1 1 1],'BackgroundColor','b','HorizontalAlignment','Center');

top=top-inc;
uicontrol('Style','Pushb','String','Add label','Position',[lft-10 top wit+15 20],...
	'Callback','label(''add'')');
top=top-inc;
uicontrol('Style','pushb','String','Delete label','Position',[lft-10 top wit+15 20],...
	'Callback','label(''delete'')');
top=top-inc;
uicontrol('Style','pushb','String','Clear all','Position',[lft-10 top wit+15 20],...
	'Callback','label(''clear'')');

%---------------- Define the buttons for loading and saving labels-----------------------
top=he-dp-10;
inc=30;
lft=lft+wit+20;

uicontrol('Style','Frame','String','Edit','Position',[lft-5 tp wit+25 70],...
	'BackgroundColor','b');
uicontrol('Style','Text','String','File','Position',[lft-4 tp+65 wit+23 20],...
	'ForegroundColor',[1 1 1],'BackgroundColor','b','HorizontalAlignment','Center');
top=top-inc;
uicontrol('Style','pushb','String','Save labels','Position',[lft top wit+20 20],...
	'Callback','label(''save'')');
top=top-inc;
uicontrol('Style','pushb','String','Load labels','Position',[lft top wit+20 20],...
	'Callback','label(''load'',''file'')');
 


%---Draw the close button-----------
lft=(wi-wit-18)/2;
uicontrol('Style','pushb','String','CLOSE','Position',[lft-5 5 wit+18 20],...
	'Callback','closem(''labFig'')');

