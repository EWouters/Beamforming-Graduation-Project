function setsin(type)

% Copyright (c) 1995 Philipos C. Loizou

global siDu siAm siFr sinFr sinDur sinAmp 


if strcmp(type,'freq')
 sinFr=str2num(get(siFr,'String'));
elseif strcmp(type,'dur')
 sinDur=str2num(get(siDu,'String'));
elseif strcmp(type,'amp')
 sinAmp=str2num(get(siAm,'String'));
end

