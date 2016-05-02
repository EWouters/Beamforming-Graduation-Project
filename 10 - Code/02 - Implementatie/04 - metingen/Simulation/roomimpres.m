function [impres] = roomimpres(delay, scale, c, fs)
%  This function computes the impulse response in a room modeled by a
%  direct path
%
%   Inputs
%   delay
%   scale
%   c
%   fs
%
%   Output
%   sigout  The sound recorded by the microphones (one column per
%           microphone, one row per sample)

%%   

%   Calculate the attenuation in air
freq = (fs/2)*[0:200]/200;                                              %   Set the frequencies for the attenuation
Atten = airAtten(freq);                                                 %   Calculate the attenuation in dB

len = 50;                                                               %   FIR filter length minimum limit
nfax = freq/(fs/2);                                                     %   Normalized frequency axis for FIR filter specs

Del = ceil(delay*fs);                                                   %   Find maximum delay in samples (results in longest frequency response)

%% 
freqsp = sum(freq.*10.^(-Atten/20))/sum(10.^(Atten/20));                %   Find filter spectral spread
mxsprd = 1/freqsp;                                                      %   Reciprocal of frequency at spread point (in seconds)

impres = zeros(1,ceil(5*fs*mxsprd+Del));                                %   Set up output array for max delay and 5 time constants of the filter

%%
distance = delay*c;                                                     %   Compute distance traveled by signal
attn = distance*Atten;                                                  %   Compute log slope of spectrum to dB
dt = abs(5*mxsprd);                                                     %   Spread in time domain (5 time constants)
filn = round(dt*fs);                                                    %   Number of filter samples

%%  If time domain spread less than len samples, set equal to len (length of sample spectra).
if filn < len;                                                          %  limit filter order to greater than 50 points (spectral definition)
    filn = len;
elseif filn > fs/2                                                      %  Limit filter order to less than a half second in worse case
    filn = fs/2;
end

%%  if filter order (same as spread) not even, increase by one sample to make order even
if filn/2 ~= fix(filn/2)
    filn=filn+1;
end

%%  
alph = 10.^(-attn/20);                                                  %   attn/10? Compute frequency spectrum for attenuation 
b = fir2(filn,nfax,alph);                                               %   FIR filter to implement attenuation effects with filn+1 coefficients, nfax frequency points, alph the magnitude response
addely = delay-(length(b)-1)/(2*fs);                                    %   Delay to middle of filter coefficient For an order n linear phase FIR filter

%% Calculate the delay by travel time

%  Filter coefficients
if addely < 0
    %  Trim filter to fit the beginning of time sequence
    trm = round(-addely*fs)+1;
    b = b(trm:end);
    addely = 0;
end

dum = scale*delaySig(b,fs,addely);                                      %   Calculate the delay                              

%%  If delay plus filter length exceeds beyond end of accumulation array, extend the accumulation array
if length(dum) > length(impres)
    impres = [impres, zeros(1, length(dum)-length(impres))];
end

%%  
impres(1:length(dum)) = impres(1:length(dum)) + dum;                   %   Assign impulse response to proper delay in accumulation array size(impres(1:length(dum)))

%%  Trim off trailing zeros
greal = find(impres ~= 0);
trmval = max(greal);
impres = impres(1:trmval);
end