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