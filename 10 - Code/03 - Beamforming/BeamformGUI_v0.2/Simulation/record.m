function [sigout, tax] = record(airAtten, micPos, sigPos, sig, fs, c)                                    %sig, sigPos, micPos, 

%%  variables


% Obtain mic array information
[mr, mc] = size(micPos);      % Determine number of mics = mc
[pgr, pgc] = size(sigPos);  % Determine number of sound sources = pgc
[sgr, sgc] = size(sig); % Determine number of signals for each source = sgc

%  Check for consistency of input information
if sgc ~= pgc
    error('Each signal source must have a position - columns of SIGPOS = columns of SIGARRAY')
end
if mr ~= pgr
    error('ErrorTests:convertTest',['The mic and signal coordinates must be in same dimension:\n rows of SIGPOS = rows MPOS'])
end

%  Find largest delay to initialize ouput array with appropiate size
dmax = 0;
for k=1:pgc  %  Every signal position
    for r=1:mc  %  with every mic position
        d = norm((sigPos(:,k)-micPos(:,r)),2);
        if d > dmax
                 dmax = d;
        end
    end
end

%  Compute output array length based on the greatest delay
outLen = ceil(dmax*fs/c) + sgr;         %   max output length, sgr is the number of samples from sig

tax = (0:outLen-1)/fs;                  %   Create corresponding time axis ; -1 because it starts at 0 instead of 1
sigout = zeros(outLen,mc);              %   Initialize output array

%  Compute a number of frequency domain coefficients to describe the 
%  attenuation spectrum
len = round(fs/40);     %   One point per 40 Hz
nfax = (0:len)/len;     %   Normalize
fax = (fs/2)*nfax;      %   Create frequency axis for the attenuation

%  Loop for each source
for k = 1:pgc
    % For each mic direct path delay and attenuation from each sound source to mic    
    for  r = 1:mc                                   
        md = norm((sigPos(:,k) - micPos(:,r)),2);       %   Compute distance between mic and source
        delay = md/c;                                   %   delay in sec
        scale = 1 /(4*pi);                              %   No scattering loss for direct path 
        
        impres = roomimpres(delay, scale, c, fs, airAtten);  %  Room impulse response
        
        dum = conv(sig(:,k),impres');  %  Filter input signal with response
         
        %   Check to ensure output matrix is large enough to accumulate the new
        %   filtered and delayed mic signal
        [orw,ocl] = size(sigout);     %  Current size of output array
        slen = length(dum);           %   length of current source to mic signal
        %  If source to mic signal is bigger than output array, extend it
        %   with zero padding
        if slen > orw
            sigout = [sigout; zeros(slen-orw,ocl)];
        end
            sigout(1:slen,r) = sigout(1:slen,r)+dum;  %  Accumulate source to mic signal in output array   
    end 
end

end