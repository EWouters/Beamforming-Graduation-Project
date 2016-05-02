function [sig,fs] = signals(filenames, tTrim)

[numFiles, ~] = size(filenames);
               %   Read the data y and sampling frequency fs
for ii = 1 : numFiles
    [y{ii}, fs(ii)]= audioread(filenames{ii});  %   Save y and Fs for each audio file
    
%     % If one of the audio files has more than 1 channel, uncomment this
%     to only keep the first.

%     [nR,nChanOrig] = size(y{ii});
%     if nChanOrig ~= 1
%         y{ii} = y{ii}(:,1);
%     end
    sigLen(ii) = length(y{ii});
end  

%   Make all the signals the same size by adding zeros
maxSigLen = max(sigLen);
for ii=1:length(filenames)
    if sigLen(ii) == maxSigLen
        sig(:,ii) = y{ii};
    elseif sigLen(ii) < maxSigLen
        sig(:,ii) = [y{ii}; zeros(maxSigLen-sigLen(ii),1)];
    else
        error(['You can''t have a longer signal than the longest', ...
            'signal...']);
    end
end


%%  Take [tTrim(1) tTrim(2)] seconds of each input signal
%   Test if the input is usable
if exist('tTrim', 'var')
    if (tTrim(1)) > (tTrim(2))
        error('2nd column in tInt must be greater than the 1st column');
    elseif (tTrim(1) < 0) | (tTrim < 0)
        error('tInt cannot contain negative values');
    end
    
    begin_index = fs*tTrim(1)+1;
    end_index = fs*tTrim(2);
    
    % Warning if begin_index is greater than signal length
    if begin_index > length(sig)
        warning('Signal ends before trimming down starts');
    end
    
    % zero pad if end_index is greater than the signal length
    if end_index > length(sig)
        sig = [sig; zeros(end_index-length(sig),length(fnames))];
    end
    
    sig = sig(begin_index:end_index,:);
end

end