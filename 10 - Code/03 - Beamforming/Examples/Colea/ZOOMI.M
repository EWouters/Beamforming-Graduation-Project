function zoomi(action)

% Copyright (c) 1995 by Philipos C. Loizou
%

global S0 S1 filename filename2 Srate fno fftSize n_Secs
global HDRSIZE cAxes En Be TIME WAV1 CLR TWOFILES En2 Be2 TOP 
global HDRSIZE2 n_Secs2 Srate2 sli wav
global hl hr doit specto1 upFreq upFreq2
global hbot htop doit0 doit1 frst0 frst1 
global bpsa bpsa2 ftype ftype2 LD_LABELS

onebyte=0;

if (S1 > S0) | strcmp(action,'out')==1
	figure(fno);
	if TWOFILES==0, axes(cAxes); end
	doit=1; %used in mclick.m
	if TWOFILES==1 & TOP==1
	  En2=S1; Be2=S0;
	else
	  En=S1; Be=S0;
	end

	
	if strcmp(action,'out')==1
	    set(sli,'Value',0);
	    if TWOFILES==1 & TOP==1
		S0=0;
		S1=round(n_Secs2*Srate2);
		En2=S1;
		Be2=S0;
		frst0=1; doit1=1;
	     else
		S0=0;
		S1=round(n_Secs*Srate);
		En=S1;
		Be=S0;
		doit0=1; % used in mouse-click routine
		frst1=1;
	     end
	end

	if LD_LABELS==1  % --- in case labels have been drawn -----------------

		if strcmp(action,'in'),      label('loadzm'); 
		elseif strcmp(action,'out'), label('load');  
		end;
 	end

	if TWOFILES==1 & TOP==1
	  fname=filename2;
	  offSet=S0*bpsa2+HDRSIZE2; 
	  frst0=1; doit1=1;
	  ftp=ftype2;
	 else
	  fname=filename;
	  offSet=S0*bpsa+HDRSIZE; 
	  doit0=1; frst1=1;
	  ftp=ftype;
	 end

	
	fp = fopen(fname,'r');
	if fp<=0
	  disp('Could not open file in zoomi.m....');
	  return;
	end
	
	
	nSamples=S1-S0 ;	% get the number of samples to read

	st = fseek(fp,offSet,'bof');
   inp=zeros(1,nSamples);
	[inp,cnt] = fread(fp,nSamples,ftp);
 	if cnt ~= nSamples,
	  fclose(fp);
	  errordlg('ERROR reading file ..','ERROR','on');
	  return;
	end
	fclose(fp);


	%----------- Remove the DC bias------------
	meen=mean(inp);
	inp=inp-meen;
	if norm(inp,2) < 1.0e-7
	  if meen < 1.0e-3
		meen=1.0e-3;
   	  end
   	  inp=inp+meen;
	end


	if (TIME)

	  if TWOFILES==1
		if TOP==1
		   	Et=1000*nSamples/Srate2;
			%if isempty(htop) 
			  subplot(2,1,1),  
			  set(gca,'Position',[0.2 0.55 0.775 0.34]);	

			  htop=gca; 
			%else
			%  axes(htop);
			%end
			plot(0:1000/Srate2:(Et-1000/Srate2),inp,'y');
			ylabel('Amplitude');%,'FontSize',9);
			%set(gca,'Units','points','FontSize',9);
			%set(gca,'FontSize',9);
			axis([0 Et min(inp)-200 max(inp)+200]);
			set(gca,'Xcolor','w'); set(gca,'Ycolor','w');
			set(gca,'Color','k');
		else

			
			Et=1000*nSamples/Srate;
			%if isempty(hbot)
			  subplot(2,1,2), 
			  set(gca,'Position',[0.2 0.11 0.775 0.34]);
			  hbot=gca;
			%else
			 
			 % axes(hbot); 
			%end
			
			plot(0:1000/Srate:(Et-1000/Srate),inp,'y');
			xlabel('Time (msecs)');%,'FontSize',9); 
			ylabel('Amplitude');%,'FontSize',9);
			%set(gca,'Units','points','FontSize',9);
			%set(gca,'FontSize',9);
			axis([0 Et min(inp)-200 max(inp)+200]);
			set(gca,'Xcolor','w'); set(gca,'Ycolor','w');
			set(gca,'Color','k');
		end
	
	  else
		
		Et=1000*nSamples/Srate;
		xax=0:1000/Srate:(Et-1000/Srate);
		plot(xax,inp)
		
		axis([0 Et min(inp)-200 max(inp)+200]);
		xlabel('Time (msecs)');%,'FontSize',9);
		ylabel('Amplitude'); %'FontSize',9);
		set(gca,'Xcolor','w'); set(gca,'Ycolor','w');
		set(gca,'Color','k');
		%set(gca,'Units','points','FontSize',9);
	   end
     else % ========== Spectrogram=================
	yLab = [0.5*Srate*upFreq/1000 0];
	ex=(En-Be)*1000/Srate;
	xLab = [0 ex];

	%--- define colormap
	
	if CLR == 0
		nMap=length(colormap);
		x1=gray(nMap);
		x4=flipud(x1);
		colormap(x4);
	
	else
	   colormap('jet');
	end
	if nSamples<1000
	  ovr=32;
	  ns=4;
	elseif nSamples>1000 & nSamples<4000
	  ovr=10;
	  ns=3;
	else
	  ovr=4;
	  ns=3;
	end
	if TWOFILES==1
	  if TOP==1
		yLab = [0.5*Srate2*upFreq2/1000 0];
		ex=(En2-Be2)*1000/Srate2;
		xLab = [0 ex];
		%if isempty(htop)
		  subplot(2,1,1), cla reset; hold off; 
		  set(gca,'Position',[0.2 0.55 0.775 0.34]);	
		  htop=gca;
		%else
		 % axes(htop); 
		%end

		cIm = image(xLab,yLab,spectrg(inp,128,ovr,ns,upFreq2));
   	        axis xy
		ylabel('Freq. (KHz)');
		set(gca,'Xcolor','w'); set(gca,'Ycolor','w');
		get(gca,'YDir');
		%set(gca,'Units','points','FontSize',9);
	  else
		%if isempty(hbot)
		   subplot(2,1,2), cla reset; hold off; 
		   set(gca,'Position',[0.2 0.11 0.775 0.34]);
		   hbot=gca;
		%else
		 %  axes(hbot);
		%end
		
		cIm = image(xLab,yLab,spectrg(inp,128,ovr,ns,upFreq));
		axis xy
		xlabel('Time (msecs)');%;,'FontSize',9);
		ylabel('Freq. (KHz)');%,'FontSize',9);
		%set(gca,'Units','points','FontSize',9);
		set(gca,'Xcolor','w'); set(gca,'Ycolor','w');

	  end
	else %=========== Single display =====================
	 
	  
	    specto1=spectrg(inp,128,ovr,ns,upFreq);
	    
	    cIm = image(xLab,yLab,specto1);
	    axis xy
	    xlabel('Time (msecs)');%,'FontSize',9);
	    ylabel('Freq. (KHz)');%,'FontSize',9);
	    %set(gca,'Units','points','FontSize',9);
  	    set(gca,'Xcolor','w'); set(gca,'Ycolor','w');

	end 
	
    end
 

 

else
	errordlg('Invalid selection. Right mark is less than left mark','ERROR in zoom','on');

end


