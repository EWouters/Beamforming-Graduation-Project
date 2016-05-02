function [inp,nsam]=getvec

%
% Copyright (c) 1995 by Philipos C. Loizou
%

global TWOFILES TOP filename filename2 HDRSIZE HDRSIZE2 bpsa bpsa2
global ftype ftype2 S0 S1 En Be En2 Be2

	if TWOFILES==1 & TOP==1
	  fname=filename2;
	  offSet=Be2*bpsa2+HDRSIZE2; 
	  ftp=ftype2;
	  nsam=	En2-Be2;
	 else
	  fname=filename;
	  offSet=Be*bpsa+HDRSIZE; 
	  ftp=ftype;
	  nsam=En-Be;
	 end

	
	fp = fopen(fname,'r');
	if fp<=0
	  error('Could not open file..');
	end
		

	
	st = fseek(fp,offSet,'bof');
        inp=zeros(1,nsam);
	inp = fread(fp,nsam,ftp);
	
	
	fclose(fp);