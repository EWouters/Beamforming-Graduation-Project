function [offsets, offsets_self] = processSignalsTD(pulse, samples)
% pulse must be a vector
% samples must be a 2xn cell array

% input sanitation
switch (nargin)
    case 2
        if ~isvector(pulse)
            error('Pulse must be a vector');
        end
        if size(samples,1)~=2
            error('Size of samples in first dimension is not 2');
        end
    otherwise
        error('Number of input args invalid');
end
numberOfPhones = size(samples,2);

% init offsets
offsets = zeros(1,numberOfPhones);
offsets_self = zeros(1,numberOfPhones-1);
% init quality measurement vector
qual_xcorr = zeros(numberOfPhones,1);
qual_acorr = zeros(numberOfPhones-1,1);

% actual synchronization algo
    function [offset, qual] = computeOffsetTD(input, ref)
%     figure();
    [mlscorr, lag] = xcorr(input,ref);
    mlscorr = mlscorr/(norm(input)*norm(ref));
    [maximum, index] = max(abs(mlscorr));
%     subplot(numberOfPhones,1,i);
%     hold on;
%     plot(lag, mlscorr);
%     plot(lag(index(1)),maximum,'r+');
    
    % return the offsets
    offset = lag(index(1));
    qual = maximum/var(mlscorr);
    end

for i=1:numberOfPhones
    [o,q] = computeOffsetTD(samples{2,i},pulse);    
    % return the offsets
    offsets(i) = o;
    qual_xcorr(i) = q;
end

% figure();
for i=2:numberOfPhones
    [o,q] = computeOffsetTD(samples{2,i},samples{2,1});    
    % return the offsets
    offsets_self(i-1) = o;
    qual_acorr(i) = q;
end
% [qual_xcorr qual_acorr]
end
