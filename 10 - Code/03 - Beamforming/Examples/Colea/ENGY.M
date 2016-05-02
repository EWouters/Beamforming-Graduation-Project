function engy

% Copyright (c) 1995 Philipos C. Loizou
%
global nChannels filename filterA filterB Srate eFig
global HDRSIZE S0 S1 ratePps En Be bl al WAV1 n_Secs En2 Be2
global filename2 TWOFILES n_Secs2 Srate2 TOP HDRSIZE2
global ftype ftype2 bpsa bpsa2

pos = get(0, 'screensize'); % get the screensize
sWi = pos(3);
sHe = pos(4);




rate=200;

WIDTH   =round(0.9375*sWi);
HEIGHT = round(0.5*sHe);
LEFT    =round(0.025*sWi);
BOTTOM  =20; 

if TWOFILES==1 & TOP==1
 fname=filename2;
 hdr=HDRSIZE2;
 n_samples=En2-Be2; %round(n_Secs2*Srate2)
 strt=Be2;
 offSet=strt*bpsa2+hdr;
 ftp=ftype2;
else
 fname=filename;
 hdr=HDRSIZE;
 n_samples=En-Be; %round(n_Secs*Srate)
 strt=Be;
 offSet=strt*bpsa+hdr;
 ftp=ftype;
end

fp = fopen(fname,'r');

if fp <=0
	disp('ERROR! File not found..')
	return;
end

	
	
		
	st = fseek(fp,offSet,'bof');
        x=zeros(1,n_samples);
	x = fread(fp,n_samples,ftp);
	
	fclose(fp);
%---- Do some error checking on the signal level ---
meen=mean(x);
x= x - meen; %----------remove the DC bias---


nmF='Energy Plot';


if (isempty(eFig))	
	eFig =  figure('Units', 'Pixels', 'Position', [LEFT BOTTOM WIDTH HEIGHT],...
	'Pointer','crosshair',...
	'Resize','on','Name',nmF,'NumberTitle','Off');

else
	figure(eFig);
	set(eFig,'Name',nmF);
end



fRate=round(Srate/rate);  %--- Number of  samples in each frame

nFrames=floor(n_samples/fRate);
	

zcnt=zeros(1,nFrames);
ampl=zeros(1,nFrames);
k=1;
for t=1:nFrames
		yin=x(k:k+fRate-1);
		eng(t)=10*log10(norm(yin,2));
		zc=0;
		x2=zeros(fRate,1);
	        x2(1:fRate-1)=yin(2:fRate);
	        zc=length(find((yin>0 & x2<0) | (yin<0 & x2>0))); %-- Zero Crossings	      
	        zcnt(t)=zc;
		%f0=pitch(yin);
		%pit(t)=f0;
	
k=k+fRate;
    
end


%--- Plot energy, zero crossings, and waveform -----------
subplot(2,1,1),plot(eng);
set(gca,'Xlim',[0 nFrames-1]);
ylabel('dB');
%subplot(3,1,2),plot(pit);
%set(gca,'Xlim',[0 nFrames-1]);
%ylabel('#zc');
subplot(2,1,2),plot(x);
set(gca,'Xlim',[0 n_samples-1]);
ylabel('Ampl.');
xlabel('Samples');
