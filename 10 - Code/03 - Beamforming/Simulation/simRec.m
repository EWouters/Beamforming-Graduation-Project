function sigout = simRec(sig, sigPos, micPos, fs, c)                                    
%   This function simulates recording the source signals with different
%   microphones.
%   
%   Inputs
%   sig     The source signals (one column per source, one row per sample)
%   sigPos  The positions of the signals in x,y,z components
%   micPos  The positions of the microphones in x,y,z components
%   fs      The sampling frequency in Herz
%   c       The speed of sound in m/s
%
%   Output
%   sigout  The sound recorded by the microphones (one column per
%           microphone, one row per sample)


%%   Obtain mic array information
[mr, mc] = size(micPos);    %   mr:  Number of dimensions,       mc:  Number of mics    
[pgr, pgc] = size(sigPos);  %   pgr: Number of dimensions pgr,   pgc: Number of sources 
[sgr, sgc] = size(sig);     %   sgr: Number of samples,          sgc: Number of sources 

%%   Check for consistency of input information
if sgc ~= pgc
    error('Each signal source must have a position - columns of SIGPOS = columns of SIGARRAY')
end
if mr ~= pgr
    error('ErrorTests:convertTest',['The mic and signal coordinates must be in same dimension:\n rows of SIGPOS = rows MPOS'])
end

%%  Find largest delay in distance to initialize ouput array with appropiate size
dmax = 0;
%  For every signal position
for k=1:pgc
    %  For every mic position
    for r=1:mc  
        d = norm((sigPos(:,k)-micPos(:,r)),2);
        if d > dmax
            dmax = d;
        end
    end
end

%%
%  Initialize output array based on the greatest delay
outLen = ceil(dmax*fs/c) + sgr;                             %   max output length based on the delay and the number of samples of the input
sigout = zeros(outLen,mc);                                  %   Initialize output array

%  Compute a number of frequency domain coefficients to describe the attenuation spectrum
len = round(fs/40);                                         %   One point per 40 Hz
nfax = (0:len)/len;                                         %   Normalize

%%  Simulate the microphones recording the signals

%  For each source
for k = 1:pgc
    % For each mic direct path delay and attenuation from each sound source to mic    
    for  r = 1:mc                                   
        md = norm((sigPos(:,k) - micPos(:,r)),2);           %   Compute distance between mic and source
        delay = md/c;                                       %   Delay in sec
        scale = 1/(1+md);                                   %   Scale factor for the direct path
        
        impres = roomimpres(delay, scale, c, fs);           %  Calculate room impulse response
        
        dum = conv(sig(:,k),impres');                       %  Convolution between the impulse response and the source
         
        %   Check to ensure output matrix is large enough to accumulate the new filtered and delayed mic signal
        [orw,ocl] = size(sigout);                           %   Current size of output array
        slen = length(dum);                                 %   length of current source to mic signal
        
        %   If source to mic signal is bigger than output array, extend it with zero padding
        if slen > orw
            sigout = [sigout; zeros(slen-orw,ocl)];
        end
            sigout(1:slen,r) = sigout(1:slen,r)+dum;        %   Accumulate source to mic signal in output array   
    end 
end
end