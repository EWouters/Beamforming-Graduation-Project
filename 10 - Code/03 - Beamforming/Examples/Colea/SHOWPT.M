function showpt

% Detect mouse click, and act appropriately
%

% Copyright (c) 1995 by Philipos C. Loizou
%

global smp


if isempty(smp), return; end;

global fno Srate n_Secs AXISLOC
global Be En TIME  TWOFILES TOP Be2 En2
global Srate2 n_Secs2 tpc boc  frq 
global upFreq upFreq2 


xv = get(fno,'CurrentPoint');  % get cursor coordinates in pixels
xp = xv(1);
yp = xv(2);

FigXY  = get(fno,'Position');

%
% The offset Be is added to account for zoomed displays
%
in_win=0;

if TWOFILES==1
	set(fno,'Units','Normal');
	xv2 = get(fno,'CurrentPoint');
	set(fno,'Units','Pixels');
	if xv2(2)>0.5
	   top_win=1; 
	else 
	   top_win=0;
	end
end
	

if TWOFILES==1
  if top_win==1
  	Sample = Be2+round((xp-AXISLOC(1))*(En2-Be2)/AXISLOC(3));
	yoffs=0.55*FigXY(4);
	zhei =0.34*FigXY(4);
  	Freq   = round((yp-yoffs)*Srate2*0.5*upFreq2/zhei);
	stime = Sample*1000/Srate2;
	b= n_Secs2*Srate2;
  	hsra=0.5*upFreq2*Srate2;
	if Sample>=0 & Sample<=b, in_win=1; end;
	
  else
	Sample = Be+round((xp-AXISLOC(1))*(En-Be)/AXISLOC(3));
	yoffs=0.11*FigXY(4);
	zhei =0.34*FigXY(4);
  	Freq   = round((yp-yoffs)*Srate*0.5*upFreq/zhei);
	stime = Sample*1000/Srate;
	b= n_Secs*Srate;
  	hsra=0.5*upFreq*Srate;
	if Sample>=0 & Sample<=b, in_win=1; end;
  end
  
else
  Sample = Be+round((xp-AXISLOC(1))*(En-Be)/AXISLOC(3));
  Freq   = round((yp-AXISLOC(2))*Srate*0.5*upFreq/AXISLOC(4));
  b= n_Secs*Srate;
  hsra=0.5*upFreq*Srate;
  stime = Sample*1000/Srate;
  
  if Sample>=0 & Sample<=b, in_win=1; end;
end



 if in_win==1

     tStr = sprintf('t= %4.1f (ms)',(stime));
     fStr = sprintf('f= %d Hz',Freq);

 
      %-----------plot the sample number and/or freq -----
     set(smp,'String',tStr,'ForegroundColor','w','BackgroundColor',[0 0 0]);
     if TIME==0
	 if Freq>0 & Freq<=hsra
     	  set(frq,'String',fStr,'ForegroundColor','w','BackgroundColor',[0 0 0]);
	 end
     end

     
end

