function spec = spectrg(wave,segsize,nlap,ntrans,upfr);

% Copyright (c) by 1998 Philipos C. Loizou
%

global PREEMPH WIND_SIZE SET_WIN UPD_WIN SET_UPD NAR_BAND 
global SPEC_EXP



if PREEMPH>0
  if SPEC_EXP<0.5
   wave = filter([1 -0.6],[1],wave);
  else
   wave = filter([1 -0.8],[1],wave);
  end
end

if SET_WIN>0  %-- use user-selected window size
 segsize=WIND_SIZE; 
end

if SET_UPD>0
  slap=UPD_WIN;
else
 slap=segsize/nlap;
end


s = length(wave);

nsegs = floor(s/slap)-floor(segsize/slap)+1;

slap=floor(slap);

ysize=floor(ntrans/2*segsize*upfr);
spec = zeros(ysize,nsegs);


seg2=zeros(ysize,1);

window = hanning(segsize);

%---take the FFT of  the waveform ----
%
k=1;
for i = 1:nsegs
 seg = zeros(ntrans*segsize,1); % leave half full of zeroes
 seg(1:segsize) = window.*wave(k:k+segsize-1);

 
 seg = abs(fft(seg));
 seg2=seg(1:ysize);

 spec(:,i)=flipud(filter([1],[1 -0.2],seg2.*seg2));


 k=k+slap;
end %----------------------------------



for i=1:ysize    % smooth the channels
 spec(i,:) = filter([1],[1 -0.2],spec(i,:));
end

% =================== compress with root of amplitude  ================
%
if NAR_BAND==0 % wideband spectrogram

	off = 0.001*max(max(spec));
	spec = (off+spec).^SPEC_EXP-off^SPEC_EXP;	
	spec = 255/max(max(spec))*spec;

else % narrowband spectrogram 
	off = 0.001*max(max(spec));
	%spec = (off+spec).^0.12-off^0.12;
	spec = (off+spec).^SPEC_EXP-off^SPEC_EXP;	
	spec = 255/max(max(spec))*spec;  
end
