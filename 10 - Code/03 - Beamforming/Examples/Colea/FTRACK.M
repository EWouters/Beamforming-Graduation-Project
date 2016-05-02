function ftrack(action)

% Show the formant track
%

% Copyright (c) 1995 by Philipos C. Loizou
%

global nChannels filename filterA filterB Srate ftrFig
global HDRSIZE S0 S1 ratePps En Be bl al WAV1 n_Secs En2 Be2
global filename2 TWOFILES n_Secs2 Srate2 TOP HDRSIZE2 fFig
global saveFmnts clsedFrm ftype ftype2 bpsa bpsa2



pos = get(0, 'screensize'); % get the screensize
sWi = pos(3);
sHe = pos(4);


WIDTH   =round(0.9375*sWi);
HEIGHT = round(0.5*sHe);
LEFT    =round(0.025*sWi);
BOTTOM  =20; 

if isempty(saveFmnts)
  saveFmnts=0;
end

if isempty(clsedFrm)
  clsedFrm=1;
end

if TWOFILES==1 & TOP==1
 fname=filename2;
 offSet=Be2*bpsa2+HDRSIZE2;
 n_samples=En2-Be2; %round(n_Secs2*Srate2)
 ftp=ftype2;
 sr=Srate2;
else
 fname=filename;
 offSet=Be*bpsa+HDRSIZE;
 n_samples=En-Be; %round(n_Secs*Srate)
 ftp=ftype;
 sr=Srate;
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


nmF='Formant Tracks';


if isempty(ftrFig) 
	ftrFig =  figure('Units', 'Pixels', 'Position', [LEFT BOTTOM WIDTH HEIGHT],...
		'Resize','on','Name',nmF,'NumberTitle','Off');
  %'Pointer','crosshair',...

else
	figure(ftrFig);
	set(ftrFig,'Name',nmF);
end

%----Set the LPC order depending on sampling rate ------

if sr>12000 & sr < 24000
 Ncoeffs=16;
elseif sr<=12000
   Ncoeffs=14;
else % CD quality Fs= 44 KHz
   Ncoeffs=28;
end

durat=20; 		 	% -- Use a 20 msec segment
fRate=floor(durat*sr/1000);  
nFrames=floor(n_samples/fRate);
window=hamming(fRate);
	

formants=zeros(3,nFrames);


k=1;
for t=1:nFrames
		yin=x(k:k+fRate-1);
		a = lpc(window.*yin,Ncoeffs);
		[f1,f2,f3]=frmnts(a,sr);	
		formants(1,t)=f1; formants(2,t)=f2; formants(3,t)=f3;		
  	
  k=k+fRate;
    
end

if strcmp(action,'save')  %--- save F1,F2,F3 in an ASCII file
	
	formName=[fname(1:length(fname)-3) 'frm'];
	fpout=fopen(formName,'w');
	time=1:durat:nFrames*durat;
	fprintf(fpout,'t(msec)  F1(Hz)  F2(Hz)  F3(Hz)\n');
	for i=1:nFrames
	  fprintf(fpout,'%6.2f %7.3f %7.3f %7.3f\n',time(i),formants(1,i),formants(2,i),...
	 	formants(3,i));
	end
	msg=sprintf('Formant values were saved in the ASCII file ''%s'' ',lower(formName));
	errordlg(msg,'Saving file','on');
	fclose(fpout);

elseif strcmp(action,'plot') %--- Plot Formant contour  -----------



Et=nFrames*20;
xax=1:20:Et;

hold off

plot(xax,formants(1,:),'y',xax,formants(2,:),'r',xax,formants(3,:),'m');
  
ylabel('Freq. (Hz)');
xlabel('Time (msec)');
set(gca,'Xlim',[1 Et]);

%----------- Create the 'close' button'-----------------------

if clsedFrm ==1

xywh = get(ftrFig, 'Position');

% Buttons.
left = 6;
wide = 60;
top  = xywh(4) - 10;
high = 22;
inc  = high + 8;

uicontrol('Style', 'PushB', 'Callback', 'closem(''ftr'')', ...
          'HorizontalAlign','center', 'String', 'Close', ...
          'Position', [left top-high wide high]);  

uimenu('Label','Save Formants','Callback','saveparm(''formnts'')');
clsedFrm=0;
end

end
