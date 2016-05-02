function setdisp(type,clor)

% Copyright (c) 1995 Philipos C. Loizou
%

global TIME En Be S0 S1 CLR En2 Be2 TWOFILES TOP fno
global HDRSIZE HDRSIZE2 Srate Srate2 n_Secs n_Secs2 filename
global filename2 AXISLOC cAxes fno boc tpc wav WAV1 singldisp
global al2 bl2 filterA2 filterB2 al bl filterA filterB tspec
global agcsc agcsc2 upFreq upFreq2 SrateChange htop hbot

if nargin==2
 if strcmp(clor,'clr')
  CLR=1;
  if TOP==1 
	if Srate2 >= 2*5000, upFreq2=2*5000/Srate2; end;
  else
	if Srate >= 2*5000, upFreq=2*5000/Srate; end;
  end
 elseif strcmp(clor,'noclr') %=======================
  CLR=0;
  if TOP==1 
	if Srate2 >= 2*5000, upFreq2=2*5000/Srate2; end;
  else
	if Srate >= 2*5000, upFreq=2*5000/Srate; end;
  end
 elseif strcmp(clor,'4khz') %=======================
		if TOP==1	
		  if Srate2 > 2*4000, upFreq2=2*4000/Srate2; end;
		else
		  if Srate > 2*4000, upFreq=2*4000/Srate; end;
		end
elseif strcmp(clor,'5khz') %=======================
		if TOP==1	
		  if Srate2 >= 2*5000, upFreq2=2*5000/Srate2; end;
		else
		  if Srate >= 2*5000, upFreq=2*5000/Srate; end;
		end
elseif strcmp(clor,'full') %=======================
		if TOP==1	
		  upFreq2=1.0;
		else
		  upFreq=1.0;
		end
  end
end
if TWOFILES==1 & TOP==1
  S1=En2;
  S0=Be2;
else
  S1=En;
  S0=Be;
end

if strcmp(type,'blow')==1
	blowup;
else

 if strcmp(type,'time')==1
	TIME=1;
	if TWOFILES==1
	  if TOP==1
		tspec(2)=1;
	  else
		tspec(1)=1;
	  end
	end
 elseif strcmp(type,'spec')==1
	TIME=0;
	if TWOFILES==1
	  if TOP==1
		tspec(2)=0;
	  else
		tspec(1)=0;
	  end
	end
 else % -------------------- Single window display ---
      if TWOFILES==1
	TWOFILES=0;
	if TOP==1
		if Srate ~= Srate2
		   al=al2; bl=bl2;
		   filterA=filterA2; filterB=filterB2;
		end
		if Srate ~= Srate2, SrateChange=1; else SrateChange=0; end;
		% NOTE: this variable is used in Shannons', and SMSP routines for  estimating 
		%       new filters due to change in Srate

		Srate=Srate2;
		HDRSIZE=HDRSIZE2;
		filename=filename2;
		n_Secs=n_Secs2;
		upFreq=2*5000/Srate;
		if wav(2)==1, WAV1=1; end;
		set(fno,'Name',filename);
		S0=0; S1=round(n_Secs*Srate);
		agcsc=agcsc2;
	else
	   	if wav(1)==1, WAV1=1; end
		set(fno,'Name',filename);
	end

	fprintf('Samp.Freq: %d Hz,  num.samples: %d (%4.2f secs)\n',...
		   	Srate,n_Secs*Srate,n_Secs);

	set(tpc,'String',' ','BackGroundColor',[0 0 0]);
	set(boc,'String',' ','BackGroundColor',[0 0 0]);
	h11=subplot(1,1,1);
	set(h11,'Visible','off');
	cAxes = axes('Units','Pixels','Position',AXISLOC);
	singldisp=1; % used in modify.m
	htop=[]; 
	hbot=[];
	
      end
 end
 zoomi('in');
  
end

