function playf(cmd)

%
% Copyright (c) 1995 by Philipos C. Loizou
%

global filename Srate
global HDRSIZE S0 S1  Be En WAV1 Srate2 HDRSIZE2 Be2 En2
global TWOFILES TOP filename2 wav
global bpsa bpsa2 ftype ftype2 VOL_MAX VOL_NORM 



onebyte=WAV1;
	
	if TWOFILES==1

	  	if strcmp(cmd,'sel') %-- play only a selected region
	   		if S1>S0
	     		   n_samples=S1-S0;
	  		 else
	     		   errordlg('Invalid selection','ERROR in play','on');
	    		   return;
	   		 end
	   		bes=S0;
		else %--play the whole file
	   		if TOP==1, n_samples=En2-Be2; bes=Be2; 
			else       n_samples=En-Be; bes=Be;	
			end			 
		end

		if TOP==1
		  offSet=bes*bpsa2+HDRSIZE2; 
		  fname=filename2;
		  ftp=ftype2;
		else		
		  offSet=bes*bpsa+HDRSIZE; 
		  fname=filename;
		  ftp=ftype;
		end
	

	fp = fopen(fname,'r');

	if fp <=0
	  disp('ERROR! File not found..')
	  return;
	end


	st = fseek(fp,offSet,'bof');
	if st<0, disp('FAILURE in reading'); return; end;
        x=zeros(1,n_samples);
	[x,cnt] = fread(fp,n_samples,ftp);
	if cnt ~= n_samples,
	  disp('ERROR in reading in playf.m');
	end
	    
	fclose(fp);
   else  % ---------- single window -------------------
	fp = fopen(filename,'r');

	if fp <=0
	  disp('ERROR! File not found..')
	  return;
	end

	if strcmp(cmd,'sel')
	   if S1>S0
	     n_samples=S1-S0;
	   else
	     errordlg('Invalid selection','ERROR in play','on');
	     fclose(fp);
	     return;
	   end
	   bes=S0;
	else %--play the whole file or whole window
	   n_samples=En-Be;
	   bes=Be; 
	end

	offSet = bes*bpsa+HDRSIZE;
	st = fseek(fp,offSet,'bof');
        x=zeros(1,n_samples);
	x = fread(fp,n_samples,ftype);
  
	fclose(fp);

  end


%----------remove the DC bias----
meen=mean(x);
x= x - meen;

if VOL_NORM==1 % normalize volume - autoscale

  mx=max(abs(x));
  mx=mx*(1+VOL_MAX);

elseif VOL_NORM==2 % have the option to scale 

  maxx=max(abs(x));
  mx=32600;
  new_max=VOL_MAX*mx;
  x=x*new_max/maxx;
  
elseif VOL_NORM==3 % -- absolute scale

  mx=32600;

end

v=[-mx-10 mx+10];


if TWOFILES==1
   if TOP==1, sr=Srate2; else sr=Srate; end;
else
 sr=Srate;
end


%---Play the speech file -----

soundsc(x,sr,v);


