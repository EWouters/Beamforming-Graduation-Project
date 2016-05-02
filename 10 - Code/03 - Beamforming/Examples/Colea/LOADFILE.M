function loadfile(action)

% Copyright (c) 1995 by Philipos C. Loizou
%
global fno TIME cAxes 
global Srate filename HDRSIZE S1 S0 Be En nChannels filterA filterB al bl
global UpperFreq LowFreq center n_Secs WAV1 CLR TWOFILES filename2
global Srate2 HDRSIZE2 Be2 En2 n_Secs2  rld TOP
global al2 bl2 filterA2 filterB2 DiffSrate wav tspec   
global agcsc2 agcsc MAX_AM upFreq upFreq2
global htop hbot doit doit0 doit1 SrateChange singldisp
global bpsa bpsa2 ftype ftype2 LD_LABELS lbUp LD_LAB_FILE


 [pth,fname] = dlgopen('open','*.ils;*.wav');
 if ((~isstr(fname)) | ~min(size(fname))), return; end	
 fname2=[pth,fname];

doit=1; doit0=1; doit1=1;
DiffSrate=0;
BYTESAM=0;
rld=1;	% used in modify.m
WAV1=0;

if strcmp(action,'replace') % ============ Replace existing file ====================

	singldisp=1; fname_old=filename;
	filename=fname2; 
	fp2 = fopen(filename,'r');
 	if fp2 <=0
		disp('ERROR! File not found..')
		return;
 	end

	 ind=find(filename == '.');
	 ext = lower(filename(ind+1:length(filename))); 
 	 [xHDRSIZE, srat,xbpsa,xftype] =gethdr(fp2,ext);
	 if srat==0
	  filename=fname_old;
	  return; 
         else
	  bpsa=xbpsa; ftype=xftype; HDRSIZE=xHDRSIZE;
         end 


	 if Srate ~= srat
	  DiffSrate=1; 
	  SrateChange=1;
	 else
	  SrateChange=0; 
	 end;

	 Srate=srat;

        if Srate<6000 | Srate>45000
  	    disp('Warning! Sampling rate not in the range: 6,000 < F < 45,000');
  	    disp('...Setting it to the default value of 10,000 Hz.');
  	    Srate=10000;
	end 

	if Srate >= 2*5000, upFreq=2*5000/Srate; end;

 	
	x2  = fread(fp2,inf,ftype);
	 
	fclose(fp2); 

	  
 
	%----------remove the DC bias----
	
	x2= x2 - mean(x2);

	mx=max(x2);
	agcsc=MAX_AM/mx;


	n_samples = length(x2);
	n_Secs    = n_samples/Srate;

	S1=n_samples;
	S0=0;
	Be=S0;
	En=S1;
	fprintf('Samp.Freq: %d Hz,  num.samples: %d (%4.2f secs)\n',Srate,n_samples,n_Secs);
	
	if TWOFILES==1
	  nm=sprintf('Top: %s --- Bottom: %s',lower(filename2),lower(fname));
	  set(fno,'Name',nm);
	  TOP=0;
	  doit1=0;
	else
	  set(fno,'Name',lower(fname));
	end

	if LD_LABELS==1 % Clear existing labels
	   jnk=get(gcf,'Userdata');
	   delete(jnk);
  	   lbUp=[];
	   LD_LABELS=0;
	   LD_LAB_FILE=0;
	end
	zoomi('out');


else  %=======================Stack the two files on two windows==================



%---- Now get the 2nd file ------------------
 filename2=fname2;
 fp2 = fopen(filename2,'r');
 if fp2 <=0
	disp('ERROR! File not found..')
	return;
 end

 ind=find(filename2 == '.');
 ext = lower(filename2(ind+1:length(filename2))); 
 [HDRSIZE2,Srate2,bpsa2,ftype2] =gethdr(fp2,ext);
 
 if Srate2==0, Srate2=[]; bpsa2=[]; ftype2=[]; return; end;

 if Srate ~= Srate2, DiffSrate=1;  end;

        
 	
	 x2  = fread(fp2,inf,ftype2);

	fclose(fp2); 
 
 if Srate2<6000 | Srate2>45000
  disp(sprintf('\a')); % beep
  disp('Warning! Sampling rate not in the range: 6,000 < F < 45,000');
  disp('...Setting it to the default value of 10,000 Hz.');
  Srate2=10000;
end   
%----------remove the DC bias----
x2= x2 - mean(x2);

mx=max(x2);
agcsc2=MAX_AM/mx;



n_samples2 = length(x2);
n_Secs2    = n_samples2/Srate2;
S1=n_samples2;
S0=0;
Be2=0;
En2=n_samples2;


fprintf('TOP FILE:  Samp.Freq: %d Hz,  num.samples: %d (%4.2f secs)\n',Srate2,n_samples2,n_Secs2);
fprintf('BOTTOM FILE: Samp.Freq: %d Hz,  num.samples: %d (%4.2f secs)\n',Srate,n_Secs*Srate,n_Secs);

if TWOFILES==1
 TOP=1;
 zoomi('out');
else
 TWOFILES=1; 
 TOP=1; zoomi('out');
 TOP=0; zoomi('out');
end

figure(fno);

set(fno,'Name',filename);


end % of if replace file


%==================================================================
if DiffSrate == 1  % then re-design the filters

 if strcmp(action,'replace')
   [bl,al]=butter(2,400/(Srate/2));  % 400 Hz Low-Pass filter
   setchan(nChannels);
 else

  FS=Srate2/2;
  nOrd=6;
  [bl2,al2]=butter(2,400/(Srate2/2));  % 400 Hz Low-Pass filter
	
  range=log10(UpperFreq/LowFreq);
  interval=range/nChannels;
   
  center=zeros(1,nChannels); upper1=zeros(1,nChannels);
  lower1=zeros(1,nChannels);

  for i=1:nChannels  % ----- Figure out the center frequencies for all channels
	upper1(i)=LowFreq*10^(interval*i);
	lower1(i)=LowFreq*10^(interval*(i-1));
	center(i)=0.5*(upper1(i)+lower1(i));
  end


  if FS<upper1(nChannels), useHigh=1;
  else			 useHigh=0;
  end

     for i=1:nChannels
	W1=[lower1(i)/FS, upper1(i)/FS];
	if i==nChannels
	  if useHigh==0
	     [b,a]=butter(3,W1);
	  else
	     [b,a]=butter(6,W1(1),'high');
	  end
	else
	   [b,a]=butter(3,W1);
	end
	filterB2(i,1:nOrd+1)=b;   %----->  Save the coefficients 'b'
	filterA2(i,1:nOrd+1)=a;   %-----> Save the coefficients 'a'
    end
  end % of if replace
else
	filterB2=filterB; filterA2=filterA;
	bl2=bl; al2=al;
end

if strcmp(action,'stack')
 nm=sprintf('Top: %s --- Bottom: %s',lower(fname),filename);
 set(fno,'Name',nm);
end
