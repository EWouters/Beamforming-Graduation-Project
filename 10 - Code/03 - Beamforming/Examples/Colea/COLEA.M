function colea(infile,Srate1)

% COLEA
%  A software tool for speech analysis
%
% To run this program, just type 'colea' in the MATLAB window. This
% will open a file dialog box from which you can select the file to open.
%
% You may also type: colea filename, where 'filename' is the
% name of the speech file.

% Copyright (c) 1998 by Philipos C. Loizou
%



colordef none  % comment this line in MATLAB 4.x

global hl hr doit
global fed shW
global filename
global fno Srate n_Secs filename AXISLOC  nLPC HDRSIZE
global nChannels fftSize filterWeights UpperFreq LowFreq ChanpUp
global center LPCSpec SpecUp Dur DurUp filterA filterB  S1 S0
global HDRSIZE cAxes En Be TIME centSMSP Asmsp Bsmsp OVRL WAV1 CLR
global TWOFILES wav agcsc MAX_AM upFreq upFreq2 FIX_SCALE
global SHOW_CRS SHOW_CHN ftype ftype2 bpsa bpsa2 PREEMPH LPC_ONLY
global lpcParam fft_par NAR_BAND SPEC_EXP FILT_TYPE VOL_MAX
global VOL_NORM
global sli n_samples FFT_SET XFFT
global tpc boc
global smp frq TOP
global preUp  defUp w64Up w128Up w256Up w512Up narUp
global crsUp chnUp lpcUp chnlpUp fbrd fnar
global ovlpfilt SET_X_AXIS LD_LABELS




if (nargin < 1)
 [pth,fname] = dlgopen('open','*.ils;*.wav');
 if ((~isstr(fname)) | ~min(size(fname))), return; end  
 filename=[pth,fname];
else
  filename=infile;
end
pos = get(0, 'screensize'); % get the screensize
sWi = pos(3);
sHe = pos(4);

WIDTH   =round(0.9375*sWi);
HEIGHT  =round(0.43*sHe) ;
LEFT    =round(0.025*sWi);
BOTTOM  =round(sHe-HEIGHT-40);

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
LPC_ONLY=1;             % if 1, only the LPC specrtrum is displayed
lpcParam(1)=1;          % if 1, use hamming window in LPC analysis, else use rectangular 
lpcParam(2)=0;          % if 1, first-order pre-emphasis in LPC analysis, else dont
			% NOTE: this pre-emphasis is done in addition to the CIS pre-emphasis
lpcParam(3)=-1;         % if 1, enhance spectral peaks in LPC analysis
fft_par(1)=1;           % if 1, use lines when plotting FFT, else use pickets
fft_par(2)=1;           % if 1 use hamming window, else rectangular
NAR_BAND=0;             % if 1, display narrowband spectrograms
SPEC_EXP=0.25;		% Used in spectrogram display (root compression)
FILT_TYPE='broad';	% the filter type
VOL_MAX=0;		% used for controling the volume
VOL_NORM=1;		% if 1, then volume is normalized
FFT_SET=0;		% if 1, use user defined FFT size
XFFT=0;			% same as above
SET_X_AXIS=0;
ovlpfilt=0;
LD_LABELS=0;
TOP=0;

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




[HDRSIZE, xSrate, bpsa, ftype] =  gethdr(fp,ext);


if xSrate==0, return; 
else Srate=xSrate; end;

if strcmp(ftype,'ascii')
 x=fscanf(fp,'%f',inf);
else
 x  = fread(fp,inf,ftype);
end

	


fclose(fp); 

if (Srate<6000 | Srate>45000) & (nargin<2)
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
	'WindowButtonDownFcn','mclick',...
	'Resize','on','Name',filename,'NumberTitle','Off',...
	'Menubar','None','WindowButtonMotionFcn','showpt',...
	'KeyPressFcn','getkb','Color','k');
		       
%------------ deterime the dimensions of the axis ------------

le=round(0.2*WIDTH);
bo=round(0.174*HEIGHT);
wi=round(0.773*WIDTH);
he=round(0.739*HEIGHT);

AXISLOC = [le bo wi he];
cAxes = axes('Units','Pixels','Position',AXISLOC);


axes(cAxes);



	Et=1000*n_samples/Srate;
	xax=0:1000/Srate:(Et-1000/Srate);
	
	plot(xax,x,'y')
	xlabel('Time (msecs)');
	ylabel('Amplitude');
	set(gca,'Color','k'); set(gca,'Xcolor','w'); set(gca,'YColor','w');
	%set(gca,'Units','points','FontSize',9);
	if min(x)<-1000 | mx >1000
	  axis([0 Et min(x)-200 max(x)+200]);
	else
	  axis([0 Et min(x) max(x)]);
	end
            
   %set(gca,'Color','k');
   set(gca,'XColor','w');
   set(gca,'YColor','w');
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
  
  
%---Draw the squares in case its TWOFILES
wwi=xywh(3); whe=xywh(4);
tpc=uicontrol('Style','text','Position',[wwi-10 2*whe/3+10 10 10],'String',' ','BackGroundColor',[0 0 0]);
boc=uicontrol('Style','text','Position',[wwi-10 whe/3-10 10 10],'String',' ','BackGroundColor',[0 0 0]);


%----Draw the time and freq numbers----------
smp=uicontrol('Style','text','Position',[10 30 wide+10 15],'BackGroundColor',[0 0 0],...
	'HorizontalAlignment','left');
frq=uicontrol('Style','text','Position',[10 10 wide+10 15],'BackGroundColor',[0 0 0],...
	'HorizontalAlignment','left');


%
%-------------------------MENUS---------------------------------
%
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
	uimenu(fprf,'Label','Windows metafile','Callback','cprint(''landscape'',''meta'')');


   uimenu(ff,'Label','Exit','CallBack','quitall','Separator','on');

fed=uimenu('Label','Edit');
    uimenu(fed,'Label','Cut','CallBack','editool(''cut'')');
    uimenu(fed,'Label','Copy','CallBack','editool(''copy'')');
    uimenu(fed,'Label','Paste','CallBack','editool(''paste'')');
    uimenu(fed,'Label','Zero segment','CallBack','modify(''zero'')','Separator','on');
    fm2=uimenu(fed,'Label','Amplify/Attenuate segment');        
	uimenu(fm2,'Label','X2','CallBack','modify(''multi2'')');       
	uimenu(fm2,'Label','X0.5','CallBack','modify(''multi05'')');
     uimenu(fed,'Label','Insert silence at cursor','CallBack','iadsil');

    
    

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
	    'Label','Full Range: 0-fs/2');
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

	
	uimenu(fd,'Label','Single Window','Callback','setdisp(''single'')');
   
   
	uimenu(fd,'Label','Energy Plot','Callback','engy');
	fdf0=uimenu(fd,'Label','F0 contour');
	     uimenu(fdf0,'Label','Autocorrelation approach','Callback','estf0(''autocor'')');
	     uimenu(fdf0,'Label','Cepstrum approach','Callback','estf0(''cepstrum'')');
		uimenu(fd,'Label','Formant track','Callback','ftrack(''plot'')');
	uimenu(fd,'Label','Power Spectral Density','Callback','estpsd');
	fd2=uimenu(fd,'Label','Preferences');
	    crsUp=uimenu(fd2,'Label','  Show Cursor Lines','Checked','on',...
		   'Callback','prefer(''crs'')');
	    

	
		
fv1=uimenu('Label','Record','CallBack','rectool');
fm1=uimenu('Label','Tools');
    
                        
    uimenu(fm1,'Label','Add Gaussian noise..','CallBack','isnr(''gaussian'')');
    uimenu(fm1,'Label','Add noise from file..','CallBack','isnr(''spec'')');
    fm3=uimenu(fm1,'Label','Convert to SCN noise','Callback','modify(''scn'')'); 
    uimenu(fm1,'Label','Filter Tool','Callback','filtool','Separator','on');
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




