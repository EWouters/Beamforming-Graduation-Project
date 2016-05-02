function [filtA,filtB,centr]= design(numch)

% Copyright (c) 1995 by Philipos C. Loizou
%

global LowFreq UpperFreq  Srate filterA filterB


%LowFreq=300;
%UpperFreq=5500;
%Srate=12000;

FS=Srate/2;
DBG=0;
if DBG==1, figure(10); end;
numch2=2*numch;

nOrd=10;
	
range=log10(UpperFreq/LowFreq);
interval=range/numch;

cen=zeros(1,numch);
up=zeros(1,numch2);
low=zeros(1,numch2);
centr=zeros(1,numch2);
k=1;
for i=1:numch  % ----- Figure out the center frequencies for all channels
	upper1(i)=LowFreq*10^(interval*i);
	lower1(i)=LowFreq*10^(interval*(i-1));
	cen(i)=0.5*(upper1(i)+lower1(i));
	low(k)=lower1(i); low(k+1)=cen(i);
	up(k)=cen(i); up(k+1)=upper1(i);
	k=k+2;
end
%-----
centr=0.5*(low+up);


if FS<up(numch2), 	 useHigh=1;
else			 useHigh=0;
end

filtA=zeros(numch2,nOrd+1); 
filtB=zeros(numch2,nOrd+1); 

if DBG==1
   subplot(2,1,1);
	for i=1:6
	 b=filterB(i,:); a=filterA(i,:);
         [h,f]=freqz(b,a,512,Srate);
	 semilogx(f,10*log10(abs(h)),'m');
	 axis([100 FS -50 5]);
	 hold on
	end
	ylabel('Amplitude (dB)');
	set(gca,'Box','off');
	subplot(2,1,2); 
	
end;

 for i=1:numch2
	W1=[low(i)/FS, up(i)/FS];
	if i==numch2
	  if useHigh==0
	     [b,a]=butter(nOrd/2,W1);
	  else
	     [b,a]=butter(nOrd,W1(1),'high');
	  end
	else
	   [b,a]=butter(nOrd/2,W1);
	end
	filtB(i,1:nOrd+1)=b;   %----->  Save the coefficients 'b'
	filtA(i,1:nOrd+1)=a;   %-----> Save the coefficients 'a'

	%if i<=numch
	 % [b2,a2]=butter(nOrd/2,[lower1(i)/FS upper1(i)/FS]);
	 % [h2,f2]=freqz(b2,a2,512,Srate);
	 % plot(f2,10*log10(abs(h2)),'r-');
	 % hold on
	%end

	if  DBG==1
	 [h,f]=freqz(b,a,512,Srate);
	 semilogx(f,10*log10(abs(h)),'m');
	 axis([100 FS -50 5]);
	 hold on
	 ylabel('Amplitude (dB)');
	 xlabel('Frequency (Hz)');
	 set(gca,'Box','off');
	end
  end



