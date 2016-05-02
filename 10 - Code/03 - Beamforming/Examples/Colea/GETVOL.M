function getvol

% Copyright (c) 1996 by Philipos C. Loizou
%

global vol_sli VOL_MAX VOL_NORM 




x = get(vol_sli,'Value');

if VOL_NORM==1

 VOL_MAX=0; 
 set(vol_sli,'Value',100);

elseif VOL_NORM==2

 VOL_MAX=x/100;

elseif VOL_NORM==3
 set(vol_sli,'Value',100);
end
