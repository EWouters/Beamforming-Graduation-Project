function puttext


% Copyright (c) 1995 Philipos C. Loizou
%

global fno Srate fFig UpperFreq Lfreq tUp ctlFig LPC_ONLY
global TWOFILES TOP Srate2 x_max

xv = get(fFig,'CurrentPoint');
xp = xv(1);
yp = xv(2);
 


FigXY = get(fFig,'Position');

AxesXY =get(gca,'Position');			  % get normalized axes coords




Xoffset = round(AxesXY(1)*FigXY(3));		  % X pixel offset
Yoffset = round(AxesXY(2)*FigXY(4));              % Y pixel offset

if LPC_ONLY==1
  lf=x_max;
else
 lf=Lfreq;
end

xpos = (xp-Xoffset)*lf/(AxesXY(3)*FigXY(3));  % coordinate in Hz

if xpos>=0 & xpos<=lf

  str = sprintf('%d',round(xpos));

  set(tUp,'String',str);
end


figure(ctlFig);

