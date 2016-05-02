function prefer(type)

%
% Copyright (c) 1995 by Philipos C. Loizou
%

global crsUp SHOW_CRS chnUp SHOW_CHN preUp PREEMPH TIME WIND_SIZE SET_WIN
global w64Up w128Up w256Up  w512Up defUp SET_UPD UPD_WIN 
global TWOFILES TOP S0 S1 En2 Be2 En Be narUp Srate Srate2 NAR_BAND
global SPEC_EXP FILT_TYPE fbrd fnar nChannels 

if strcmp(type,'crs') %-- Show or not cursor lines

	SHOW_CRS = SHOW_CRS*(-1);
	if SHOW_CRS>0
	  set(crsUp,'Checked','On');
	else
	  set(crsUp,'Checked','Off');
	end
elseif strcmp(type,'chn')

	SHOW_CHN = SHOW_CHN*(-1);
	if SHOW_CHN>0
	  set(chnUp,'Checked','On');
	else
	  set(chnUp,'Checked','Off');
	end
elseif strcmp(type,'preemp') %---------- Do preemphasis in spectrogram

	PREEMPH = PREEMPH*(-1);
	if PREEMPH>0
	  set(preUp,'Checked','On');
	else
	  set(preUp,'Checked','Off');
	end
	if TWOFILES==1 & TOP==1
	 S1=En2; S0=Be2;
	else
	  S1=En; S0=Be;
	end
	if TIME==0, zoomi('in'); end;

elseif strcmp(type,'win_default')  % ====== Set the window size for spectrogram ======
	SET_WIN=0;
	set(defUp,'Checked','On');   set(w64Up,'Checked','Off');
	set(w128Up,'Checked','Off'); set(w256Up,'Checked','Off');
	set(w512Up,'Checked','Off');
	if TWOFILES==1 & TOP==1
	 S1=En2; S0=Be2;
	else
	  S1=En; S0=Be;
	end
	if TIME==0, zoomi('in'); end;
elseif strcmp(type,'win_64')
	SET_WIN=1;
	WIND_SIZE=64;
	set(defUp,'Checked','Off');  set(w64Up,'Checked','On');
	set(w128Up,'Checked','Off'); set(w256Up,'Checked','Off');
	set(w512Up,'Checked','Off');	
	if TWOFILES==1 & TOP==1
	 S1=En2; S0=Be2;
	else
	  S1=En; S0=Be;
	end
	if TIME==0, zoomi('in'); end;
elseif strcmp(type,'win_128')
	SET_WIN=1;
	WIND_SIZE=128;
	set(defUp,'Checked','Off'); set(w64Up,'Checked','Off');
	set(w128Up,'Checked','On'); set(w256Up,'Checked','Off');
	set(w512Up,'Checked','Off');
	if TWOFILES==1 & TOP==1
	 S1=En2; S0=Be2;
	else
	  S1=En; S0=Be;
	end
	if TIME==0, zoomi('in'); end;
elseif strcmp(type,'win_256')
	SET_WIN=1;
	WIND_SIZE=256;
	set(defUp,'Checked','Off');  set(w64Up,'Checked','Off');
	set(w128Up,'Checked','Off'); set(w256Up,'Checked','On');
	set(w512Up,'Checked','Off');
	if TWOFILES==1 & TOP==1
	 S1=En2; S0=Be2;
	else
	  S1=En; S0=Be;
	end
	if TIME==0, zoomi('in'); end;
elseif strcmp(type,'win_512')
	SET_WIN=1;
	WIND_SIZE=512;
	set(defUp,'Checked','Off');  set(w64Up,'Checked','Off');
	set(w128Up,'Checked','Off'); set(w256Up,'Checked','Off')
	set(w512Up,'Checked','On');
	if TWOFILES==1 & TOP==1
	 S1=En2; S0=Be2;
	else
	  S1=En; S0=Be;
	end
	if TIME==0, zoomi('in'); end;
elseif strcmp(type,'upd_default')
	SET_UPD=0;
	if TIME==0, zoomi('out'); end;
elseif strcmp(type,'upd_8')
	SET_UPD=1;
	UPD_WIN=8;
	if TWOFILES==1 & TOP==1
	 S1=En2; S0=Be2;
	else
	  S1=En; S0=Be;
	end
	if TIME==0, zoomi('in'); end;
elseif strcmp(type,'upd_16')
	SET_UPD=1;
	UPD_WIN=16;
	if TWOFILES==1 & TOP==1
	 S1=En2; S0=Be2;
	else
	  S1=En; S0=Be;
	end
	if TIME==0, zoomi('in'); end;
elseif strcmp(type,'upd_32')
	SET_UPD=1;
	UPD_WIN=32;
	if TWOFILES==1 & TOP==1
	 S1=En2; S0=Be2;
	else
	  S1=En; S0=Be;
	end
	if TIME==0, zoomi('in'); end;
elseif strcmp(type,'upd_64')
	SET_UPD=1;
	UPD_WIN=64;
	if TWOFILES==1 & TOP==1
	 S1=En2; S0=Be2;
	else
	  S1=En; S0=Be;
	end
	if TIME==0, zoomi('in'); end;
elseif strcmp(type,'narrow') %============== Narrow Band Spectrogram=============

	if ~exist('SET_WIN'), SET_WIN=1; else, SET_WIN=SET_WIN*(-1); end;
	if SET_WIN>0, set(narUp,'Checked','on'); NAR_BAND=1; else,
	  	      set(narUp,'Checked','off'); NAR_BAND=0; end;
	
	if TWOFILES==1 & TOP==1
	 S1=En2; S0=Be2;
	 if Srate2>20000, WIND_SIZE=512; else, WIND_SIZE=256; end;
	else
	  S1=En; S0=Be;
	  if Srate>20000, WIND_SIZE=512; else, WIND_SIZE=256; end;
	end
	TIME=0;
	zoomi('in'); 

elseif strcmp(type,'enh_default') % ===== Formant Enhancement =========
	
 	SPEC_EXP=0.25;
	if TWOFILES==1 & TOP==1
	 S1=En2; S0=Be2;
	else
	  S1=En; S0=Be;
	end
	if TIME==0, zoomi('in'); end;
elseif strcmp(type,'enh_3')
	
 	SPEC_EXP=0.3;
	if TWOFILES==1 & TOP==1
	 S1=En2; S0=Be2;
	else
	  S1=En; S0=Be;
	end
	if TIME==0, zoomi('in'); end;
elseif strcmp(type,'enh_4')
	
 	SPEC_EXP=0.4;
	if TWOFILES==1 & TOP==1
	 S1=En2; S0=Be2;
	else
	  S1=En; S0=Be;
	end
	if TIME==0, zoomi('in'); end;
elseif strcmp(type,'enh_5')
	
 	SPEC_EXP=0.5;
	if TWOFILES==1 & TOP==1
	 S1=En2; S0=Be2;
	else
	  S1=En; S0=Be;
	end
	if TIME==0, zoomi('in'); end;
elseif strcmp(type,'enh_6')
	
 	SPEC_EXP=0.6;
	if TWOFILES==1 & TOP==1
	 S1=En2; S0=Be2;
	else
	  S1=En; S0=Be;
	end
	if TIME==0, zoomi('in'); end;

elseif strcmp(type,'broad')  % ====== Set the filter type ========
	
	FILT_TYPE='broad';
	set(fbrd,'Checked','on'); set(fnar,'Checked','off');
	setchan(nChannels);
	

elseif strcmp(type,'narrfil')  % ====== 
	FILT_TYPE='narrow';
	set(fbrd,'Checked','off'); set(fnar,'Checked','on');
	setchan(nChannels);

end