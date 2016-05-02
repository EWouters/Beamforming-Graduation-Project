function estf0(type,action)

% Copyright (c) 1995 Philipos C. Loizou
%

global nChannels filename Srate eFig
global HDRSIZE S0 S1 ratePps En Be  n_Secs En2 Be2
global filename2 TWOFILES n_Secs2 Srate2 TOP HDRSIZE2 
global bpsa bpsa2 ftype ftype2 bf0 af0 SrateChange


if nargin==1, action='plot'; end;

pos = get(0, 'screensize'); % get the screensize
sWi = pos(3);
sHe = pos(4);


WIDTH   =round(0.9375*sWi);
HEIGHT = round(0.5*sHe);
LEFT    =round(0.025*sWi);
BOTTOM  =20; 

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

%-----select a method for pitch detection -----------
%
if strcmp(type,'cepstrum')
	 CEPSTRUM=1;	
 else 
	CEPSTRUM=0; 
	if isempty(bf0) | SrateChange==1
 		[bf0,af0]=butter(4,900/(sr/2));
	end
 end;


%---- Do some error checking on the signal level ---
meen=mean(x);
x= x - meen; %----------remove the DC bias---


nmF='F0 Contour Plot';


if isempty(eFig) 
	eFig =  figure('Units', 'Pixels', 'Position', [LEFT BOTTOM WIDTH HEIGHT],...
	'Pointer','crosshair',...
	'Resize','on','Name',nmF,'NumberTitle','Off');
	crM=1;
else
	figure(eFig);
	set(eFig,'Name',nmF);
	crM=0;
end


updRate=floor(20*sr/1000);  %-- Update every 20 msec
if CEPSTRUM==1
 fRate=floor(40*sr/1000);  % -- Use a 40 msec segment
else
 fRate=floor(30*sr/1000);  % -- Use a 30 msec segment
end
nFrames=floor(n_samples/updRate)-1;

% --- Do some error checking in the length of the region selected ---------
%
if nFrames<1
  errordlg('Region selected was too small..','ERROR in pitch estimation','on');
  delete(eFig);
  eFig=[];
  return;
end	
k=1;
f01=zeros(1,nFrames);
f0=zeros(1,nFrames);

m=1;
avgF0=0;
for t=1:nFrames
		yin=x(k:k+fRate-1);
		
		if CEPSTRUM==1
			a=pitch(fRate,sr,yin); % Use the cepstrum method
		else
	        	a=pitchaut(fRate,sr,yin); % Use the autocorr. method
		end
		f0(t)=a;
		if t>2 & nFrames>3 %--do some median filtering
		  z=f0(t-2:t); 
		  md=median(z);
		  f01(t-2)=md;
		  if md > 0
		    avgF0=avgF0+md;
		    m=m+1;
		   end
		elseif nFrames<=3
		  f01(t)=a;
		  avgF0=avgF0+a;
		  m=m+1;
		end

		
k=k+updRate;
    
end


if m==1, avgF0=0; else, avgF0=avgF0/(m-1); end;

str= sprintf('Average F0=%5.2f Hz',avgF0);

set(eFig,'Name',str);

%---------------Save F0 values in an ASCII file ---------------
%
if strcmp(action,'save')

  [pth,f0name] = dlgopen('save',['*.pit']);
  if ((~isstr(f0name)) | ~min(size(f0name))), return; end	
  fname1=[pth,f0name];
  fpout=fopen(fname1,'w');
  upd=round(1000*updRate/sr);

  fprintf(fpout,'t(msec) F0(Hz)\n-------+-----\n');
  k=1;
  for t=upd/2:upd:nFrames*upd
	fprintf(fpout,'%4.2f    %5.2f\n',t,f01(k));
  k=k+1;
  end 
 
  fclose(fpout);
end


%-------------- Plot F0 contour  ---------------------------------
%
xt=1:nFrames;
xt=20*xt;

if ~isempty(xt) & nFrames>1
  plot(xt,f01)
  axis([xt(1) xt(nFrames) 0 max(f01)+50]);
else
  if nFrames==1, plot(f01,'o'); else, plot(f01); end;
end

ylabel('Hz');
xlabel('Time (msecs)');





%--------------Create the 'close' button' ---------------

xywh = get(eFig, 'Position');

% Buttons.
left = 6;
wide = 60;
top  = xywh(4) - 10;
high = 22;
inc  = high + 8;

uicontrol('Style', 'PushB', 'Callback', 'closem(''efig'')', ...
          'HorizontalAlign','center', 'String', 'Close', ...
          'Position', [left top-high wide high]);  

if crM==1 
 if strcmp(type,'cepstrum'), str='estf0(''cepstrum'',''save'')';
 else str='estf0(''autoc'',''save'')'; end;
 uimenu('Label','Save pitch values','Callback',str);
end
