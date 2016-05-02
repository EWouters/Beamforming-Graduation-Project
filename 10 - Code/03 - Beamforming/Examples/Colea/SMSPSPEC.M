function smspspec

% Copyright (c) 1995 by Philipos C. Loizou
%

global  filename Srate fno nLPC  nChannels UpperFreq
global filterWeights HDRSIZE center LPCSpec F Dur  Lfreq
global spFig Asmsp Bsmsp centSMSP S0 bls als smspEc
global bpsa bpsa2 ftype ftype2 HDRSIZE2 filename2 TWOFILES TOP

nCh=16;
nBa=6;
fftSize=512;

smspEc=1;
pos = get(0, 'screensize'); % get the screensize
sWi = pos(3);
sHe = pos(4);

wi=round(0.5625*sWi);
he=round(0.4*sHe);
le=round((sWi-wi)/2);

if TWOFILES==1 & TOP==1
  fname=filename2;
  offSet = S0*2+HDRSIZE2;
  ftp=ftype2;
else
 fname=filename;
 offSet = S0*2+HDRSIZE;
 ftp=ftype;
end


nSamples=round(Dur*Srate/1000);  % get the number of samples to read

fp = fopen(fname,'r');

st = fseek(fp,offSet,'bof');
inp = fread(fp,nSamples,ftp);
fclose(fp);
%----------- Remove the DC bias------------
inp=inp-mean(inp);


if  isempty(spFig)
  spFig = figure('Units', 'pixels', 'Position', [le 9 wi he]);
else
  figure(spFig);
end

Winp=inp;
%  fwin = filter([1 -3000/5500],[1 -1200/5500],Winp);
%  Winp=fwin;



fft2=fftSize/2;

set(spFig,'Units','Pixels','SelectionType','normal');
	

fftFreqs = (0:fft2-1)/fftSize*Srate;
if (LPCSpec == 1) 
    a = lpc(hamming(nSamples).*inp,nLPC); 
    [H,F]= freqz(1,a,fftSize,Srate);
end
    fd=zeros(fftSize,1);
    fd(1:nSamples)=Winp;
    fd2= abs(fft((fd)));   
    fftMag = fd2(1:fft2);    

%-------- Compute the filterbanks------------------------
nOrd=6;

Lfreq=centSMSP(nCh);

for i=1:nCh
	y=filter(Bsmsp(i,1:nOrd+1),Asmsp(i,1:nOrd+1),Winp);
	y1=filter(bls,als,abs(y));
	fbank2(i)=10*log10(norm(y1,2));
end

%---------- Select the 6 maximum-----------------

[srt_fb,ind]=sort(fbank2);
ind0=ind(11:nCh);
[ind3, ind2]=sort(ind0);
for j=1:6
	srt(j)=fbank2(ind3(j));
	ind1(j)=centSMSP(ind3(j));
	
end

    if (LPCSpec==1)
	fftFreqs = 0.5*(0:fftSize-1)/fftSize*Srate;
	fftMag=abs(H);
    end
    dBMag = 10*log10(fftMag);
    subplot(2,1,1), plot(fftFreqs,dBMag)
    axis([0 Lfreq min(dBMag) max(dBMag)])
    xlabel('Freq. (Hz)','FontSize',5);
    ylabel('Ampl. (dB)','FontSize',8);
    set(gca,'FontSize',8');
    subplot(2,1,2), plot(centSMSP,fbank2,'-',ind1,srt,'ro');
    
    axis([0 Lfreq min(fbank2) max(fbank2)])
    xlabel('Freq. (Hz)','FontSize',6);
    ylabel('Ampl.(dB)','FontSize',8);
    set(gca,'FontSize',8');



figure(fno);

