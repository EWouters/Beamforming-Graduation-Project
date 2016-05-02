function [F0, F1, F2, A1, A2, A3, A4, A5, voiced]=formpe(inp)

% For details see: Blamey et al., JASA 82, pp.38-47, July 1987.
% 
% Copyright (c) 1995 by Philipos C. Loizou
%

global  Srate b35 a35 b0 a0 b1 a1 b1h a1h b2 a2 f1p f2p f0p a1p a2p
global  SrateChange b0v a0v b0un a0un
global  a3 b3 a4 b4 a5 b5

nSamples=length(inp);

%--If there is a Srate change, re-design the filters
%

alpha=0.1;  % used in the LPF for smoothing
%--------------- F0 estimation ------------------------------
%- Reference: O. Gruenz and L. Schott (1949), JASA, vol.21, pp. 487-495
%
xin=abs(inp);	%--Full-wave rectification
if isempty(b0) | SrateChange==1
	Srate2=Srate/2;
	[b0,a0]=butter(2,270/Srate2);
	f1p=0; f2p=0; f0p=0; a1p=0; a2p=0;
	[b35,a35]=butter(1,200/Srate2);	
	[b0v a0v]=butter(3,[150/Srate2 900/Srate2]);
	[b0un a0un]=butter(3,4000/Srate2,'high');
end

xin=filter(b0,a0,xin);
xin=xin-mean(xin);
x2=zeros(nSamples,1);
x2(1:nSamples-1)=xin(2:nSamples);
zc=length(find((xin>0 & x2<0) | (xin<0 & x2>0))); %-- Zero Crossings


F0=0.5*Srate*zc/nSamples;

%--- Estimate energy in 150-900 Hz range--- (see p. 491, Gruenz et al.)
x0=inp-mean(inp);
x1=filter(b0v,a0v,x0);
x1=filter(b35,a35,abs(x1));
Ev=norm(x1,2)/nSamples;

% -- estimate energy above 4000 Hz --------(see p. 491, Gruenz et al.)
x2=filter(b0un,a0un,x0);
x2=filter(b35,a35,abs(x2));
Eunv=norm(x2,2)/nSamples;

if Ev>Eunv, voiced=1; else voiced=0; end
%fprintf('F0=%f Ev=%f Eunv=%f: %d\n',F0,Ev,Eunv,voiced);

%fprintf('F0: Zc=%d EF0=%f\n',zc,0.5*Srate*zc/nSamples)


%--------------- F1 estimation ---------------------------------
xin=inp-mean(inp);
 if (isempty(b1) | SrateChange==1)
	[b1,a1]=butter(2,1000/(Srate/2));          % LPF @ 1000 Hz
 end

xin=filter(b1,a1,xin);
if isempty(b1h)
	[b1h,a1h]=butter(1,280/(Srate/2),'high');  % HPF @ 280 Hz
end
xin=filter(b1h,a1h,xin);

A1=norm(xin,2);
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

xin=inp-mean(inp);


if isempty(b2) | SrateChange==1
	w1=[800*2/Srate 4000*2/Srate];
	[b2,a2]=butter(4,w1);
end
xin=filter(b2,a2,xin);

A2=norm(xin,2);
A2=A2+alpha*a2p;
a2p=A2;

x2=zeros(nSamples,1);
x2(1:nSamples-1)=xin(2:nSamples);
zc=length(find((xin>0 & x2<0) | (xin<0 & x2>0))); %--- Zero crossings



F2=0.5*Srate*zc/nSamples;
F2=F2+alpha*f2p;
f2p=F2;
%fprintf('F2: Zc=%d EF2=%f\n',zc,0.5*Srate*zc/nSamples)

if SrateChange==1, SrateChange=0; end; % reset

%---------------Estimate amplitudes in Bands 3-5 --------------------

xin=inp-mean(inp);  %	 ============ A3 ============
if isempty(b3) | SrateChange==1
	w1=[2000*2/Srate 2800*2/Srate];
	[b3,a3]=butter(4,w1);
end
xin=filter(b3,a3,xin);

A3=norm(xin,2);
		
xin=inp-mean(inp);  %	 ============ A4 ============
if isempty(b4) | SrateChange==1
	w1=[2800*2/Srate 4000*2/Srate];
	[b4,a4]=butter(4,w1);
end
xin=filter(b4,a4,xin);

A4=norm(xin,2);
		
xin=inp-mean(inp); %	 ============ A5 ============			
if isempty(b5) | SrateChange==1
	w1=[4000*2/Srate 6000*2/Srate];
	[b5,a5]=butter(4,w1(1),'high');
end
xin=filter(b5,a5,xin);

A5=norm(xin,2);



