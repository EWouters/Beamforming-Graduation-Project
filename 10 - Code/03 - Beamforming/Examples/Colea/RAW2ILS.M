function raw2ils(filename,nbytes,srate)
% Usage : raw2ils infile [NumberOfBytesToSkip SamplingFreq]
%
%

if nargin==0
 fprintf('Usage : raw2ils infile [NumberOfBytesToSkip SamplingFreq]\n');
 return;
end

if nargin<2
 nbytes=512;  % number of bytes to skip
end

 if nargin<3
    srate=16000;
 end

  
fp=fopen(filename,'r');

if fp<0
 fprintf('ERROR! Could not find file: %s\n',filename);
 fprintf('...skipping file\n');
 return;
end

ind = find(filename == '.');
if ind>1
 outname=[filename(1:ind-1) '.ils'];
else
 outname=[filename '.ils'];
end

fpout= fopen(outname,'w');


 st=fseek(fp,nbytes,-1);  % Skip nbytes in header
 header = zeros(1,256);
 

y=fread(fp,inf,'short');

nblocks=length(y)/256;
mrk1=-32000;
mrk2=32149;

header(6) =nblocks;
header(62)=srate;
header(63)=mrk1;
header(64)=mrk2;

fwrite(fpout,header,'short');
fwrite(fpout,y,'short');
fclose(fpout);

