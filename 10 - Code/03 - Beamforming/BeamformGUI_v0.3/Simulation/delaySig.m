function sd = delaySig(b,fs,addely)
%  This function delays signal b met addely seconds
%
%   Inputs
%   b       Filter for attenuation effect
%   fs      Sampling frequency
%   addely  Number of seconds to delay the signal
%   
%   Output
%   sd      Delayed signal

%%  Covert to column vectors for processing
[r,c] = size(b);

%   Covert to column vectors for processing
if r == 1;
    b = b.';                                                        %  Ensure it is a column vector
    [rn,c] = size(b);
elseif c == 1
    [rn,c] = size(b);                                               % Otherwise rn = r indicating it came in as a column vector
else                                                                %  If multi column and row then process each column as its own signal
    [rn,c] = size(b);                                               % Otherwise input was columnwise matrix
    if length(addely) ~= c
        error('Number of columns in signal matrix must equal number of elements in delay vector')
    end
end

%%
%   Error for negative delay
if min(addely) < 0;
    error('Delay cannot be negative')
end

nd = ceil(addely*fs);                                               % Compute requested delay in sample points rounded off to nearest sample

slen = max(nd)+rn;                                                  %   Take max of all delays in vector to determine final signal length
sdd = zeros(slen,1);                                                %   Initalize dummy vector for storing integer shift
sd = zeros(slen,c);                                                 %   Initialize output matrix

%%  Apply the delay
for k=1:c
    %  Shift integer sample component of delay
    id = fix(addely(k)*fs)+1;
    sdd(id:min([slen,(rn+id-1)])) = b(1:min([slen-id+1, rn]),k);
    sd(:,k) = sdd(1:slen);
end

%%  Restore dimension of signal vector to original orientation

%   If input was originally a row vector, take transpose
if rn ~= r                                                         
   sd = (sd.');
end