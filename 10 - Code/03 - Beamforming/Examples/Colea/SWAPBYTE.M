function [out] = swapbyte(infile,hdrs) 


% Copyright (c) 1996 by Philipos C. Loizou
%
%

fp=fopen(infile,'r');
if fp<0, error('Unable to open the file in swapbyte.m ');
end

hdrs
fseek(fp,hdrs,'bof'); % ..... skip hdrs bytes in header 
xin=fread(fp,inf,'ushort');

hi=floor(xin/256); % get the high byte
lo=xin-256*hi;     % get the low byte
out=256*lo+hi;     % swap


% .. convert the unsigned representation to signed representation ...
%
mx=32768*2;
med=32768;
neg=find(out>med); lneg=length(neg);
if lneg>0
 out(neg)=out(neg)-mx*ones(lneg,1);
end

fclose(fp);




































