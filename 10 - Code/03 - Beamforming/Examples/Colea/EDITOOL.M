function editool(action,psample)

% Copyright (c) 1995 by Philipos C. Loizou
%

global S0 S1 filename filename2 Srate fno fftSize n_Secs
global HDRSIZE cAxes En Be TIME WAV1 CLR TWOFILES En2 Be2 TOP 
global HDRSIZE2 n_Secs2 Srate2 sli wav fpmod fpmod2 singldisp rld
global newname newname2 agcsc agsc2 MAX_AM fed lastS0 lastTOP
global cutvec modChange bpsa bpsa2 ftype ftype2 adsOp fedun


zm=0;

if isempty(cutvec) & strcmp(action,'paste')==1
	errordlg('Nothing to paste','ERROR','on');
	return;
end

 
if (S1 > S0) | (strcmp(action,'paste')==1)
	figure(fno);
	if TWOFILES==0, axes(cAxes); end
	 
		 
	if nargin==2 & strcmp(action,'paste') & TWOFILES==1 % case undo
	   TOP=lastTOP;
	end

	  if TWOFILES==1 & TOP==1
	     if isempty(fpmod2) | rld==1
		fp = fopen(filename2,'r');
	  	x=fread(fp,inf,ftype2); oldfile=filename2;
		  ind=find(filename2 == '.');
  		   ext = lower(filename2(ind+1:length(filename2))); 
		   newname2=['mod2.' ext];
	  	fpmod2 = fopen(newname2,'w+');
	  	fwrite(fpmod2,x,ftype2);
	  	filename2=newname2;
	  	fclose(fpmod2); fclose(fp);
	  	fpmod2 = fopen(newname2,'r+');
		rld=0;
	     else
		fpmod2 = fopen(newname2,'r+');
	     end
	   else % single file or bottom window selected
		if isempty(fpmod) | singldisp==1
		  fp = fopen(filename,'r');
	  	  x=fread(fp,inf,ftype);
		   ind=find(filename == '.');
  		   ext = lower(filename(ind+1:length(filename))); 
		   newname=['mod1.' ext];
	  	  fpmod = fopen(newname,'w+');
	  	  fwrite(fpmod,x,ftype); oldfile=filename;
	  	  filename=newname;
	  	  fclose(fpmod); fclose(fp);
	  	  fpmod = fopen(newname,'r+');
		  singldisp=0;
		else
		  fpmod = fopen(newname,'r+');
	        end
	    end
	  
	if S0==0, S0=1; end % this is to avoid matrix index of 0
	nSamples=S1-S0;	    % get the number of samples to read

	

	if TWOFILES==1 & TOP==1	
	  ind=find(filename2 == '.');
  	  ext = lower(filename2(ind+1:length(filename2))); 
	 hdr=fread(fpmod2,HDRSIZE2/2,'short');
	 inp =fread(fpmod2,inf,ftype2);
	 inpNS=length(inp);
	 fclose(fpmod2);
	 fpmod2 = fopen(newname2,'w+');
	 sfreq=Srate2;
	else
	  ind=find(filename == '.');
  	  ext = lower(filename(ind+1:length(filename))); 
	  hdr=fread(fpmod,HDRSIZE/2,'short');
	  inp =fread(fpmod,inf,ftype);
	  inpNS=length(inp);
	  fclose(fpmod);
	  fpmod = fopen(newname,'w+');
	  sfreq=Srate;
	end
	

	
      
	if strcmp(action,'cut') % ========== CUT ==============
	  NsamNew=inpNS-nSamples+1;
	  if NsamNew<5
		errordlg('No region has been selected','ERROR','on');
		edinp=inp;
		zm=0;
	  else
	   edinp = zeros(1,NsamNew);
	   edinp(1:S0)=inp(1:S0);
	   edinp(S0+1:NsamNew)=inp(S1:inpNS);
	   if TOP==1, n_Secs2=NsamNew/Srate2;
	   else	     n_Secs=NsamNew/Srate; end;
	   mx=max(edinp);
	   cutvec=zeros(1,nSamples);
	   cutvec=inp(S0:S1);
	   zm=1;
	  end
	  modChange=1;	
	  lastS0=S0;
	  if TWOFILES==1, lastTOP=TOP; end;
	 fedun=uimenu(fed,'Label','Undo last cut','Callback','editool(''paste'',''special'')',...
		'Separator','on');       

	elseif strcmp(action,'copy') % ========== COPY============

	  cutvec=zeros(1,nSamples);
	  cutvec=inp(S0:S1);
	  edinp=inp;
	  zm=0;
	elseif strcmp(action,'paste') % ========== PASTE ==========
	  
	  if nargin==2, S0=lastS0; delete(fedun); end;
	  clen=length(cutvec);
 	  NsamNew=inpNS+clen; 
	  edinp = zeros(1,NsamNew);
	  edinp(1:S0)=inp(1:S0);
	  edinp(S0+1:S0+clen)=cutvec;
	  edinp(S0+1+clen:NsamNew)=inp(S0+1:inpNS);
	  if TOP==1, n_Secs2=NsamNew/Srate2;
	  else	     n_Secs=NsamNew/Srate; end;
	  mx=max(edinp);
	  zm=1;
	  modChange=1;
	  if TWOFILES==1 & nargin==1
	   if abs(Srate-Srate2)>200  | strcmp(ftype,ftype2)~=1
	    warn=sprintf('The two waveforms have different data types (e.g., sampl. freq, bytes/sample).');
	    warndlg(warn,'WARNING in paste');
	   end
	  end	

      elseif strcmp(action,'addsil') % ========ADD SILENCE  ==========
	  
	  nmsec=str2num(get(adsOp,'String'));
	  if nmsec<0, errordlg('The number has to be greater than 0 msec.','ERROR','on'); 
		edinp=inp;
		zm=0;
	  else
	   if TOP==1, clen=round(nmsec*Srate2/1000);
	   else,      clen=round(nmsec*Srate/1000); end; 
	 
 	   NsamNew=inpNS+clen; 
	   edinp = zeros(1,NsamNew);
	   edinp(1:S0)=inp(1:S0);
	   edinp(S0+1:S0+clen)=mean(inp)*ones(1,clen);
	   edinp(S0+1+clen:NsamNew)=inp(S0+1:inpNS);
	   if TOP==1, n_Secs2=NsamNew/Srate2;
	   else	     n_Secs=NsamNew/Srate; end;
	   mx=max(edinp);
	   zm=1;
	   modChange=1;
	 end
 elseif strcmp(action,'insfile') % ======== INSERT FILE at cursor =========
	  
	  [pth,fname] = dlgopen('open','*.ils;*.wav');
 	  if ((~isstr(fname)) | ~min(size(fname))), return; end	
 	  fname2=[pth,fname];
	  fp2 = fopen(fname2,'r');

	  ind=find(fname == '.');
	  ext = lower(fname(ind+1:length(fname))); 
 	  [xHDRSIZE, srat,xbpsa,xftype] =gethdr(fp2,ext);
	
	  x2  = fread(fp2,inf,ftype);
	  clen=length(x2);
	  fclose(fp2); 

 	  NsamNew=inpNS+clen; 
	  edinp = zeros(1,NsamNew);
	  edinp(1:S0)=inp(1:S0);
	  edinp(S0+1:S0+clen)=x2;
	  edinp(S0+1+clen:NsamNew)=inp(S0+1:inpNS);
	  if TOP==1, n_Secs2=NsamNew/Srate2;
	  else	     n_Secs=NsamNew/Srate; end;
	  mx=max(edinp);
	  zm=1;
	  modChange=1;
	  if srat ~= sfreq
	    warn=sprintf('The inserted waveform was sampled at a different sampling frequency.');
	    warndlg(warn,'WARNING in inserting file');
	  end
  
  elseif strcmp(action,'upsample') % ========== UPSAMPLE ==========
	  nrt=2;
	  len=S1-S0+1; %if rem(len,2)~=0, len=len+1; S1=S1+1; end;
 	  NsamNew=inpNS+nrt*len-len; 
	  edinp = zeros(1,NsamNew);
	  edinp(1:S0)=inp(1:S0);
	  updata=interp(inp(S0:S1),nrt); % upsample data
	  %updata=resample(inp(S0:S1),3,2);
	  edinp(S0+1:S0+nrt*len)=updata;
	  edinp(S0+nrt*len:NsamNew)=inp(S1+1:inpNS);
	  if TOP==1, n_Secs2=NsamNew/Srate2;
	  else	     n_Secs=NsamNew/Srate; end;
	  mx=max(edinp);
	  zm=1;
	  modChange=1;
	  if TWOFILES==1
	   if abs(Srate-Srate2)>200  | strcmp(ftype,ftype2)~=1
	    warn=sprintf('The two waveforms have different data types (e.g., sampl. freq, bytes/sample).');
	    warndlg(warn,'WARNING in paste');
	   end
	  end	

	end

%-- Adjust the maximum amplitude of the modified signal changed	
%
if ~strcmp(action,'copy') & zm==1 % case action is copying, dont bother with max
  if TWOFILES==1 & TOP==1
	agcsc2=MAX_AM/mx;
  else	
	 agcsc=MAX_AM/mx; 
  end
end

 
	if TWOFILES==1 & TOP==1
	 fwrite(fpmod2,hdr,'short');
 	 fwrite(fpmod2,edinp,ftype2);	
	 fclose(fpmod2);
	 S0=Be2; S1=En2;
	else
	 fwrite(fpmod,hdr,'short');
	 fwrite(fpmod,edinp,ftype);	
	 fclose(fpmod);
	 S0=Be; S1=En;
	end
	
	if zm==1
	  zoomi('out');
	end
 
	
else	
	errordlg('Invalid segment selection. Right mark is less than left mark.','ERROR','on');
end

