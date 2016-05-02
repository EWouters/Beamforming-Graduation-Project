function savefile(type)

% Copyright (c) 1995 by Philipos C. Loizou
%

global Srate filename HDRSIZE S1 S0 Be En 
global UpperFreq LowFreq center n_Secs WAV1 CLR TWOFILES filename2
global Srate2 HDRSIZE2 Be2 En2 n_Secs2 TOP
global DiffSrate wav tspec modChange


if TWOFILES==1 & TOP==1
   ind=find(filename2 == '.');
   ext = lower(filename2(ind+1:length(filename2)));
else
   ind=find(filename == '.');
   ext = lower(filename(ind+1:length(filename)));
end

%----Open up a dialog box-----------
 [pth,fname] = dlgopen('save',['*.' ext]);
 if ((~isstr(fname)) | ~min(size(fname))), return; end	
 fname1=[pth,fname];

 if TWOFILES==1 & TOP==1
   fp=fopen(filename2,'r');
   hdrs=HDRSIZE2/2;
   
 else
  
   fp=fopen(filename,'r');
   hdrs=HDRSIZE/2;
  
 end

if strcmp(type,'seg') %---------save selected region -----------

 if S1>S0

  if TWOFILES==1 & TOP==1
     hdr=fread(fp,HDRSIZE2/2,'short');
     offSet = S0*2+HDRSIZE2;
     filen=filename2;
  else
     hdr=fread(fp,HDRSIZE/2,'short');
     offSet = S0*2+HDRSIZE;
     filen=filename;
  end

 
    nsam=S1-S0; 
    st = fseek(fp,offSet,'bof');
    x  = fread(fp,nsam,'short');
    
    fpout=fopen(fname1,'w');
    ind=find(filen == '.');
    ext = lower(filen(ind+1:length(filen)));
    savehder(fp,fpout,ext,nsam);%---- adjust #sample-entry in header
    fclose(fp);
    
    fwrite(fpout,x,'short');
    fclose(fpout);
 else
	errordlg('Invalid region selected','ERROR','on');
	fclose(fp);
	return;
 end
else %============ save the whole file ========================

 if modChange==1  % In case the file has been cut or pasted,
		  % modify header appropriately

	 fpout=fopen(fname1,'w');
	 hdr=fread(fp,hdrs,'short');
	 x=fread(fp,inf,'short');
	 
	 savehder(fp,fpout,ext,length(x));
	 fclose(fp);
	 fwrite(fpout,x,'short');
 	 fclose(fpout);

 else

	 x=fread(fp,inf,'short');
	 fclose(fp);

	 fpout=fopen(fname1,'w');
 	 fwrite(fpout,x,'short');
 	 fclose(fpout);
  end

end
