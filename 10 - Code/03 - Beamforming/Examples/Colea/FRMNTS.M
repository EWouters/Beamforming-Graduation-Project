function [F1,F2, F3]=frmnts(a,srat)

% The formants are computed by solving for the roots of the LPC polynomial 
%

% Copyright (c) 1998 by Philipos C. Loizou
%

global f1p f2p f3p

 const=srat/(2*pi);
 rts=roots(a);
 k=1;

 for i=1:length(a)-1
	re=real(rts(i)); im=imag(rts(i));
	formn=const*atan2(im,re);      %--formant frequencies
	bw=-0.5*const*log(abs(rts(i)));%--formant bandwidth
	if formn>90 & bw <500 & formn<4000
		save(k)=formn;
		bandw(k)=bw;
		k=k+1;
	end
		
 end
 
 
if length(save)>=2
   [y, ind]=sort(save);
else
   F1=f1p; F2=f2p; F3=f3p;
   fprintf('\nWarning! The LPC order in frmtns.m might be too small for this sampling frequency.\n\n');
   return;
end
   



%----Impose some formant continuity constraints -------------------

leny=length(y);
if leny==2, only2=1; else only2=0; end;

in1=[]; in2=[];

if ~isempty(f1p)
 in1=find(abs(f1p-y)<150);
 in2=find(abs(f2p-y)<150);
 if length(in1)>1, i1=in1(2); else, i1=in1; end;
 if length(in2)>1, i2=in2(2); else, i2=in2; end;

 
 if ~isempty(i1) & ~isempty(i2) 
    if i1==i2
	 F1=y(1); F2=y(2); if only2==1, F3=f3p; else F3=y(3); end; 
    else
      F1=y(i1); F2=y(i2); 
      if i2+1 > leny, F3=f3p; else, F3=y(i2+1); end;
     
    end;
  elseif ~isempty(i1) & isempty(i2)
    F1=y(i1); F2=y(i1+1); 
    if i1+2 > leny, F3=f3p; else, F3=y(i1+2); end;
    
  else
   F1=y(1); F2=y(2); 
   if only2==1,    F3=f3p; 
   else		   F3=y(3);
   end
  
  end

 
else %++++++++++++++++ the first time ++++++++++++++++++
 if only2==1
   F1=300; F2=1200; F3=3000;
 elseif abs(y(1)-y(2))<80
   F1=y(2); F2=y(3); if leny>3, F3=y(4); else, F3=3000; end; 
 elseif leny==4
   F1=y(2); F2=y(3); F3=y(4);
 else
   F1=y(1); F2=y(2); 
   if only2==1,    F3=3000; 
   else		 F3=y(3);
   end
 end
end

% --last check .. --------
if abs(F2-F3)<50
  	F2=f2p; F3=f3p;
end

if abs(F2-F1)<50
	F2=f2p; F3=f3p;
end
  

%y(1:leny)
%fprintf('%4.2f %4.2f %4.2f\n',F1,F2,F3);
f1p=F1; f2p=F2; f3p=F3;


	
