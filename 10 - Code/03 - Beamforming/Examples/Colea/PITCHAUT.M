function [f0] = pitchaut(len,sr,xin)

% Pitch estimation using the autocorrelation method

% Copyright (c) 1995 Philipos C. Loizou
%

global bf0 af0 



xin=filter(bf0,af0,xin);  % LPF at 900 Hz

%-----------find the clipping level, CL -----------

i13=floor(len/3);
maxi1=max(abs(xin(1:i13)));

i23=floor(2*len/3);
maxi2=max(abs(xin(i23:len)));

if maxi1>maxi2, CL=0.68*maxi2; else CL= 0.68*maxi1; end;

%----------Center clip waveform, and compute the autocorrelation  -----------------------

clip=zeros(len,1);
ind1=find(xin>=CL);
clip(ind1)=xin(ind1)-CL;

ind2=find(xin <= -CL);
clip(ind2)=xin(ind2)+CL;

engy=norm(clip,2)^2;

RR=xcorr(clip);
m=len;


%-------Find the max autocorrelation in the range 60 <= f <= 320 Hz ------------
%
LF=floor(sr/320); 
HF=floor(sr/60);

Rxx=abs(RR(m+LF:m+HF));
[rmax, imax]= max(Rxx);

imax=imax+LF;
f0=sr/imax;


%------------ Check max RR against V/UV threshold ----------------------------
silence=0.4*engy;


if (rmax > silence)  & (f0 > 60) & (f0 <=320)
 f0=sr/imax;
else % -- its unvoiced segment ---------
 f0=0;
end










