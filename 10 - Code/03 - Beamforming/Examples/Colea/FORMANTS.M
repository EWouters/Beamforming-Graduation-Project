function [F0, F1, F2, A1, A2]=formants(inp)

% For details see: Blamey et al., JASA 82, pp.38-47, July 1987.
% 
% Copyright (c) 1995 by Philipos C. Loizou
%

global  Srate b35 a35 b0 a0 b1 a1 b1h a1h b2 a2 f1p f2p f0p a1p a2p
global  SrateChange

nSamples=length(inp);

alpha=0.1;  % used in the LPF for smoothing
%--------------- F0 estimation ------------------------------

xin=abs(inp);	%--Full-wave rectification
if isempty(b0)| SrateChange==1
	[b0,a0]=butter(2,270/(Srate/2));
	f1p=0; f2p=0; f0p=0; a1p=0; a2p=0;
	[b35,a35]=butter(1,35/(Srate/2));	
end

xin=filter(b0,a0,xin);
xin=xin-mean(xin);
x2=zeros(nSamples,1);
x2(1:nSamples-1)=xin(2:nSamples);
zc=length(find((xin>0 & x2<0) | (xin<0 & x2>0))); %-- Zero Crossings


F0=0.5*Srate*zc/nSamples;


%fprintf('F0: Zc=%d EF0=%f\n',zc,0.5*Srate*zc/nSamples)


%--------------- F1 estimation ---------------------------------
xin=inp-mean(inp);
 if (isempty(b1))
	[b1,a1]=butter(2,850/(Srate/2));          % LPF @ 850 Hz
 end

xin=filter(b1,a1,xin);
if isempty(b1h) | SrateChange==1
	[b1h,a1h]=butter(1,480/(Srate/2),'high');  % HPF @ 480 Hz
end
xin=filter(b1h,a1h,xin);

A1=10*log10(max(xin));
A1=A1+alpha*a1p;
a1p=A1;

x2=zeros(nSamples,1);
x2(1:nSamples-1)=xin(2:nSamples);
zc=length(find((xin>0 & x2<0) | (xin<0 & x2>0))); %-- Zero Crossings

F1=0.5*Srate*zc/nSamples;
F1=F1+alpha*f1p;

f1p=F1;
%fprintf('F1: Zc=%d EF1=%f\n',zc,0.5*Srate*zc/nSamples)


%--------------- F2 estimation ---------------------------------
Blamey=0;
if Blamey==1
th1=850*pi/(Srate/2);
ij=sqrt(-1);
ta=tan(th1);
sc=1/sqrt(2);
re=sc/sqrt(1+ta*ta); im=sc*ta/sqrt(1+ta*ta);
rt1=re+ij*im;
%atan(im/re)*180/pi
%norm([re im])

th2=1000*pi/(Srate/2);
ta=tan(th2);
re2=sc/sqrt(1+ta*ta); im2=sc*ta/sqrt(1+ta*ta);
rt2=re2+ij*im2;
p=poly([rt1 conj(rt1) rt2 conj(rt2)]);
%roots(p)
%freqz(p,1,512,12000);
%pause
end

xin=inp-mean(inp);


if isempty(b2) | SrateChange==1
	[b2,a2]=butter(4,1000/(Srate/2),'high');
end
xin=filter(b2,a2,xin);

A2=10*log10(max(xin));
A2=A2+alpha*a2p;
a2p=A2;

x2=zeros(nSamples,1);
x2(1:nSamples-1)=xin(2:nSamples);
zc=length(find((xin>0 & x2<0) | (xin<0 & x2>0))); %--- Zero crossings

%zc=0;
%for i=1:nSamples-1
%   if (xin(i)>0 & xin(i+1)<0) |  (xin(i)<0 & xin(i+1)>0)
%	zc=zc+1;
%   end
%    
%end

F2=0.5*Srate*zc/nSamples;
F2=F2+alpha*f2p;
f2p=F2;
%fprintf('F2: Zc=%d EF2=%f\n',zc,0.5*Srate*zc/nSamples)

if SrateChange==1, SrateChange=0; end; % reset
