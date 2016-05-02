function [avgF0, f01] = getf0 (sr,x)

% Copyright (c) 1995 Philipos C. Loizou
%

n_samples=length(x);

fRate=floor(40*sr/1000);  % -- Use a 40 msec segment
nFrames=floor(2*n_samples/fRate); 
	
k=1;
f01=zeros(1,nFrames-1);
f0=zeros(1,nFrames-1);
m=1;
avgF0=0.0;
for t=1:nFrames-1
		yin=x(k:k+fRate-1);
		
		a=pitch(fRate,sr,yin);
		f0(t)=a;
		if t>2 %--do some median filtering
		  z=f0(t-2:t);
		  md=median(z);
		  f01(t-2)=md;
		end

		if a > 0
		  avgF0=avgF0+a;
		  m=m+1;
		end
	
k=k+fRate/2;
    
end

avgF0=avgF0/m;

