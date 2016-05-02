function seton(type)

% Copyright (c) 1995 Philipos C. Loizou
%

global OVRL fno FIX_SCALE



if strcmp(type,'on')
 OVRL=-OVRL;
elseif strcmp(type,'scale')
 FIX_SCALE=-FIX_SCALE;
end



figure(fno);

