function endpoint


inpfile = 'female.dat';
labdir  = 'c:\colea\labels\';
nFiles  = 1600;
Srate = 16000;


fpi=fopen(inpfile,'r');


for m=1:nFiles  %-------Outer loop ----------------

  filename = fscanf(fpi,'%s',1);

 if ~isempty(filename) 

  [x,n_samples,vowel,basename] = getfile(filename);
 
n_Secs    = n_samples/Srate;
Dur=10.0;   % Duration in msec of window



%---------------- Process input waveform ---------------------
fSize= Dur*Srate/1000;
nFrames=floor(n_samples/fSize);
k=1;
engy=zeros(1,nFrames);
for i=1:nFrames
	y=x(k:k+fSize-1);
	engy(i)=10*log10(norm(y));
	k=k+fSize;
end
mx=max(engy); mn=min(engy);
%fprintf('max=%f min=%f\n',mx,mn);
ind=find(engy>(mx-5));
lind=length(ind);
onSample=(ind(1)-1)*fSize;
if (ind(lind)-ind(lind-1) > 1)
  fprintf(' ***Warning for file: %s (diff=%d)\n',filename,ind(lind)-ind(lind-1));
  offSample=(ind(lind-1)-1)*fSize;
else
  offSample=(ind(lind)-1)*fSize;
end
vDur=(offSample-onSample)*1000/Srate;

fprintf('%s: beg=%d end=%d (Dur:%f)\n',filename,onSample,offSample,vDur);

%-------Output data to a label file--------------
savefile(labdir,basename,onSample,offSample,vowel);
else
  fprintf('\n\n A total of %d files processed\n',m-1);
  return;
end

end


fprintf('\n\n A total of %d files processed\n',m-1);

