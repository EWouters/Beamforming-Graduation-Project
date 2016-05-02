function [lower1, center, upper1]= centfreq(n,low,high)

% Divides the spectrum into n bands equally spaced logarithmically
%

% Copyright (c) 1995 Philipos C. Loizou
%

LowFreq     =low;
UpperFreq   =high;
range=log10(UpperFreq/LowFreq);
interval=range/n;


for i=1:n  % ----- Figure out the center frequencies for all channels
	upper1(i)=LowFreq*10^(interval*i);
	lower1(i)=LowFreq*10^(interval*(i-1));
	center(i)=0.5*(upper1(i)+lower1(i));
end


