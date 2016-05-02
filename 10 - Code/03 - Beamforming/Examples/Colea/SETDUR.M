function setdur

% Copyright (c) 1995 Philipos C. Loizou
%

global Dur DurUp S0 Srate Srate2 TOP TWOFILES

x = get(DurUp,'Value');

if (x >= 1 & x ~=6 )

   if     x<=5, Dur=x*10; 
   elseif  x==7
	    if TWOFILES==1 & TOP==1
		Dur=64*1000/Srate2;
	    else
		Dur=64*1000/Srate;
	    end
   elseif  x==8
	    if TWOFILES==1 & TOP==1
		Dur=128*1000/Srate2;
	    else
		Dur=128*1000/Srate;
	    end
 elseif  x==9
	    if TWOFILES==1 & TOP==1
		Dur=256*1000/Srate2;
	    else
		Dur=256*1000/Srate;
	    end
 elseif  x==10
	    if TWOFILES==1 & TOP==1
		Dur=512*1000/Srate2;
	    else
		Dur=512*1000/Srate;
	    end
 end	

 pllpc(S0);

end





