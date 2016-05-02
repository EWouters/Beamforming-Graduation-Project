function [F0]=pitch(inp)

global  Srate bf0 af0


nSamples=length(inp);

alpha=0.1;  % used in the LPF for smoothing
%--------------- F0 estimation ------------------------------

xin=abs(inp);
if ~exist('bf0')
	[b0,a0]=butter(2,900/(Srate/2));
end

xin=filter(b0,a0,xin);
xin=xin-mean(xin);
x2=zeros(nSamples,1);
x2(1:nSamples-1)=xin(2:nSamples);
zc=length(find((xin>0 & x2<0) | (xin<0 & x2>0))); 


F0=0.5*Srate*zc/nSamples;

