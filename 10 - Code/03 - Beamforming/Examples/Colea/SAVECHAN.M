function savechan(inp)

% Copyright (c) 1995 by Philipos C. Loizou
%

global nChannels


%----Open up a dialog box-----------
 [pth,fname] = dlgopen('save',['*.' 'txt']);
 if ((~isstr(fname)) | ~min(size(fname))), return; end	
 fname1=[pth,fname];

 fpc=fopen('channels.txt','r');
 fpout=fopen(fname1,'w+');

 Ap=fscanf(fpc,'%f',[nChannels 900]);

if nargin==1 % save the average values as well
 App=Ap';
 mn=mean(App);
 sd=std(App);
end

 frmt='';
 for i=1:nChannels-1
  frmt=['%f ' frmt];
 end
 frmt=[frmt '%f\n'];
 fprintf(fpout,frmt,Ap);

if nargin==1
 fprintf(fpout,'%f ',mn);
 fprintf(fpout,'\n');
 fprintf(fpout,'%f ',sd);
end

 fclose(fpc);
 fclose(fpout);
