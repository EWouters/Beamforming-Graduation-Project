

global sliB fno TIME CLR 

if TIME==0

x=get(sliB,'Value');
figure(fno);
if CLR==1
  brighten(jet,x)
else
  set(sliB,'Value',0');

end

