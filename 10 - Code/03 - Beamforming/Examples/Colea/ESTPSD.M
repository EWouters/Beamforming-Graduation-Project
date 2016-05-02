function estpsd(type)

% Copyright (c) 1995 Philipos C. Loizou
%

global nChannels filename Srate eFig
global HDRSIZE S0 S1 ratePps En Be  n_Secs En2 Be2
global filename2 TWOFILES n_Secs2 Srate2 TOP HDRSIZE2 
global bpsa bpsa2 ftype ftype2 bf0 af0 SrateChange





if TWOFILES==1 & TOP==1
 fname=filename2;
 hdr=HDRSIZE2;
 n_samples=En2-Be2; 
 strt=Be2;
 sr=Srate2;
 offSet = strt*bpsa2+hdr;
 ftp=ftype2;
else
 fname=filename;
 hdr=HDRSIZE;
 n_samples=En-Be; %round(n_Secs*Srate)
 strt=Be;
 sr=Srate;
 offSet = strt*bpsa+hdr;
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


figure(11);
psd(x,512,sr,[],256);


