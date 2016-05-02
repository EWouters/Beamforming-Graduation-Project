function singen

% Copyright (c) 1995 Philipos C. Loizou

global  filename sinFr sinDur sinAmp  Srate  fno
global TWOFILES n_Secs MAX_AM ftype bpsa agcsc singldisp cAxes AXISLOC
global htop hbot HDRSIZE

nsam=round(Srate*sinDur/1000);


x=sinAmp*sin(2*pi*sinFr*[0:nsam-1]/Srate);

fprintf('..creating a %6.2f Hz tone\n',sinFr);


% --- taper the sinewave at endpoints -------------
%
tdurs=round(10.0*Srate/1000); % duration of tapering
taper=hamming(2*tdurs)';
x(1:tdurs)=x(1:tdurs).*taper(1:tdurs);
x(nsam-tdurs+1:nsam)=x(nsam-tdurs+1:nsam).*taper(tdurs+1:2*tdurs);

%--save the sine wave in .ils format -----


hdr=zeros(1,256);
hdr(6)=floor(nsam/256);
hdr(62)=Srate;

fp = fopen('modsin.ils','w');

fwrite(fp,hdr,'short');	
fwrite(fp,x,'short');


fclose(fp);

filename='modsin.ils';
n_Secs=sinDur/1000;

mx=sinAmp;
agcsc=MAX_AM/mx;

HDRSIZE=512;

ftype='short';
bpsa=2;

if TWOFILES==1
	figure(fno);
	h11=subplot(1,1,1);
	set(h11,'Visible','off');
	cAxes = axes('Units','Pixels','Position',AXISLOC);
	singldisp=1; % used in modify.m
	TWOFILES=0;
	hbot=[]; htop=[];
	zoomi('out');
else

       zoomi('out');
end
