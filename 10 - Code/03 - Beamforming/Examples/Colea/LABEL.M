function label(action,opt)

%
% Copyright (c) 1995 by Philipos C. Loizou
%

global fno  lbVals Srate labfile LD_LABELS Be En lbUp n_Secs
global iaCnt  lbaUp labSave LD_LAB_FILE LD_LAB_FILE2


if isempty(LD_LAB_FILE), LD_LAB_FILE=0; end;
if isempty(LD_LAB_FILE2), LD_LAB_FILE2=0; end;





%=========================================================================
if strcmp(action,'add') %------------------ Add a label ----------
   
    figure(fno)

if  LD_LAB_FILE2==1 % clear existing labels
  	jnk=get(gcf,'Userdata');
	delete(jnk);
  	lbUp=[];
end

[x,y]=ginput(2);


if isempty(iaCnt), 
	iaCnt=1; 
	labfile='xlab.txt'; 
end;

off=Be*1000/Srate;
lbVals(iaCnt,1)=x(1)+off; lbVals(iaCnt,2)=x(2)+off;



FigXY = get(fno,'Position');
	
xlm=get(gca,'Xlim');
set(gca,'Units','Pixels');
AxesXY =get(gca,'Position');

fac=AxesXY(3)/xlm(2);
Xoffset = AxesXY(1);		  % X pixel offset  

xpos = round(Xoffset+x(1)*fac);  % coordinate in pixels
xwi= round((x(2)-x(1))*fac);


lbaUp(iaCnt)=uicontrol('Style','edit','Position',[xpos 5 xwi 20 ],...
	'BackGroundColor','y','HorizontalAlignment',...
	'center','String','text','Callback','labtext');



iaCnt=iaCnt+1;


set(gcf,'Userdata',lbaUp);

set(gca,'Units','Normal');
hold off
LD_LABELS=1; LD_LAB_FILE=1;
%=========================================================================
elseif strcmp(action,'load') %-------------- Load a label file -----------

  if   nargin==2
  	[pth,fname] = dlgopen('open','*.phn;*.txt');
  	if ((~isstr(fname)) | ~min(size(fname))), return; end	
  	labfile=[pth,fname];
     LD_LAB_FILE2=1;
   figure(fno)
	jnk=get(gcf,'Userdata');
	for i=1:length(jnk)
	 valid=0;
	 eval('findobj(jnk(i));','valid=1;');
	 if valid==0, delete(jnk(i)); end; 
	end
  else
	jnk=get(gcf,'Userdata');
	for i=1:length(jnk)
	 valid=0;
	 eval('findobj(jnk(i));','valid=1;');
	 if valid==0, delete(jnk(i)); end; 
	end
 
  end


  LD_LABELS=1;
  x=zeros(2,1);
  endp=zeros(2,1);
  FigXY = get(fno,'Position');
	

  xlm=[Be*1000/Srate, En*1000/Srate];
  set(gca,'Units','Pixels');
  AxesXY =get(gca,'Position');

  fac=AxesXY(3)/xlm(2);
  Xoffset = AxesXY(1);		  % X pixel offset  

  if ~isempty(lbUp) & LD_LAB_FILE==1
  	lbUp=[];
  end
	
  fp =fopen(labfile,'r');

  ilc=1;
  while 1
  	[endp,cnt]=fscanf(fp,'%d %d',2);
	
   	if cnt ~=2
     	   break;
   	else
     	   lab = fscanf(fp,'%s',1);
   	  
       
	   	
	x(1)=endp(1)*1000/Srate;
	x(2)=endp(2)*1000/Srate;
	if x(2) > n_Secs*1000
	  fprintf('WARNING! A label was found out of range.\n');
	  break;
	end;
  	xpos = round(Xoffset+x(1)*fac);  % coordinate in pixels
   	xwi= round((x(2)-x(1))*fac);
	if xwi<=0, xwi=2; end;
	%fprintf('%d %d %d %d %s\n',xpos,xwi,endp(1),endp(2),lab)

	if rem(ilc,2)==0, bk=[0.5 0.5 0.5]; else, bk='b'; end;
   	
	lbUp(ilc)=uicontrol('Style','text','Position',[xpos 5 xwi 20 ],'BackGroundColor',bk,...
	 'ForeGroundColor','y','HorizontalAlignment','center','String',lab);
	
	ilc=ilc+1;
       end
   end
  
  fclose(fp);
  set(gcf,'Userdata',lbUp)
  
  set(gca,'Units','Normal');
  hold off
  LD_LAB_FILE=1;
% ==============================================================================
elseif strcmp(action,'loadzm') %-------- Draw the labels in a zoomed display -----------

  figure(fno)
  
  lab=[];
  LD_LABELS=1;
  x=zeros(2,1);
  endp=zeros(2,1);
  FigXY = get(fno,'Position');
	
  xlm=[Be*1000/Srate, En*1000/Srate];
  set(gca,'Units','Pixels');
  AxesXY =get(gca,'Position');

  fac=AxesXY(3)/(xlm(2)-xlm(1));
  Xoffset = AxesXY(1);		  % X pixel offset  
	
  fp =fopen(labfile,'r');


  
	jnk=get(gcf,'Userdata'); 
	for i=1:length(jnk)
	 valid=0;
	 eval('findobj(jnk(i));','valid=1;');
	 if valid==0, delete(jnk(i)); end; 
	end
	lbUp=[];
  

  begL=Be;
  endL=En;
  
  while endp(2)<begL 
	[endp,cnt]=fscanf(fp,'%d %d',2);
	if cnt==2
	  lab = fscanf(fp,'%s',1);
	else
	  fclose(fp);
	  return;
	end
  end;
	
	x(2)=(endp(2)-Be)*1000/Srate;
	x(1)=(endp(1)-Be)*1000/Srate;
	if x(1)<0.0, x(1)=0.0; end;
  	xpos = round(Xoffset+x(1)*fac);  % coordinate in pixels
   	xwi= round((x(2)-x(1))*fac);
	if xwi<=0, xwi=2; end;

   	lbUp(1)=uicontrol('Style','text','Position',[xpos 5 xwi 20 ],'BackGroundColor','b',...
	 'ForeGroundColor','y','HorizontalAlignment','center','String',lab);

  
  ilc=2; 
  while endp(2)<endL

  	[endp,cnt]=fscanf(fp,'%d %d',2);
   	if cnt ~=2
     	   break;
   	else
     	   lab = fscanf(fp,'%s',1);
   	  
        %fprintf('%d %d %s\n',endp(1),endp(2),lab);
	x(1)=(endp(1)-Be)*1000/Srate;
	if endp(2)>endL
	  x(2)=(endL-Be)*1000/Srate;
	else
	  x(2)=(endp(2)-Be)*1000/Srate;
	end
  	xpos = round(Xoffset+x(1)*fac);  % coordinate in pixels
   	xwi= round((x(2)-x(1))*fac);
	if xwi<=0, xwi=2; end;

	if rem(ilc,2)==0, bk=[0.5 0.5 0.5]; else, bk='b'; end; % -- alternate bkg colors
   	lbUp(ilc)=uicontrol('Style','text','Position',[xpos 5 xwi 20 ],'BackGroundColor',bk,...
	 'ForeGroundColor','y','HorizontalAlignment','center','String',lab); 
       
 	ilc=ilc+1;
	end % of if cnt ~=2
   end

  set(gcf,'Userdata',lbUp);
  fclose(fp);
  set(gca,'Units','Normal');
  hold off

%=========================================================================
 elseif strcmp(action,'save') %-------------- save a label file -----------
    
    
 	if isempty(iaCnt)
	  errordlg('No labels were created for saving.','ERROR','on');
	  return;
	end
  	[pth,fname] = dlgopen('save','*.phn;*.txt');
  	if ((~isstr(fname)) | ~min(size(fname))), return; end	
  	filen=[pth,fname];
     
     

	fp=fopen(filen,'w');
	ic=size(lbVals); ic1=ic(1);
	vals=round(lbVals*Srate/1000);
	
	for i=1:ic1
	  in=find(labSave(i,:)==0);
	  fprintf(fp,'%d %d %s\n',vals(i,1),vals(i,2),setstr(labSave(i,1:in(1))));
	end
	
	fclose(fp);
 
%=========================================================================
 elseif strcmp(action,'savef') %-------------- save a label file -----------

 	if isempty(iaCnt)
	  errordlg('No labels were created for saving.','ERROR','on');
	  return;
	end
 
	
	fp=fopen(labfile,'w');
	ic=size(lbVals); ic1=ic(1);
	vals=round(lbVals*Srate/1000);
	
	for i=1:ic1
	  in=find(labSave(i,:)==0);
	  fprintf(fp,'%d %d %s\n',vals(i,1),vals(i,2),setstr(labSave(i,1:in(1))));
	end
	
	fclose(fp);
 
%=========================================================================
 elseif strcmp(action,'delete') %-------------- delete the last label ----

  
    figure(fno)
  if iaCnt>1 
   jnko=get(gcf,'Userdata');
   jnk=jnko(iaCnt-1);
   valid=0;
   eval('findobj(jnk);','valid=1;');
   if valid==0, delete(jnk); 
    	  	iaCnt=iaCnt-1;
   end	
  else
   lbaUp=[]; lbVals=[];
   errordlg('There is no label to delete','ERROR','on');
   return;
  end
 
%=========================================================================
 elseif strcmp(action,'clear') %-------------- clear all labels ----

  
   figure(fno)
  
   jnko=get(gcf,'Userdata');
   if isempty(jnko)
	 errordlg('There are no labels to clear','ERROR','on');
    else
	for i=1:length(jnko)
		valid=0;
		eval('findobj(jnko(i));','valid=1;');
		if valid==0, delete(jnko(i)); end;
	end
   	lbaUp=[]; lbVals=[];
	set(gcf,'Userdata',[]);
	LD_LABELS=0;
	iaCnt=1;  
    end
   
end

