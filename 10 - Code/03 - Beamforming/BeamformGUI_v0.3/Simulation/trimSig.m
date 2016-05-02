function [sig] = trimSig(audio, fs, tTrim)
%   This function trims the signal down to the interval tTrim
%
%   Inputs
%   audio   Matrix with the (to be recorded) seperate audio (source) files
%   tTrim   The interval to trim the audio down to
%
%   Output
%   sig     The trimmed audio(one column per source, one row per sample)


%%   Determine the length of the longest audio signal
[~, numFiles] = size(audio);    %   Number of source files in audio

%   Determine the length of each signal
for ii = 1 : numFiles
    sigLen(ii) = length(audio{ii});
end

maxSigLen = max(sigLen);        %   Length of the longest signal

%%   Make all the signals the same size by adding zeros
for ii=1:length(audio)
    if sigLen(ii) == maxSigLen
        sig(:,ii) = audio{ii};
    elseif sigLen(ii) < maxSigLen
        sig(:,ii) = [audio{ii}; zeros(maxSigLen-sigLen(ii),1)];
    else
        error(['You can''t have a longer signal than the longest', ...
            'signal...']);
    end
end


%%  Trim each input signal down to [tTrim(1) tTrim(2)] seconds

%   Test if the input is usable
if (tTrim(1)) > (tTrim(2))
    error('2nd column in tInt must be greater than the 1st column');
elseif (tTrim(1) < 0) | (tTrim(2) < 0)
    error('tInt cannot contain negative values');
end

%   Set begin and end index
begin_index = fs*tTrim(1)+1;
end_index = fs*tTrim(2);

%   Warning if begin_index is greater than signal length
if begin_index > length(sig)
    warning('Signal ends before trimming down starts');
end

%   Zero pad if end_index is greater than the signal length
if end_index > length(sig)
    sig = [sig; zeros(end_index-length(sig),length(fnames))];
end

%   Trim the signal to the desired length
sig = sig(begin_index:end_index,:);
end