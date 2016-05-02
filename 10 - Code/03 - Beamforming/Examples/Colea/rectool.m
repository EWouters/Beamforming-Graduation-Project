function rectool

% Copyright (c) 1995 Philipos C. Loizou

global nChannels filename bvi avi Srate 
global HDRSIZE S0 S1  En Be Dur n_Secs MAX_AM fno
global HDRSIZE2 Srate2 n_Secs2 filename2 TOP TWOFILES agcsc2
global recFig recBitsH recFsH recFileH recDurH


pos = get(0, 'screensize');

wi=270; 
he=210; 
xpos=(pos(3)-wi)/2; 
ypos=(pos(4)-he)/2;

if isempty(recFig)
	recFig = figure('Units', 'pixels', 'Position', [xpos ypos wi he],...
	'Menubar','none','NumberTitle','off','Name',...
	'Recording Tool');
else
	figure(recFig);
	if ~isempty(recBitsH); return; end;
end

%---------------- Define the buttons for Low-Pass Filter-----------------------
dp=35; 
top=165; 
inc=30;
lft=80;
wit=65; 


uicontrol('Style','Text','String','Sampl Freq','Position',[3 top lft+7 20],'BackgroundColor',...
	 [0 0 0],'ForeGroundColor','y');
recFsH=uicontrol('Style','PopUp','String',' 8,000 | 11,025 | 16,000 | 22,050 | 44,100','Position',[lft+12 top wit 20],...
   'BackgroundColor',[1 1 1],'Value',4);
uicontrol('Style','Text','String','Hz','Position',[lft+12+wit+3 top lft+7 20],'BackgroundColor',...
   [0 0 0],'ForeGroundColor','y','HorizontalAlignment','left');

top=top-inc;
uicontrol('Style','Text','String','Duration','Position',[3 top lft 20],'BackgroundColor',...
	 [0 0 0],'ForeGroundColor','y');
recDurH=uicontrol('Style','edit','String','2','Position',[lft+12 top wit/2 20],...
	'BackgroundColor',[1 1 1]);
uicontrol('Style','Text','String','secs','Position',[lft+12+wit/2+3 top lft+7 20],'BackgroundColor',...
   [0 0 0],'ForeGroundColor','y','HorizontalAlignment','left');


top=top-inc;
uicontrol('Style','Text','String','Number of bits','Position',[3 top lft 20],'BackgroundColor',...
	 [0 0 0],'ForeGroundColor','y');
recBitsH=uicontrol('Style','Popup','String',' 8 | 16','Position',[lft+12 top wit 20],...
	'BackgroundColor',[1 1 1],'Value',2);

top=top-inc;
uicontrol('Style','Text','String','Filename','Position',[3 top lft 20],'BackgroundColor',...
	 [0 0 0],'ForeGroundColor','y');
recFileH=uicontrol('Style','edit','String','rec.wav','Position',[lft+12 top wit 20],...
	'BackgroundColor',[1 1 1]);

top=top-inc;

%---Draw the close button-----------
dx=10;
width=50;
lft=floor(wi-3*width-2*dx)/2;

uicontrol('Style','pushb','String','Record','Position',[lft 5 width 20],...
   'Callback','getrec','BackgroundColor','r','ForegroundColor','w',...
   'FontWeight','bold');
lft=lft+width+dx;
uicontrol('Style','pushb','String','Cancel','Position',[lft 5 width 20],...
	'Callback','closem(''recFig'')');
lft=lft+width+dx;
uicontrol('Style','pushb','String','Help','Position',[lft 5 width 20],...
	'Callback','helpf(''rectool'')');

s=which('wavrecord');
if length(s)==0
   errordlg('The MATLAB record program can not be located in this PC. You need MATLAB 5.3 and Signal Processing Toolbox 4.2.','WARNING','on');
end

