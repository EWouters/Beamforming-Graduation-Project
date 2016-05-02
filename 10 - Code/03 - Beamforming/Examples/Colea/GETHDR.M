function [HDRSIZE, Srate1, bps, filet] =  gethdr(fp,ext)


bps=2; filet='short';  % bytes per samples

if strcmp(ext,'ils') %---- ILS --- 
	HDRSIZE=512;   % Header size in bytes
	[xx, cnt] = fread(fp,HDRSIZE/2,'short');
	if cnt < HDRSIZE/2
	  fprintf('ERROR in reading file %s (possibly a zero-bytes file)\n',filename);
	  return;
	end
   Srate1 = xx(62); 
   
elseif strcmp(ext,'adf') %-- ADF format -CSRE ----
	HDRSIZE=512;
	csre=fread(fp,8,'char');
	setstr(csre);
	numsam=fread(fp,1,'int32');
 	xx=fread(fp,5,'short'); bits=xx(4); cd=xx(5);
	srt=fread(fp,1,'float');
	Srate1=1000*srt;
	fseek(fp,HDRSIZE,'bof');
   
elseif strcmp(ext,'adc')  %-- old TIMIT format----
	xx=fread(fp,3,'short');  % xx(1)= hdrsize in words
				 % xx(2)= version
				 % xx(3)= number of channels 
	if xx(2)>10 | xx(3)>3
	  error('ERROR reading TIMIT header..');
	end
	HDRSIZE=xx(1)*2; % header size in bytes 
	if HDRSIZE<0 | HDRSIZE>20
	   error('ERROR reading TIMIT header..');
	end
	srt=fread(fp,1,'short'); % sampling period in 1/4 microsecs
	nsam=fread(fp,1,'int32'); % number of samples
	if srt>0
	  Srate1=4*10^6/srt; 
	else
	 error('ERROR reading TIMIT header..');
	end
   
 
 elseif strcmp(ext,'wav')  % -- MS Windows WAV files or TIMIT files
	xx=fread(fp,4,'char');
	riff=(setstr(xx))';
      if strcmp(riff,'RIFF') ~= 1   % maybe a SPHERE file
        fseek(fp,0,'bof');
        nist=fscanf(fp,'%s',1);
        if strcmp(nist(1:4),'NIST') ==0
          error('Error reading voice file header, not a MS Windows WAV nor TIMIT ..');
          return;
        end 
        
        nn=fscanf(fp,'%d',1);
        for i=1:5
          X=fscanf(fp,'%s %s %s',3);
        end

        X=fscanf(fp,'%s %s',2);
        Srate1=fscanf(fp,'%d',1);
      
        for i=1:2
          X=fscanf(fp,'%s %s %s',3);
        end
	
        X=fscanf(fp,'%s %s',2);
        bps=fscanf(fp,'%d',1);
	
        fseek(fp,1024,'bof'); % skip the header
        HDRSIZE=1024;	% Header Size.  
   else  				%------ maybe a MS windows .wav file
        numsa=fread(fp,1,'int32');  % length in bytes of rest of file
        xx=fread(fp,7,'short');
        chan=fread(fp,1,'short'); 
        Srate1=fread(fp,1,'int32');  % -- Get the sampling frequency-------
        datasec=fread(fp,2,'short');
        bytesamp=fread(fp,1,'short');
        if bytesamp==1, bps=1; filet='char'; end
        bitssamp=fread(fp,1,'short');
        xx=fread(fp,4,'char'); 
        if strcmp('data',setstr(xx)')==1 | strcmp('fact',setstr(xx)')==1
           if strcmp('fact',setstr(xx)')==1, nsam=fread(fp,3,'int32'); end;
              
         else
           fprintf('ERROR! Not a valid wav file. Missing data.\n');
        end
        nsam=fread(fp,1,'int32'); % Number of samples in bytes
        HDRSIZE=ftell(fp);
 
 end

   
    
elseif strcmp(ext,'voc') %-------- Creative Lab's VOC files-------

	cint=[1 2^8]';
	xx=fread(fp,20,'char');
	vf=setstr(xx');
	if strcmp(vf(1:19),'Creative Voice File')==0
	  disp('ERROR! File is not a proper VOC file');
	  return;
	end
	xoff=fread(fp,1,'short');
	x1=fread(fp,2,'uchar'); % frmt=sum(x1 .* cint)
	x1=fread(fp,2,'uchar'); % vid=sum(x1 .* cint)
	blk_type=fread(fp,1,'uchar');
	x3=fread(fp,3,'uchar');
	blen=sum(x3 .* [cint; 2^16])-2;
	if blk_type==1  % Voice data
	  tconst=fread(fp,1,'uchar');
	  Srate1=10^6/(256-tconst);
	  pck=fread(fp,1,'uchar');
	  if pck ~=0, disp('WARNING! Voice data is not in 8-bit sample format'); end;
	  fread(fp,1,'uchar');
	else
	  Srate1=11125;
	  disp('WARNING! Not a voice file.');
	end
	HDRSIZE=ftell(fp);
	WAV=1; bps=1; filet='char';
else
	
	
   fprintf('ERROR! Unknown file extension..\n');
    Srate1=0;   
	 convert; % convert file format
    
 end  
	

