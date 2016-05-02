function [delay_error, qual] = real_life_metingen_verwerken(result, delays)
% process real-life results
[del, ind] = max(delays);
added_signal = zeros(del,1);
if ind == 1
    result_processed = [[result(:,1); added_signal] [added_signal; result(:,2)]];
elseif ind == 2
    result_processed = [[added_signal; result(:,1)] [result(:,2); added_signal]];
end

[delay_error, qual] = computeOffsetTD(result_processed(:,1),result_processed(:,2));

function [offset, qual] = computeOffsetTD(input, ref)
%     figure();
    [mlscorr, lag] = xcorr(input,ref);
    mlscorr = mlscorr/(norm(input)*norm(ref));
    [maximum, index] = max(abs(mlscorr));    
    % return the offsets
    offset = lag(index(1));
    qual = maximum/var(mlscorr);
end
end