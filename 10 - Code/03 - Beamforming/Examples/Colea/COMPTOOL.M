function comptool(type)

% Copyright (c) 1995 Philipos C. Loizou
%

global nChannels filename  Srate
global HDRSIZE S0 S1 anFig Be En
global bpsa bpsa2 ftype ftype2 TWOFILES TOP filename2 HDRSIZE2
global Be2 En2 SrateChange
global AnCmp NCmp CURS N_comp W_comp



if TWOFILES==0
   errordlg('Two files are needed for comparison.','ERROR','on');
   return;
end


if strcmp(type,'cursor')
 CURS=1;
 return;
elseif strcmp(type,'overall')
 CURS=0;
 return;
elseif strcmp(type,'analysis')
 W_comp=str2num(get(AnCmp,'String'));
 return;
elseif strcmp(type,'order')
 N_comp=str2num(get(NCmp,'String'));
 return;
end;


wind_size=round(W_comp*Srate/1000);  % Window size


pos = get(0, 'screensize'); % get the screensize
sWi = pos(3);
sHe = pos(4);

WIDTH   =round(0.9375*sWi);
HEIGHT  =round(0.383*sHe) ;	
LEFT    =round(0.025*sWi);
BOTTOM  =20; 

 	if CURS==1  % --------- just a single frame----------------
		offSet = S0*bpsa+HDRSIZE;
		n_samples=wind_size;
		
		fname=filename;

	     fp = fopen(fname,'r');

	     if fp <=0
		disp('ERROR! File not found..')
		return;
	     end

	     st = fseek(fp,offSet,'bof');
       	     x=zeros(1,n_samples);
	     x = fread(fp,n_samples,ftype);
	     fclose(fp);

	     fp2 = fopen(filename2,'r');

	     if fp2 <=0
		disp('ERROR! File not found..')
		return;
	     end
	     offSet = S0*bpsa+HDRSIZE2;
	     st = fseek(fp2,offSet,'bof');
       	     y=zeros(1,n_samples);
	     y = fread(fp,n_samples,ftype2);
	     fclose(fp2);

	     nFrames=1;
	     opt='single';

	else % ------------- process whole file or window ---------
	    fp = fopen(filename,'r');
	     n_samples=En-Be;
	     if fp <=0
		disp('ERROR! File not found..')
		return;
	     end
	     offSet = Be*bpsa+HDRSIZE;
	     st = fseek(fp,offSet,'bof');
	     x = fread(fp,n_samples,ftype);
	     fclose(fp);
	   

	    fp2 = fopen(filename2,'r');

	     if fp2 <=0
		disp('ERROR! File not found..')
		return;
	     end
	     st = fseek(fp2,offSet,'bof');
	     [y,cnt] = fread(fp2,n_samples,ftype2);
	     if cnt<n_samples, n_samples=cnt; end;
	     fclose(fp2);
	     
	
	     nFrames=floor(n_samples/wind_size)-1;
	     opt='all';
	end
	    

	    

%----------remove the DC bias----

x= x - mean(x);
y= y -mean(y);


% -------------------Main loop: compare two waveforms --------------
%
k=1;
distor=zeros(1,nFrames);

for t=1:nFrames
	xtmp=x(k:k+wind_size-1);
	ytmp=y(k:k+wind_size-1);
	dst = distance(xtmp,ytmp',N_comp,type,opt);	
	distor(t)=dst;
 	k=k+wind_size;
end
% ------------------------------------------------------------------
mn=mean(distor);
st=std(distor);

if CURS==0

nmF= sprintf('Mean:%f       Stdv:%f',mn,st);

if (isempty(anFig))	
	anFig =  figure('Units', 'Pixels', 'Position', [LEFT BOTTOM WIDTH HEIGHT],...
	'Pointer','crosshair',...
	'Resize','on','Name',nmF,'NumberTitle','Off');

else
	figure(anFig);
	set(anFig,'Name',nmF);
	
end

subplot(2,1,1),plot(distor);
axis([1 nFrames min(distor) max(distor)]);
xlabel('Frames');
subplot(2,1,2),plot(x);
axis([0 n_samples min(x)-50 max(x)+50]);
xlabel('Samples');
%----------- Create the 'close' button'
xywh = get(anFig, 'Position');

% Buttons.
left = 6;
wide = 60;
top  = xywh(4) - 10;
high = 22;
inc  = high + 8;

uicontrol('Style', 'PushB', 'Callback', 'closem(''an'')', ...
          'HorizontalAlign','center', 'String', 'Close', ...
          'Position', [left top-high wide high]);   

end