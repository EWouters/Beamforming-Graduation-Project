function colea(filename,Srate1)

% Copyright (c) 1995 by Philipos C. Loizou
%

%clf reset

if (nargin < 1)
 [pth,fname] = dlgopen('open','*.ils;*.wav');
 if ((~isstr(fname)) | ~min(size(fname))), return; end  
 filename=[pth,fname];
end
pos = get(0, 'screensize'); % get the screensize
sWi = pos(3);
sHe = pos(4);

WIDTH   =round(0.9375*sWi);
HEIGHT  =round(0.48*sHe) ;
LEFT    =round(0.025*sWi);
BOTTOM  =round(0.767*sHe);

LPCSpec = 1;            % if 0 display FFT, else LPC spectrum
TIME=1;                 % if 0 display spectrogram, else time waveform
WAV1=0;                 % If 1, then it is a .wav file with 8 bits/sample
CLR=1;                  % If 1 display spectrogram in color, else in gray scale
TWOFILES=0;             % If 1, then display two files
wav(1)=0; wav(2)=0;     % Used in case of dual-displays for 1-byte samples, as in WAV
upFreq=1.0;             % Upper frequency (percentage of Srate/2) in spectrogram
upFreq2=1.0;            % Upper frequency in spectrogram (1.0=Srate/2)
FIX_SCALE=-1;           % if > 0, then channel y-axis is always 0-15 dB
SHOW_CRS=1;             % if 1, show cursor lines, else dont
SHOW_CHN=1;             % if 1, show channel output/LPC display
PREEMPH=1;              % if 1, do pre-emphasis when computing the  spectrogram
LPC_ONLY=0;             % if 1, only the LPC specrtrum is displayed
lpcParam(1)=1;          % if 1, use hamming window in LPC analysis, else use rectangular 
lpcParam(2)=0;          % if 1, first-order pre-emphasis in LPC analysis, else dont
			% NOTE: this pre-emphasis is done in addition to the CIS pre-emphasis
lpcParam(3)=-1;         % if 1, enhance spectral peaks in LPC analysis
fft_par(1)=1;           % if 1, use lines when plotting FFT, else use pickets
NAR_BAND=0;             % if 1, display narrowband spectrograms
SPEC_EXP=0.25;		% Used in spectrogram display (root compression)
FILT_TYPE='broad';	% the filter type
VOL_MAX=0;		% used for controling the volume
VOL_NORM=1;		% if 1, then volume is normalized

fp = fopen(filename,'r');

if fp <=0
	disp('ERROR! File not found..')
	return;
end

ftype='short'; bpsa=2;    % bytes per sample
ftype2='short'; bpsa2=1;

ind1=find(filename == '.');
if length(ind1)>1, ind=ind1(length(ind1)); else, ind=ind1; end;
ext = lower(filename(ind+1:length(filename))); 

global filename 


[HDRSIZE, xSrate, bpsa, ftype] =  gethdr(fp,ext);


if xSrate==0, return; 
else Srate=xSrate; end;

if strcmp(ftype,'ascii')
 x=fscanf(fp,'%f',inf);
else
 x  = fread(fp,inf,ftype);
end

	


fclose(fp); 

if Srate<6000 | Srate>45000 & nargin<2
h=warndlg('Sampling rate not in the range: 10,000 < F < 45,000 . Setting it to  10,000 Hz.','WARNING!');
  disp('Warning! Sampling rate not in the range: 6,000 < F < 45,000');
  disp('...Setting it to the default value of 10,000 Hz.');
  Srate=10000;
end    



x= x - mean(x);  %----------remove the DC bias----

if (nargin==2)
 Srate  = str2num(Srate1);
 if Srate<10000 | Srate>45000
	error('Invalid sampling frequency specified: 10,000<F<45,000');
 end
end

MAX_AM=2048; % This allows 12-bit resolution

mx=max(x);
agcsc=MAX_AM/mx;


n_samples = length(x);
n_Secs    = n_samples/Srate;
Dur=10.0;   % Duration in msec of window
S1=n_samples;
S0=0;
Be=S0;
En=S1;
OVRL=1;  % if 1 then hold off plots, else hold on plots in 'pllpc'

fprintf('Samp.Freq: %d Hz,  num.samples: %d (%4.2f secs)\n',Srate,n_samples,n_Secs);

fno =  figure('Units', 'Pixels', 'Position', [LEFT BOTTOM WIDTH HEIGHT],...
	'WindowButtonDownFcn','mclick','Pointer','crosshair',...
	'Resize','on','Name',filename,'NumberTitle','Off',...
	'Menubar','None','WindowButtonMotionFcn','showpt',...
	'KeyPressFcn','getkb');
		       
%------------ deterime the dimensions of the axis ------------

le=round(0.2*WIDTH);
bo=round(0.174*HEIGHT);
wi=round(0.773*WIDTH);
he=round(0.739*HEIGHT);

AXISLOC = [le bo wi he];
cAxes = axes('Units','Pixels','Position',AXISLOC);


axes(cAxes);


%----------------- Define Filterbank Characteristics---------
fftSize=512;
nChannels   =6;
LowFreq     =300;
UpperFreq   =5500;
range=log10(UpperFreq/LowFreq);
interval=range/nChannels;


for i=1:nChannels  % ----- Figure out the center frequencies for all channels
	upper1(i)=LowFreq*10^(interval*i);
	lower1(i)=LowFreq*10^(interval*(i-1));
	center(i)=0.5*(upper1(i)+lower1(i));
end


%-------------- Design the Butterworth filter------------
nOrd=6;
FS=Srate/2; 
if FS<upper1(nChannels), useHigh=1;
else                     useHigh=0;
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
	filterB(i,1:nOrd+1)=b;   %----->  Save the coefficients 'b'
	filterA(i,1:nOrd+1)=a;   %-----> Save the coefficients 'a'
end

%----------------------------------------------------------
global fno Srate n_Secs filename AXISLOC  nLPC HDRSIZE
global nChannels fftSize filterWeights UpperFreq LowFreq ChanpUp
global center LPCSpec SpecUp Dur DurUp filterA filterB  S1 S0
global HDRSIZE cAxes En Be TIME centSMSP Asmsp Bsmsp OVRL WAV1 CLR
global TWOFILES wav agcsc MAX_AM upFreq upFreq2 FIX_SCALE
global SHOW_CRS SHOW_CHN ftype ftype2 bpsa bpsa2 PREEMPH LPC_ONLY
global lpcParam fft_par NAR_BAND SPEC_EXP FILT_TYPE VOL_MAX
global VOL_NORM



	Et=1000*n_samples/Srate;
	xax=0:1000/Srate:(Et-1000/Srate);
	
	plot(xax,x)
	xlabel('Time (msecs)');
	ylabel('Amplitude');
	%set(gca,'Units','points','FontSize',9);
	if min(x)<-1000 | mx >1000
	  axis([0 Et min(x)-200 max(x)+200]);
	else
	  axis([0 Et min(x) max(x)]);
	end
            

xywh = get(fno, 'Position');
axi=AXISLOC;

% Buttons.
left = 10;
wide = 80;
top  = xywh(4) - 10;
high = 22;
high=22;
if 9*(22+8) > xywh(4), high=17; end;
inc  = high + 8;
%---------- Display the slider and the push-buttons-------------
sli = uicontrol('Style','slider','min',0,'max',1000','Callback',...
	'getslide','Position',[axi(1) axi(2)+axi(4)+2 axi(3) 12]);


global sli n_samples

Zin = uicontrol('Style', 'PushButton', 'Callback','zoomi(''in'')', ...
	 'HorizontalAlign','center', 'String', 'Zoom In',...
	 'Position', [left top-high wide high]);

top = top - inc;
Zout = uicontrol('Style', 'PushButton', 'Callback','zoomi(''out'')', ...
	 'HorizontalAlign','center', 'String', 'Zoom Out',...
	 'Position', [left top-high wide high]);
if Srate>12000
  nLPC=14;
else
 nLPC=12; % initialize LPC order
end
top = top - inc-20;
uicontrol('Style','Frame','Position',[left top-high-10 wide+5 high+30],...
	'BackgroundColor','b');
 
uicontrol('Style','text','Position',[left+wide/3 top 40 high-3],'BackGroundColor','b',...
	'HorizontalAlignment','left','ForeGroundColor','w','String','Play');

plUp = uicontrol('Style', 'PushButton', 'Callback', 'playf(''all'')', ...
	  'HorizontalAlign','center', 'String', 'all',...
	  'Position', [left top-high wide/2 high]);

uicontrol('Style', 'PushButton', 'Callback', 'playf(''sel'')', ...
	  'HorizontalAlign','center', 'String', 'sel',...
	  'Position', [left+wide/2+5 top-high wide/2 high]);
  
top = top - inc-10;
ChanpUp = uicontrol('Style', 'Popup', 'Callback', 'setchan', ...
	  'HorizontalAlign','center', 'String', ['# Channels | 3 | 4 | 5 | 6 | 7 | 8 | 10 | 12 | 14 | 16 | 18 | 20'],...
	  'Position', [left top-high wide high]); 

top = top - inc;
DurUp = uicontrol('Style', 'Popup', 'Callback', 'setdur', ...
	  'HorizontalAlign','center', 'String', ['Duration | 10 ms | 20 ms | 30 ms | In samples | 64 | 128 | 256 | 512'],...
	  'Position', [left top-high wide high]); 

  
top = top - inc;
uicontrol('Style', 'PushB', 'Callback', 'quitall',... 
	  'HorizontalAlign','center', 'String', 'Quit', ...
	  'Position', [left top-high wide high]);  

%top=top-inc;
%sliB = uicontrol('Style','slider','min',-1,'max',1','Callback',...
%       'getcontr','Position', [left top-high wide high]);
%global sliB

%---Draw the squares in case its TWOFILES
wwi=xywh(3); whe=xywh(4);
tpc=uicontrol('Style','text','Position',[wwi-10 2*whe/3+10 10 10],'String',' ','BackGroundColor',[0 0 0]);
boc=uicontrol('Style','text','Position',[wwi-10 whe/3-10 10 10],'String',' ','BackGroundColor',[0 0 0]);

global tpc boc
global smp frq

%----Draw the time and freq numbers----------
smp=uicontrol('Style','text','Position',[10 30 wide+10 15],'BackGroundColor',[0 0 0],...
	'HorizontalAlignment','left');
frq=uicontrol('Style','text','Position',[10 10 wide+10 15],'BackGroundColor',[0 0 0],...
	'HorizontalAlignment','left');


%
%-------------------------MENUS---------------------------------
%

  % uimenu(fed,'Label','Upsample','CallBack','editool(''upsample'')');


ff=uimenu('Label','File');
   uimenu(ff,'Label','&Load and stack','Callback','loadfile(''stack'')');
   uimenu(ff,'Label','Load and &replace','Callback','loadfile(''replace'')');
   uimenu(ff,'Label','&Save whole file','Callback','savefile(''whole'')','Separator','on');
   uimenu(ff,'Label','Sa&ve selected region','Callback','savefile(''seg'')');
   uimenu(ff,'Label','Insert file at cursor','CallBack','editool(''insfile'')','Separator','on');
   uimenu(ff,'Label','File utility','Callback','filetool');
   uimenu(ff,'Label','Print-Landscape','Callback','cprint(''landscape'',''printer'')','Separator','on');
   uimenu(ff,'Label','Print-Portrait','Callback','cprint(''portrait'',''printer'')');
   fprf=uimenu(ff,'Label','Print to file ...');
	uimenu(fprf,'Label','Postscript','Callback','cprint(''landscape'',''eps'')');
	%uimenu(fprf,'Label','Windows metafile','Callback','cprint(''landscape'',''meta'')');


   uimenu(ff,'Label','Exit','CallBack','quitall','Separator','on');

fed=uimenu('Label','Edit');
    uimenu(fed,'Label','Cut','CallBack','editool(''cut'')');
    uimenu(fed,'Label','Copy','CallBack','editool(''copy'')');
    uimenu(fed,'Label','Paste','CallBack','editool(''paste'')');
    
global fed
fd=uimenu('Label','Display');
	uimenu(fd,'Label','Time Waveform','Callback','setdisp(''time'')');
       fd0= uimenu(fd,'Label','Spectrogram');
	uimenu(fd0,'Callback','setdisp(''spec'',''clr'')',...
	    'Label','Color');
	uimenu(fd0,'Callback','setdisp(''spec'',''noclr'')',...
	    'Label','Gray Scale');
	uimenu(fd0,'Callback','setdisp(''spec'',''4khz'')',...
	    'Label','0-4 kHz');
	uimenu(fd0,'Callback','setdisp(''spec'',''5khz'')',...
	    'Label','0-5 kHz');
	uimenu(fd0,'Callback','setdisp(''spec'',''full'')',...
	    'Label','Full Range');
	fd01=uimenu(fd0,'Label','Preferences');
	    preUp=uimenu(fd01,'Label','Preemphasis','Checked','on',...
		   'Callback','prefer(''preemp'')');
	    fd02=uimenu(fd01,'Label','Window Size');
		defUp=uimenu(fd02,'Label','Default','Checked','on',...
		   'Callback','prefer(''win_default'')');
		w64Up=uimenu(fd02,'Label','64 pts','Checked','off',...
		   'Callback','prefer(''win_64'')');
		w128Up=uimenu(fd02,'Label','128 pts','Checked','off',...
		   'Callback','prefer(''win_128'')');
		w256Up=uimenu(fd02,'Label','256 pts','Checked','off',...
		   'Callback','prefer(''win_256'')');
		w512Up=uimenu(fd02,'Label','512 pts','Checked','off',...
		   'Callback','prefer(''win_512'')');

	   fd03=uimenu(fd01,'Label','Update frame size');
		uimenu(fd03,'Label','Default','Callback','prefer(''upd_default'')');
		uimenu(fd03,'Label','8 pts','Callback','prefer(''upd_8'')');
		uimenu(fd03,'Label','16 pts','Callback','prefer(''upd_16'')');
		uimenu(fd03,'Label','32 pts','Callback','prefer(''upd_32'')');
		uimenu(fd03,'Label','64 pts','Callback','prefer(''upd_64'')');
	
	 fd04=uimenu(fd01,'Label','Formant enhancement');
		uimenu(fd04,'Label','Default','Callback','prefer(''enh_default'')');
		uimenu(fd04,'Label','0.3','Callback','prefer(''enh_3'')');
		uimenu(fd04,'Label','0.4','Callback','prefer(''enh_4'')');
		uimenu(fd04,'Label','0.5','Callback','prefer(''enh_5'')');
		uimenu(fd04,'Label','0.6','Callback','prefer(''enh_6'')');

	narUp=uimenu(fd01,'Label','Narrowband','Callback','prefer(''narrow'')');

	
	global preUp  defUp w64Up w128Up w256Up w512Up narUp

	uimenu(fd,'Label','Single Window','Callback','setdisp(''single'')');
	uimenu(fd,'Label','Blow Up','Callback','setdisp(''blow'')');
	fd1=uimenu(fd,'Label','Filters');
	fd2=uimenu(fd1,'Label','CIS filters');
		uimenu(fd2,'Label','Linear Scale','Callback','vfilter(1)');
		uimenu(fd2,'Label','Log Scale','Callback','vfilter(2)');
		uimenu(fd2,'Label','Show center freqs','Callback','vfilter(6)');
	uimenu(fd1,'Label','Vienna filter','Callback','vfilter(3)');
	uimenu(fd1,'Label','SMSP filter','Callback','vfilter(4)');
	uimenu(fd1,'Label','Ineraid filter','Callback','vfilter(5)');
	uimenu(fd,'Label','Energy Plot','Callback','engy');
	fdf0=uimenu(fd,'Label','F0 contour');
	     uimenu(fdf0,'Label','Autocorrelation approach','Callback','estf0(''autocor'')');
	     uimenu(fdf0,'Label','Cepstrum approach','Callback','estf0(''cepstrum'')');
	uimenu(fd,'Label','Glottal flow','Callback','glottal');
	uimenu(fd,'Label','Formant track','Callback','ftrack(''plot'')');
	uimenu(fd,'Label','Power Spectral Density','Callback','estpsd');
	fd2=uimenu(fd,'Label','Preferences');
	    crsUp=uimenu(fd2,'Label','  Show Cursor Lines','Checked','on',...
		   'Callback','prefer(''crs'')');
	    chnUp=uimenu(fd2,'Label','  Show LPC-Channel Outputs Window','Checked','on',...
		   'Callback','prefer(''chn'')'); 
	    lpcUp=uimenu(fd2,'Label','  Show only LPC spectrum','Checked','off',...
		   'Callback','setovr(''lpconly'')');
	    chnlpUp=uimenu(fd2,'Label','  Show LPC and channel outputs','Checked','on',...
		   'Callback','setovr(''lpc_chan'')');
	    filUp=uimenu(fd2,'Label','  Filter type');
	           fbrd=uimenu(filUp,'Label','Broadband','Checked','on',...
		        'Callback','prefer(''broad'')');
		   fnar=uimenu(filUp,'Label','Narrowband','Checked','off',...
		        'Callback','prefer(''narrfil'')');

global crsUp chnUp lpcUp chnlpUp fbrd fnar

fa=uimenu('Label','Analog','Callback','analog(''noLPF'')');
%fpu=uimenu('Label','Pulsatile');
%	uimenu(fpu,'Label','300 pps','Callback','pulse(300)');
%	uimenu(fpu,'Label','800 pps','Callback','pulse(800)');
%	uimenu(fpu,'Label','1100 pps','Callback','pulse(1100)');
	
fpa=uimenu('Label','Analysis');
	uimenu(fpa,'Label','300 pps','Callback','analysis(300)');
%	uimenu(fpa,'Label','500 pps','Callback','analysis(500)');
	uimenu(fpa,'Label','800 pps','Callback','analysis(800)');
	uimenu(fpa,'Label','1100 pps','Callback','analysis(1100)');
	uimenu(fpa,'Label','1400 pps','Callback','analysis(1400)');
%	uimenu(fpa,'Label','1700 pps','Callback','analysis(1700)');




fty=uimenu('Label','Type');
	fty1=uimenu(fty,'Label','F0/F1/F2');
	     uimenu(fty1,'Label','Freqs.','Callback','f0f1f2(''freq'')');
	     uimenu(fty1,'Label','Ampl.','Callback','f0f1f2(''ampl'')');
	uimenu(fty,'Label','MPEAK','Callback','mpeak');
	uimenu(fty,'Label','SMSP','Callback','smsp');
	uimenu(fty,'Label','House/3M','Callback','house','Separator','On');
	uimenu(fty,'Label','Vienna/3M','Callback','vienna');
	uimenu(fty,'Label','Buzz/Hiss','Callback','bhiss');
	fty1=uimenu(fty,'Label','Shannon','Separator','on');
	     uimenu(fty1,'Label','2 Channels','Callback',...
		'shannon(2)');
		uimenu(fty1,'Label','3 Channels','Callback',...
		'shannon(3)');
		uimenu(fty1,'Label','4 Channels','Callback',...
		'shannon(4)');
		uimenu(fty1,'Label','# CIS Channels','Callback',...
		'shannon(5)');
		uimenu(fty1,'Label','# CIS Channels+Flip','Callback',...
		'shannon(5,''flip'')');
		uimenu(fty1,'Label','# CIS Channels+Noise','Callback',...
		'shans(5)');
		fty2=uimenu(fty1,'Label','Preferences');
		  uimenu(fty2,'Label','Show filters','Callback','vfiltsha');
		  shW=uimenu(fty2,'Label','Show channel outputs','Callback','setovr(''shanwin'')');

	global shW
	uimenu(fty,'Label','Ineraid','Callback','ineraid');     
	ftlo=uimenu(fty,'Label','Loizou');
		uimenu(ftlo,'Label',' 64 pts','Callback','loizou(''64'')');
		uimenu(ftlo,'Label','128 pts','Callback','loizou(''128'')');
	   ftco=uimenu(ftlo,'Label','Linear compression');
	        uimenu(ftco,'Label','3 dB','Callback','loizouc(''pow1'',''10^(3/20)'')');
		uimenu(ftco,'Label','6 dB','Callback','loizouc(''pow1'',''10^(6/20)'')');
		uimenu(ftco,'Label','9 dB','Callback','loizouc(''pow1'',''10^(9/20)'')');
		uimenu(ftco,'Label','15 dB','Callback','loizouc(''pow1'',''10^(15/20)'')');
		uimenu(ftco,'Label','25 dB','Callback','loizouc(''pow1'',''10^(25/20)'')');
	     uimenu(ftlo,'Label','Flip Loizou','Callback','loizud(''128'',''flip'')');
		%uimenu(ftlo,'Label','Rand Loizou','Callback','loizud(''128'',''rand'')');
		uimenu(ftlo,'Label','Loizou-5-6 ch','Callback','loizud(''128'',''poor'')');
	uimenu(ftlo,'Label','test','Callback','loi2(''128'')');
		%uimenu(ftlo,'Label','128 pts+Interp','Callback','loizou(''interp'')');
		%uimenu(fty,'Label','New','Callback','loinew(''128'')');
		%uimenu(fty,'Label','Hamming','Callback','loizou2(''128'')');
		uimenu(fty,'Label','B-Plomp','Callback','plomp');
		fti=uimenu(fty,'Label','Insertions');
		    uimenu(fti,'Label','Normal','Callback','loitest(''normal'')');
		    uimenu(fti,'Label','22 mm','Callback','loitest(''actual'',''5_22'')');
		    uimenu(fti,'Label','23 mm','Callback','loitest(''actual'',''5_23'')');
		    uimenu(fti,'Label','24 mm','Callback','loitest(''actual'',''5_24'')');
		    uimenu(fti,'Label','25 mm','Callback','loitest(''actual'',''5_25'')');	
		fts=uimenu(ftlo,'Label','SMSP');
		    uimenu(fts,'Label','64 pts','Callback','loismsp(''64'')');
		     uimenu(fts,'Label','128 pts','Callback','loismsp(''128'')');
		     uimenu(fts,'Label','6x8','Callback','loinm(''128'',''norm'',''6'')');
		     uimenu(fts,'Label','5x8','Callback','loinm(''128'',''norm'',''5'')');
		     uimenu(fts,'Label','4x8','Callback','loinm(''128'',''norm'',''4'')');
		     uimenu(fts,'Label','3x8','Callback','loinm(''128'',''norm'',''3'')');
		     uimenu(fts,'Label','2x8','Callback','loinm(''128'',''norm'',''2'')');
		     uimenu(fts,'Label','Actual loc','Callback','loismsp(''128'',''act'')');
		%uimenu(ftlo,'Label','CIS-LPC','Callback','loilpc(''64'')');
		ftb=uimenu(ftlo,'Label','CIS4');
		uimenu(ftb,'Label','64 pts','Callback','loiz4(''64'')');
		uimenu(ftb,'Label','128 pts','Callback','loiz4(''128'')');
		uimenu(ftlo,'Label','CIS5-match-filters','Callback','loiz5(''128'')');
		uimenu(ftb,'Label','128+Virtual','Callback','loiz4(''128'',''virt2'')');
		fta=uimenu(ftlo,'Label','Actual location');
		    uimenu(fta,'Label','6 channels','Callback','loizou(''actual'',''6'')');
		    uimenu(fta,'Label','5 channels-22mm','Callback','loizou(''actual'',''5_22'')');
		    uimenu(fta,'Label','5 channels-25mm','Callback','loizou(''actual'',''5_25'')');
		%ftab=uimenu(ftlo,'Label','Blake W.');
		%   uimenu(ftab,'Label','Normal','Callback','blake(''128'',''normal'')'); 
		%   uimenu(ftab,'Label','Shifted','Callback','blake(''128'',''5_22'')');          
	ftlon=uimenu(fty,'Label','Formant shifter');
		uimenu(ftlon,'Label',' +800  Hz','Callback','loizn(''800'')');
		uimenu(ftlon,'Label',' +1000 Hz','Callback','loizn(''1000'')');
		uimenu(ftlon,'Label',' +1200 Hz','Callback','loizn(''1200'')');
		uimenu(ftlon,'Label',' +1400 Hz','Callback','loizn(''1400'')');
		uimenu(ftlon,'Label',' +1800 Hz','Callback','loizn(''1800'')');
		uimenu(ftlon,'Label',' +2000 Hz','Callback','loizn(''2000'')');
		uimenu(ftlon,'Label',' +3000 Hz','Callback','loizn(''3000'')');
fv1=uimenu('Label','Record','CallBack','getrec');
fm1=uimenu('Label','Tools');
    
    uimenu(fm1,'Label','Zero','CallBack','modify(''zero'')');
    fm2=uimenu(fm1,'Label','Amplify/Attenuate');        
	uimenu(fm2,'Label','X2','CallBack','modify(''multi2'')');       
	uimenu(fm2,'Label','X0.5','CallBack','modify(''multi05'')');
     uimenu(fm1,'Label','Insert silence','CallBack','iadsil');
    fm3=uimenu(fm1,'Label','Noise (SCN)','Callback','modify(''scn'')');                 
    uimenu(fm1,'Label','Gaussian Noise','CallBack','isnr(''gaussian'')');
    uimenu(fm1,'Label','Spectrally-shaped Noise','CallBack','isnr(''spec'')');
    uimenu(fm1,'Label','Filter Tool','Callback','filtool');
    uimenu(fm1,'Label','Sine wave generator','Callback','sintool');
    uimenu(fm1,'Label','Label tool','Callback','labtool'); 
    uimenu(fm1,'Label','Comparison tool','Callback','distool');
    uimenu(fm1,'Label','Volume control','Callback','voltool');

uimenu('Label','Help','Callback','helpf(''colea'')');

%-----------Initialize handles to cursor lines ------------

np=3; Ylim=get(gca,'YLim');
hl=line('Xdata',[np np],'Ydata',Ylim,'Linestyle','-',...
	   'color',[0 0 0],'Erasemode','xor');

hr=line('Xdata',[np np],'Ydata',Ylim,'Linestyle','--',...
	   'color',[0 0 0],'Erasemode','xor');
doit=0;
global hl hr doit



%wAxes = axes('Units','Pixels','Position',[0 0 WIDTH HEIGHT],...
%       'Visible','off');
%axes(wAxes);
%hll=line('Xdata',[0.3 0.3],'Ydata',[0.05 0.1],'Linestyle','-',...
%          'color','r','Erasemode','xor');
%global hll wAxes

%
% 
%hbot=uicontrol('Style','text','Position',[10 10 wide+10 15],'BackGroundColor',[0 0 0],...
%       'HorizontalAlignment','left');

%global htop hbot
