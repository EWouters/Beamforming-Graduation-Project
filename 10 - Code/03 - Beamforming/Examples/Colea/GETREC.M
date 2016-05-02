function getrec

% Copyright (c) 1995-1999 Philipos C. Loizou
%

global  filename Srate filename2 Srate2 TWOFILES TOP  ftype2 n_Secs2
global  n_Secs MAX_AM ftype bpsa agcsc HDRSIZE HDRSIZE2 bpsa2
global  recBitsH recFsH recFileH recDurH agcsc2


nBits=8*get(recBitsH,'Value');
if nBits==8, 
   DTYPE='uint8'; maxAmp=128;
   xftype='char'; xbpsa=1;
else
   DTYPE='int16'; maxAmp=32768; 
   xftype='short';  xbpsa=2;
 end;

iFs=get(recFsH,'Value');
FsValues=[8000,11025,16000,22050,44100];
xSrate=FsValues(iFs);

Dur=str2num(get(recDurH,'String'));  % in secs
fname=get(recFileH,'String');
ind=find(fname == '.');
if isempty(fname), xfilename=[fname '.wav']; 
else, xfilename=fname; end;

if TWOFILES==1  % check to make sure that the filenames of the waveforms in top and bottom 
                % window are not identical
   if TOP==1, if strcmp(xfilename,filename)==1, 
                errordlg('The  filename of recorded speech can not be the same as the filename of the waveform in the bottom window. Enter a new filename in the Record window.','ERROR in record','on');
                return;
              end
    else
             if strcmp(xfilename,filename2)==1, 
                errordlg('The  filename of recorded speech can not be the same as the filename of the waveform in the top window. Enter a new filename in the Record window.','ERROR in record','on');
                return;
              end
    end
end

y=wavrecord(Dur*xSrate,xSrate,DTYPE);  % start recording
y=double(y);                         % convert type 'int16' integer to double
if strcmp(DTYPE,'uint8')==1
   y=y-128;
end

y=y(10:Dur*xSrate)/maxAmp;            % restrict input amplitude range to [-1, 1)
                                     % skip the first 10 samples, as they might have a DC
wavwrite(y,xSrate,nBits,xfilename);    % save recorded data in a .wav file


if TWOFILES==1 & TOP==1  % set the appropriate variables if two windows
    n_Secs2=(Dur*xSrate-10)/xSrate; 
    mx=max(abs(y));
    agcsc2=MAX_AM/mx;
    HDRSIZE2=44;
    Srate2=xSrate;
    filename2=xfilename;
    ftype2=xftype;
    bpsa2 =xbpsa; 
else  % only one window
    n_Secs=(Dur*xSrate-10)/xSrate; 
    mx=max(abs(y));
    agcsc=MAX_AM/mx;
    HDRSIZE=44;
    Srate=xSrate;
    filename=xfilename;
    ftype=xftype;
    bpsa =xbpsa;   
 end
 
zoomi('out');




return;
%----------------------------------------------
fp= fopen('sndcard.cfg','r');

if fp<0
  errordlg('Could not find souncard config file: sndcard.cfg.  If this file does not exist, then create it and put the name of the record utility program','GETREC');
else
 
 snd = fscanf(fp,'%s');
 fclose(fp);

 if ~isempty(snd) 
    exe=['!' snd];
    eval(exe); 
 else
  str=sprintf('Could not find record utility: %s',snd);
  errordlg(str,'GETREC');
 end

end

