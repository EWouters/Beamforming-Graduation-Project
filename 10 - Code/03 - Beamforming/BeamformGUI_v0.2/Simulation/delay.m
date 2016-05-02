function [sd, tn] = delay(b,fs,addely)

%  Find length and dimension of input signal
[r,c] = size(b);

%  Covert to column vectors for processing
if r == 1;
    b = b.';  %  Ensure it is a column vector
    [rn,c] = size(b);
elseif c == 1
    [rn,c] = size(b); % Otherwise rn = r indicating it came in as a column vector
else   %  If multi column and row then process each column as its own signal
    [rn,c] = size(b); % Otherwise input was columnwise matrix
    if length(addely) ~= c
        error('Number of columns in signal matrix must equal number of elements in delay vector')
    end
end

if min(addely) < 0;
    error('Delay cannot be negative')
end
% Compute requested delay in sample points rounded off to nearest sample
nd = ceil(addely*fs);

%  Determine final output length
if nargin == 4
    slen = ceil(ns*fs);
else
    slen = max(nd)+rn;   %  Take max of all delays in vector to determine final signal length
end
sdd = zeros(slen,1);  % Initalize dummy vector for storing integer shift
sd = zeros(slen,c);       % Initialize output matrix

%  Loop through each row of signal matrix and apply delay
for k=1:c
    %  Shift integer sample component of delay
    id = fix(addely(k)*fs)+1;
    sdd(id:min([slen,(rn+id-1)])) = b(1:min([slen-id+1, rn]),k);
    sd(:,k) = sdd(1:slen);
end

%  Restore dimension of signal vector to original orientation
if rn == r     % If input was originally a column or multi-signal matrix we are done
   if nargout == 2      %   Create time axis if requested
     tn = [0:slen-1]'/fs;
   end
else      % If input was originally a row vector, take transpose
   sd = (sd.');
   if nargout == 2      %   Create time axis if requested
     tn = [0:slen-1]/fs;
   end
end