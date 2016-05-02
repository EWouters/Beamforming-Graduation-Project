function volopt(type)

%
% Copyright (c) 1995 by Philipos C. Loizou
%
global rb_abs rb_norm rb_nosc VOL_NORM VOL_MAX vol_sli


if strcmp(type,'abs')

  set(rb_abs,'Value',1); set(rb_norm,'Value',0); set(rb_nosc,'Value',0);
  VOL_NORM=3;
  set(vol_sli,'Value',100);

elseif strcmp(type,'norm')

 set(rb_abs,'Value',0); set(rb_norm,'Value',1); set(rb_nosc,'Value',0);
 VOL_NORM=1;
 VOL_MAX=0;
 set(vol_sli,'Value',100); 

elseif strcmp(type,'nosc')

  set(rb_abs,'Value',0); set(rb_norm,'Value',0); set(rb_nosc,'Value',1);
  VOL_NORM=2;
  VOL_MAX=0.5;
  set(vol_sli,'Value',50); 
end
