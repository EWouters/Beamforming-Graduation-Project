function setlpc

% Copyright (c) 1995 Philipos C. Loizou
%

global lpcPopUp nLPC S0

x = get(lpcPopUp,'Value');

if (x > 1)

 if     (x==2)  nLPC = 8;
 elseif (x==3)  nLPC = 10;
 elseif (x==4)  nLPC = 12;
 elseif (x==5)  nLPC = 14;
 elseif (x==6)  nLPC = 16;
 elseif  x==7   nLPC = 18;
 elseif  x==8   nLPC = 20;
 elseif  x==9   nLPC = 22;
 elseif  x==10  nLPC = 24;
 elseif  x==11  nLPC = 28;
 elseif  x==12  nLPC = 32;
 end
	
 pllpc(S0);

end





