function getslide

% Copyright (c) 1995 by Philipos C. Loizou
%

global sli En Be S0 S1 xp n_samples En2 Be2 TWOFILES TOP
global Srate2 n_Secs2


if TWOFILES==1 & TOP==1
nsamples=n_Secs2*Srate2;
if Be2>0 | En2<nsamples

x = get(sli,'Value');

if x<xp
	jnk1=x;
	x=-xp;
	xp=jnk1;
else
	xp=x;
end
if (Be2+x) > 0 & (En2+x) < nsamples
  S0=Be2+x;
end

if (En2+x)<nsamples 
  S1=En2+x;
else
  S1=nsamples;
  En2=S1;
  disp('End of file reached !')
end

%fprintf('S0=%d S1=%d\n',S0,S1);

zoomi('in');

end
else

if Be>0 | En<n_samples

x = get(sli,'Value');

if x<xp
	jnk1=x;
	x=-xp;
	xp=jnk1;
else
	xp=x;
end
if (Be+x) > 0 & (En+x) < n_samples
  S0=Be+x;
end

if (En+x)<n_samples 
  S1=En+x;
else
  S1=n_samples;
  En=S1;
  disp('End of file reached !')
end

%fprintf('S0=%d S1=%d\n',S0,S1);

zoomi('in');

end

end


