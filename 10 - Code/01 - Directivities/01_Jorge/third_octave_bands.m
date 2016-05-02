%% Code to execute
fs          = ;									% Sampling frequency
N_fft       = ;                                 % FFT size (USE A POWER OF TWO FOR CONVENIENCE AND SPEED)
numBands    = 13;                               % Number of 1/3 octave bands
mn          = 125;                              % Center frequency of first 1/3 octave band in Hz.
A           = thirdoct(fs, N_fft, numBands, mn);           % Get 1/3 octave band matrix

% apply 1/3 octave band decomposition
x_hat     	= fft(x, N_fft);			   % apply short-time DFT to clean signal x (assumed a column vector input)
x_hat       = x_hat(1:(N_fft/2+1));        % take single-sided spectrum

X			= sqrt(A*abs(x_hat).^2);     % compute the norm of the 1/3 octave bands (you may want to compute the power, i.e. without the squate root)




%% Function to calculate the 1/3 octave band matrix

function  [A, cf] = thirdoct(fs, N_fft, numBands, mn)
%   [A CF] = THIRDOCT(FS, N_FFT, NUMBANDS, MN) returns 1/3 octave band matrix
%   inputs:
%       FS:         samplerate 
%       N_FFT:      FFT size
%       NUMBANDS:   number of bands
%       MN:         center frequency of first 1/3 octave band
%   outputs:
%       A:          octave band matrix
%       CF:         center frequencies

f               = linspace(0, fs, N_fft+1);
f               = f(1:(N_fft/2+1));
k               = 0:(numBands-1); 
cf              = 2.^(k/3)*mn;
fl              = sqrt((2.^(k/3)*mn).*2.^((k-1)/3)*mn);
fr              = sqrt((2.^(k/3)*mn).*2.^((k+1)/3)*mn);
A               = zeros(numBands, length(f));

for i = 1:(length(cf))
    [~, b]                   = min((f-fl(i)).^2);
    fl(i)                   = f(b);
    fl_ii                   = b;

	[~, b]                   = min((f-fr(i)).^2);
    fr(i)                   = f(b);
    fr_ii                   = b;
    A(i,fl_ii:(fr_ii-1))	= 1;
end

rnk         = sum(A, 2);
numBands  	= find((rnk(2:end)>=rnk(1:(end-1))) & (rnk(2:end)~=0)~=0, 1, 'last' )+1;
A           = A(1:numBands, :);
cf          = cf(1:numBands);

end