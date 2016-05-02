function drawctls

% Copyright (c) 1995 by Philipos C. Loizou
%


global ctlFig fFig ipk1 ipk2 ipk3 iapk1 iapk2 iapk3 iengy
global tUp
global lpcPopUp
global ctFFT
global SpcUp
global ovrUp
global vchUp DurUp

pos = get(0, 'screensize'); % get the screensize
sWi = pos(3);
sHe = pos(4);

wi=round(0.5625*sWi);
he=round(0.45*sHe);

le=round((sWi-wi)/2);
wi_new=sWi-le-wi-10;

if isempty(ctlFig)
	ctlFig = figure('Units', 'pixels', 'Position', [le+wi 20 wi_new he],...
	'Menubar','none','NumberTitle','off','Name','Controls','Color','k');	
 
end

xywh = get(ctlFig, 'Position');

% Buttons.
left = 6;
wide = 40;
top  = xywh(4) - 10;
high = 22;
if 9*(22+8) > xywh(4), high=17; end;
inc  = high + 8;
inct = 15;

top=top-15;
uicontrol('Style', 'Text','String','Cursor loc:','Position', [left top wide+30 15],...
	'BackgroundColor',[0 0 0],'ForegroundColor','y','HorizontalAlignment','left');

tUp=uicontrol('Style', 'Text','String',' ','Position', [left+wide+30 top wide+20 15],...
	'BackgroundColor',[0 0 0],'ForegroundColor',[1 1 1]);

uicontrol('Style', 'Text','String','Hz','Position', [left+2*wide+51 top wide 15],...
	'BackgroundColor',[0 0 0],'ForegroundColor','y');
 
top=top-10;

%
%------------------- Draw the text for Formants, amplitudes and energy  ------------
%
wide2=round((xywh(3)-50)/3);
nleft2=left+wide2+14;
uicontrol('Style', 'Text','String','Formants','Position', [left top-10 wide2+24 15],...
	'BackgroundColor','b','ForegroundColor','w','HorizontalAlignment','left');

nleft=left+wide+20;
uicontrol('Style', 'Text','String','Ampl','Position', [nleft2+4 top-10 wide2+15 15],...
	'BackgroundColor','b','ForegroundColor','w','HorizontalAlignment','right');

uicontrol('Style', 'Text','String','Engy','Position', [nleft2+wide2+18 top-10 wide2+19 15],...
	'BackgroundColor','b','ForegroundColor','w','HorizontalAlignment','center');

top=top-inc+5;
left=3;
ipk1=uicontrol('Style', 'Text','String',' ','Position', [left top-10 wide2+18 15],...
	'BackgroundColor',[0 0 0],'ForegroundColor',[1 1 1],'HorizontalAlignment','center');

iapk1=uicontrol('Style', 'Text','String',' ','Position', [nleft2 top-10 wide2+15 15],...
	'BackgroundColor',[0 0 0],'ForegroundColor','r','HorizontalAlignment','right');

iengy=uicontrol('Style', 'Text','String',' ','Position', [nleft2+wide2+21 top-10 wide2+15 15],...
	'BackgroundColor',[0 0 0],'ForegroundColor',[1 1 1],'HorizontalAlignment','center');


top=top-inct;
ipk2=uicontrol('Style', 'Text','String',' ','Position', [left top-10 wide2+18 15],...
	'BackgroundColor',[0 0 0],'ForegroundColor',[1 1 1],'HorizontalAlignment','center');
iapk2=uicontrol('Style', 'Text','String',' ','Position', [nleft2 top-10 wide2+15 15],...
	'BackgroundColor',[0 0 0],'ForegroundColor','r','HorizontalAlignment','right');
top=top-inct;
ipk3=uicontrol('Style', 'Text','String',' ','Position', [left top-10 wide2+18 15],...
	'BackgroundColor',[0 0 0],'ForegroundColor',[1 1 1],'HorizontalAlignment','center');
iapk3=uicontrol('Style', 'Text','String',' ','Position', [nleft2 top-10 wide2+15 15],...
	'BackgroundColor',[0 0 0],'ForegroundColor','r','HorizontalAlignment','right');

%-----------------------------draw the buttons --------------------------------
nwide=wide+20; 
left=5;
top=top-inc; top2=top; 
inc=(top-4*high)/4;
inc=inc+high;
lpcPopUp = uicontrol('Style', 'Popup', 'Callback', 'setlpc', ...
          'HorizontalAlign','center', 'String', ['LPC order | 8 | 10 | 12 | 14 | 16 | 18 | 20 | 22 | 24 | 28 | 32'],...
          'Position', [left top-20 wide+30 high]);
       
       z=wi_new-2*left-2*(wide+30);
       lft=left+wide+30+z;
 uicontrol('Style', 'Text','String','Duration','Position', [lft top wide+30 15],...
	'BackgroundColor','b','ForegroundColor','w','HorizontalAlignment','center');
   
DurUp = uicontrol('Style', 'Popup', 'Callback', 'setdur', ...
	  'HorizontalAlign','center', 'String', [' 10 ms | 20 ms | 30 ms | 40 ms | 50 ms | In samples | 64 | 128 | 256 | 512'],...
	  'Position', [lft top-22 wide+30 high]); 


top=top-inc;
ctFFT = uicontrol('Style', 'Popup', 'Callback','setfft', ...
          'HorizontalAlign','left', 'String', ['FFT size | Default | 64 | 128 | 256 | 512 | 1024'],...
          'Position', [left top-20 wide+30 high]);  



top=top-inc;
SpcUp = uicontrol('Style', 'Popup', 'Callback','specsel', ...
          'HorizontalAlign','left', 'String', ['Spectrum | LPC | FFT'],...
          'Position', [left top-20 wide+30 high]);  




top=top-inc;
ovrUp=uicontrol('Style', 'Checkbox', 'Callback','seton(''on'')', ...
          'HorizontalAlign','center', 'String', 'Overlay', ...
          'Position', [left top-high 2*wide high]);
%---


figure(fFig);
