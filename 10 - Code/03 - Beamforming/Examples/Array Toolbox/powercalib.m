function [ calibpos ] = powercalib( files, fovp, nwlen, posthresh, posnum)
% This function expects N many input audio files, all of which contain data
% recorded from a sound source in the same position for all files.
% For each file, the script will roll through a set of possible microphone
% positions and record the power each time. At the end, the sound source
% positions corresponding to the top 5% coherent power are averaged and
% used as the sound source position for that file. At the end, the
% positions from each file are averaged together to yield CALIBPOS.

% FILES is a structure containing the string filenames of the audio files
%  used for calibration.
% NWLEN is the window length in seconds.
% EXPECTPOS is the user input expected positions of the microphones
% POSTHRESH is the maxiumum allowed distance from the expectpos that any
%  given mic should be at
% POSNUM is the number of possible positions that should be tested for each
% microphone.

if nargin < 5
   posnum=5;
   if vargin < 4
      posthresh=.01;
      if vargin < 3
         nwlen=10e-3; 
      end
   end
end

expectpos= fovp.mp;
nmics= size( expectpos, 2); % # of mics is equal to # of columns
% change count sizes for more precise calibration
xcnt= 5;
ycnt= 5;

%for each file in FILES
for filename=1:size(files,2)
    %for each microphone
    for mic=1:nmics
       %generate a bunch of possible positions for this mic
       %generate range of xcoords and ycoords
       xcoords= zeros(xcnt,1);
       ycoords= zeros(ycnt,1);
       xcoords(1,1)= expectpos(1,mic);
       ycoords(1,1)= expectpos(2,mic);
       for i=2:xcnt
           xcoords(i,1)= xcoords(i-1,1)+(2*posthresh)/(xcnt-1);
       end
       for i=2:ycnt
           ycoords(i,1)= ycoords(i-1,1)+(2*posthresh)/(ycnt-1);
       end
       
       coords= zeros(size(xcoords,1)*size(ycoords,1),2);
       for xc=1:size(xcoords,1)
           for yc=1:size(ycoords,1)
               coords(i,:) = [xcoords(xc), ycoords(yc)];
           end
       end
    end
    %for each possible combo of positions, compute the power of the
    %calibration image (srp)
    
     
end


end

