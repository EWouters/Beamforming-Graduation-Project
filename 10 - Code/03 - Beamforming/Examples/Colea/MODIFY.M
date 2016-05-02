function modify(action)

% Copyright (c) 1995 by Philipos C. Loizou
%

global S0 S1 filename filename2 Srate fno  wAxes fftSize n_Secs
global HDRSIZE cAxes En Be TIME WAV1 CLR TWOFILES En2 Be2 TOP 
global HDRSIZE2 n_Secs2 Srate2 sli wav fpmod fpmod2 singldisp rld
global newname newname2 agcsc agsc2 MAX_AM
global snrFig snrOp bpsa bpsa2 ftype ftype2 GAUSN




if (S1 > S0)
   if strcmp(action,'noise')~=1,   figure(fno); end;
   
	  fname=filename;
	  
	
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
	  

	nSamples=S1-S0+1; 	% get the number of samples to read

	if TWOFILES==1 & TOP==1	
	 inp =fread(fpmod2,inf,ftype2);
	 hdr2=HDRSIZE2/2;
	 mn=mean(inp(hdr2:length(inp)));
	 fclose(fpmod2);
	 fpmod2 = fopen(newname2,'w+');
	else
	  inp =fread(fpmod,inf,ftype);
	  hdr2=HDRSIZE/2;
	  mn=mean(inp(hdr2:length(inp)));
	  fclose(fpmod);
	  fpmod = fopen(newname,'w+');
	end
	
  if strcmp(action,'noise')==1  % case it is noise, find out what kind..
	if GAUSN==1, action='gnoise'; else action='spnoise'; end;
  end

  % &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
  %   
	if strcmp(action,'zero') % ====== Zero segment =================
	   inp(hdr2+S0:hdr2+S1)=mn*ones(1,S1-S0+1);    
	elseif strcmp(action,'multi2') %-- Amplify by 2-----
	   x=inp(hdr2+S0:hdr2+S1); 
	   x=x-mean(x); mx=2*max(x);
	   inp(hdr2+S0:hdr2+S1)=2*x+mn*ones(S1-S0+1,1);
	elseif strcmp(action,'multi05') %--- attenuate by a factor of 0.5
	   x=inp(hdr2+S0:hdr2+S1); 
	   x=x-mean(x); mx=0.5*max(x);
	   inp(hdr2+S0:hdr2+S1)=0.5*x+mn*ones(S1-S0+1,1);
	
	elseif strcmp(action,'scn') % ==== Signal Correlated Noise ===
	   
	   mpy=zeros(1,nSamples);
	   ns=rand(1,nSamples)-0.5;
	   mpy=sign(ns);  % 1 or -1 with a prob of 0.5
	   x2=inp(hdr2+S0:hdr2+S1);
	   x2=x2-mean(x2); mx=max(x2);
	   inp(hdr2+S0:hdr2+S1)=mpy.*x2'+mn*ones(1,S1-S0+1);

	elseif strcmp(action,'gnoise') % ==== Add Gausian noise ====
	   x=inp(hdr2+S0:hdr2+S1); 
	   x=x-mean(x); 
	   se=norm(x,2)^2/nSamples; %signal energy
	   SNR=str2num(get(snrOp,'String'));
	   if  isempty(SNR)
		errordlg('ERROR in SNR value','ERROR','on');
		if TOP==1
		 filename2=oldfile; fclose(fpmod2); rld=1;
		else
		  filename=oldfile; fclose(fpmod); singldisp=1;
		end
		return;
	   end
	   nsc=se/(10^(SNR/10));
	   y=sqrt(nsc)*randn(nSamples,1);
	   ne=norm(y,2)^2/nSamples;  
	   fprintf('Estimated SNR=%f\n',10*log10(se/ne));
	   x = x+y;   mx=max(x);
 	   inp(hdr2+S0:hdr2+S1)=x+mn*ones(S1-S0+1,1);

	elseif strcmp(action,'spnoise') % ==== Add  noise from a file====
	   x=inp(hdr2+S0:hdr2+S1); 
	   x=x-mean(x); 
	   se=norm(x,2)^2/nSamples; %signal energy
	   SNR=str2num(get(snrOp,'String'));
	   if  isempty(SNR)
		errordlg('ERROR in SNR value','ERROR','on');
		if TOP==1
		 filename2=oldfile; fclose(fpmod2); rld=1;
		else
		  filename=oldfile; fclose(fpmod); singldisp=1;
		end
		return;
	   end
	   nsc=se/(10^(SNR/10));
	       %---------- get the noise from file -----
		 [pth,fname] = dlgopen('open','*.ils;*.wav');
       if ((~isstr(fname)) | ~min(size(fname))), 
          if TOP==1
             filename2=oldfile; fclose(fpmod2); rld=1;
          else
             filename=oldfile; fclose(fpmod); singldisp=1;
          end
          return;
       end  
         noisefile=[pth,fname];
		   fpn=fopen(noisefile,'r');
         
         ind1=find(fname == '.');  % read the header first 
         if length(ind1)>1, ind=ind1(length(ind1)); else, ind=ind1; end;
         ext = lower(fname(ind+1:length(fname))); 
         [hdrs, x1, x2, ftyp] =  gethdr(fpn,ext);  
         
	        
	        [y,cnt]=fread(fpn,nSamples,ftyp);	
           fclose(fpn);
           if cnt<nSamples  % --not enough samples in the noise file
              if TOP==1
                 filename2=oldfile; fclose(fpmod2); rld=1;
              else
                 filename=oldfile; fclose(fpmod); singldisp=1;
              end
              errordlg('Not enough samples in the noise file.','ERROR','on');
              return;

           end
	    ny=norm(y,2)^2/nSamples;
	    y=sqrt(nsc/ny)*y;
	    ne=norm(y,2)^2/nSamples; 
	    fprintf('Estimated SNR=%f\n',10*log10(se/ne));
	    x = x+y;   mx=max(x);
 	   inp(hdr2+S0:hdr2+S1)=x+mn*ones(S1-S0+1,1);
	end

%-- Adjust the maximum amplitude of the modified signal changed	
%
if ~strcmp(action,'zero') % case action is zeroing, dont bother with max
  if TWOFILES==1 & TOP==1
	agcsc2=MAX_AM/mx;
  else	
	 agcsc=MAX_AM/mx; 
  end
end
  
	if TWOFILES==1 & TOP==1
 	 fwrite(fpmod2,inp,ftype2);	
	 fclose(fpmod2);
	 S0=Be2; S1=En2;
	else
	 fwrite(fpmod,inp,ftype);	
	 fclose(fpmod);
	 S0=Be; S1=En;
	end
	
	
	zoomi('in');

	
else
	disp(' ');
	disp('ERROR! Invalid selection. Right mark is less than left mark..');
end


