function [sigout, tax] = simtone(f1,widthe,td,fs,windtype,siglen)
% This function creates a windowed tonal signal associated with 
% a delay and bandwidth. The Envelope can be either a Square, Rayleigh,
% hanning, or triangular, the default is square.  The output includes
% the signal SIGOUT  and its corresponding time axis "tax."  The width of
% the window should be at least one period of the center frequency
% 
%  [sigout, tax] = simtone(f1,widthe,td,fs,windtype,siglen)
%
% The input arguments are:
% f1  =>     Frequency of tone
% widthe =>  Envelope width (3dB points)
% td =>   time delay in seconds with reference to the first point in 
%         output signal array.
% fs =>   Signal sampling frequency
% windtype => optional parameter, the shape of the window that modulates
%             tone is described by this string.  The choices are:
%             windtype = 'Square' - square window.
%                        'Rayleigh' - Rayleigh distribution function
%                        'Hanning' - Hanning window
%                        'Triangle' - Triangular window
% siglen => optional input, it is the length of output signal in seconds
%           it should be at least 2 times the width of the envelope plus
%            the delay, maybe more in the case of the Rayleigh pulse since it
%            does not have a finite duration.  The default
%            is td+4*width.
%   Written by Kevin D. Donohue (donohue@engr.uky.edu) July 2005


%  Check on input parameters
if nargin == 4   %  If type not given, set to default
    windtype = 'Square';
    siglen = td+4*widthe;
elseif nargin == 5  %  If width not given set to default
    siglen =  td+4*widthe;
end

tonlen = siglen-td;
t = [0:round(tonlen*fs)]'/fs;   %  Create time axis over tone duration
% Create signals
if windtype(1) == 'H' | windtype(1) == 'h'  %  If hanning
    win = zeros(round(fs*tonlen)+1,1);      %  initialize signal array
    wlen = round(fs*widthe/.3644)+1;        %  Find length of non-zero signal to put 3 dB point widthe appart
    win(1:wlen) = hanning(wlen);            %  Compute envelope
    win = win.*sin(2*pi*f1*t);              %  modulate with sine wave

elseif windtype(1) == 'T' | windtype(1) == 't'  % If triangluar 
    win = zeros(round(fs*tonlen)+1,1);          % initialize signal array
    wlen = round(fs*widthe/.2937)+1;            %  Find length of non-zero signal  to put 3 dB point widthe appart
    win(1:wlen) = triang(wlen);                 %  Compute envelope
    win = win.*sin(2*pi*f1*t);                  %  Modulate with sine wave
    
elseif windtype(1) == 'R' | windtype(1) == 'r'      % If Rayleigh
    sigma = widthe;                                 % set variance to signal width
    win = t.*exp(-(1/2)*(t.^2)/(sigma^2))/sigma^2;  % compute envelope
    win = win.*sin(2*pi*f1*t);                      % Modulate with sine wave

else                                              %  if nothing else, use square
    win = zeros(round(fs*tonlen)+1,1);            % initialize signal array
    win(1:round(fs*widthe)+1) = ones(round(fs*widthe)+1,1);  % set square duration points to 1
    win = win.*sin(2*pi*f1*t);
end
%  Initialize output signal
sigout = zeros(round(fs*siglen)+1,1);
%  Roundoff delay to nearest integer point
tdn = round(fs*td)+1;
%  Assign tone with leading zeros to correspond to the delay
sigout(tdn:round(fs*siglen)+1,1)=win;
%  Assign time axis
tax = [0:round(siglen*fs)]/fs;