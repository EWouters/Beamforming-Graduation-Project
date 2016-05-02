function apfilter(type,action)

% Copyright (c) 1995 Philipos C. Loizou

global nChannels filename bvi avi Srate upFreq
global HDRSIZE S0 S1  En Be Dur n_Secs MAX_AM fno
global HDRSIZE2 Srate2 n_Secs2 filename2 TOP TWOFILES agcsc2
global fcLPF nuLPF fcHPF nuHPF fc1BPF  fc2BPF nuBPF ftype2 ftype bpsa bpsa2 


if strcmp(action,'view') % =============== VIEW FILTER RESPONSE ==============

   if strcmp(type,'LPF')

	  figure(10);
	  f=2*fcLPF/Srate;
	  [b,a]=butter(nuLPF,f);
	  [h,fr]=freqz(b,a,512,Srate);
	  plot(fr,10*log10(abs(h)));
	  xlabel('Freq. (Hz)'); ylabel('dB');
   elseif strcmp(type,'HPF')

	  figure(10);
	  f=2*fcHPF/Srate;
	  [b,a]=butter(nuHPF,f,'high');
	  [h,fr]=freqz(b,a,512,Srate);
	  plot(fr,10*log10(abs(h)));
	  xlabel('Freq. (Hz)'); ylabel('dB');
   else
	   figure(10);
	   w=[2*fc1BPF/Srate 2*fc2BPF/Srate];
	   [b,a]=butter(nuBPF,w);
	   [h,fr]=freqz(b,a,512,Srate);
	   plot(fr,10*log10(abs(h)));
	   xlabel('Freq. (Hz)'); ylabel('dB');
   end

else % ======================== APPLY FILTER============================

if En < Be  % --- Check to see if the segment selected is valid -----
  errordlg('Invalid segment selected: left mark is greater than right','ERROR in Filter Tool','on');
  return;
end


fp = fopen(filename,'r');

if fp <=0
	disp('ERROR! File not found..')
	return;
end

	hdr=fread(fp,HDRSIZE/2,'short');
	x = fread(fp,inf,ftype);	
	n_samples=length(x);
	fclose(fp);

	

meen=mean(x);
x= x - meen; %----------remove the DC bias---


%-------------Filter the signal ------------------------------------
%
	if strcmp(type,'LPF')
	    f=2*fcLPF/Srate;
	    [b,a]=butter(nuLPF,f);
  	 elseif strcmp(type,'HPF')
	    f=2*fcHPF/Srate;
	    [b,a]=butter(nuHPF,f,'high');
  	 else % its BPF
	    w=[2*fc1BPF/Srate 2*fc2BPF/Srate];
	    [b,a]=butter(nuBPF,w);
	 end
 	
	y=zeros(1,En-Be-1);
	y=x(Be+1:En-1);
	ebe= norm(y,2);
 	y = filter(b,a,y);
	eaf=norm(y,2);
	scale=(ebe/eaf); % ---- Scale so that the filtered signal has same energy as original
	x(Be+1:En-1)=scale*y;

%------------ Save filtered signal and initialize variables for dual display----

 ind=find(filename == '.');
 ext = lower(filename(ind+1:length(filename))); 
 newname3=['filtered.' ext];

 if strcmp(newname3,filename)==1
    newname3=['filter1.' ext]
 end

fpout=fopen(newname3,'w');
fwrite(fpout,hdr,'short');
fwrite(fpout,x,'short');
fclose(fpout);	


filename2=newname3;
Srate2=Srate;
n_Secs2=n_Secs;

mx=max(x);
agcsc2=MAX_AM/mx;


TWOFILES=1;
TOP=1;
HDRSIZE2=HDRSIZE;
ftype2='short';
bpsa2=2;
zoomi('out');
TOP=0;
if Srate >= 2*5000, upFreq=2*5000/Srate; end;
zoomi('out');


 nm=sprintf('Top: %s --- Bottom: %s',lower(filename2),filename);
 set(fno,'Name',nm);

end
