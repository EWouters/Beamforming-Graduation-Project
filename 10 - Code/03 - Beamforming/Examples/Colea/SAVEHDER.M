function savehder(fpin,fpout,ext,nsamples)

% Adjust the entry in the header regarding  number of samples

%
% Copyright (c) 1996 by Philipos C. Loizou
%

st=fseek(fpin,0,-1);
if st<0
 error('Error in saving header');
end

if strcmp(ext,'ils') 	 %---- ILS --- 

	hdr=fread(fpin,256,'short');
	hdr(6)=floor(nsamples/256);
	fwrite(fpout,hdr,'short');		
	

elseif strcmp(ext,'adf') %-- ADF format ---

	csre=fread(fpin,8,'char');
	fwrite(fpout,csre,'char');
	numsam=fread(fpin,1,'int32');
	numsam=nsamples;
	fwrite(fpout,numsam,'int32');
	hdr=fread(fpin,250,'short');
	fwrite(fpout,hdr,'short');	
	
		
elseif strcmp(ext,'adc') % -- TIMIT ----
	xx=fread(fpin,4,'short');  
	fwrite(fpout,xx,'short'); 
	nsam=fread(fpin,1,'int32'); % number of samples
	nsam=nsamples;
	fwrite(fpout,nsam,'int32');
	

elseif strcmp(ext,'w')   % --vowel files

	hdr=fread(fpin,256,'short');
	fwrite(fpout,hdr,'short');	
	

elseif strcmp(ext,'wav') % -- WAV files
	
	xx=fread(fpin,4,'char');
	fwrite(fpout,xx,'char');
        numsa=fread(fpin,1,'int32');  % length in bytes of rest of file
	numsa=2*nsamples+36;
	fwrite(fpout,numsa,'int32');

	xx1=fread(fpin,16,'short');
	fwrite(fpout,xx1,'short');
	nsam=fread(fpin,1,'int32'); % Number of samples in bytes
	nsam=2*nsamples;
	fwrite(fpout,nsam,'int32');
	
end  


