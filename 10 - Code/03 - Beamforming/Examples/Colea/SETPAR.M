function setpar(type)

% Copyright (c) 1995 Philipos C. Loizou
%

global fft_par S0 SET_X_AXIS F_MAX XFFT XFFT_TIMES
global foha fore

if strcmp(type,'FFT_line')
  fft_par(1)=1;
elseif strcmp(type,'FFT_pick')
  fft_par(1)=0;
elseif strcmp(type,'range_def')
  SET_X_AXIS=0;
elseif strcmp(type,'range_5k')
  SET_X_AXIS=1; F_MAX=5000;
elseif strcmp(type,'range_4k')
   SET_X_AXIS=1; F_MAX=4000;
elseif strcmp(type,'range_32')
   SET_X_AXIS=1; F_MAX=3200;
elseif strcmp(type,'size_def')
   XFFT=0;
elseif strcmp(type,'size_x2')
   XFFT=1; XFFT_TIMES=2;
elseif strcmp(type,'size_x4')
   XFFT=1; XFFT_TIMES=4;
elseif strcmp(type,'hamming')
   fft_par(2)=1;
   set(foha,'Checked','on');
   set(fore,'Checked','off');
elseif strcmp(type,'rect')
   fft_par(2)=0;
   set(foha,'Checked','off');
   set(fore,'Checked','on');

end

pllpc(S0)

