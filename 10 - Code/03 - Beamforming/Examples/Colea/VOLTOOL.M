function voltool

% Copyright (c) 1995 by Philipos C. Loizou
%

global  volFig
global vol_sli rb_norm rb_abs rb_nosc

if exist('volFig')
 valid=0;
 eval('findobj(volFig);','valid=1;');
end

if isempty(volFig) | valid==1

  wi=300; he=90;
  pos=get(0,'screensize');
  xpos=(pos(3)-wi)/2;
  ypos=(pos(4)-he)/2;  

  volFig=figure('Units','Pixels','Position',[xpos ypos wi he],'MenuBar','None','Name',...
	'Volume Tool','NumberTitle','Off');

    %---------- Display the volume slider -------------
    %
    vol_sli = uicontrol('Style','slider','min',0,'max',100','Callback',...
	'getvol','Position',[50 60 wi-100 15],'Value',99);
    uicontrol('style','text','String','soft','Position',[20 60 20 15],...
	'ForegroundColor','r','BackgroundColor','k');
    uicontrol('style','text','String','loud','Position',[50+wi-100+8 60 30 15],...
	'ForegroundColor','r','BackgroundColor','k');

    uicontrol('style','pushb','String','Cancel','Position',[wi-50 30 50 15],...
	'Callback','delete(gcf)');
    uicontrol('style','pushb','String','Help','Position',[wi-50 5 50 15],...
	'Callback','helpf(''voltool'')');

   
   rb_norm=uicontrol('Style','radio','String','Auto scale','Value',1,...
		'Position',[2 15 77 15],'Callback','volopt(''norm'')',...
		'ForegroundColor','y','BackgroundColor','k');
   rb_nosc=uicontrol('Style','radio','String','No scale',...
		'Position',[90 15 70 15],'Callback','volopt(''nosc'')',...
		'ForegroundColor','y','BackgroundColor','k');
   rb_abs=uicontrol('Style','radio','String','Absolute',...
		'Position',[170 15 70 15],'Callback','volopt(''abs'')',...
		'ForegroundColor','y','BackgroundColor','k');
   
 
 

else
 figure(volFig); 
end

