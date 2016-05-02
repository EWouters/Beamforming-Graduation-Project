function savelpc

% Copyright (c) 1996 Philipos C. Loizou
%



[pth,fname] = dlgopen('save',['*.txt']);
 if ((~isstr(fname)) | ~min(size(fname))), return; end	
 fname1=[pth,fname];

global fftFreqs dBMag

fp=fopen(fname1,'w');
y=[fftFreqs ; dBMag'];

fprintf(fp,'%8.2f %4.2f\n',y);
fclose(fp);

