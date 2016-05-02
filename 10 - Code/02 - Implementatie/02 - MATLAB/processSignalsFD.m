function [offsets] = processSignalsFD(pulse, samples)
    % pulse must be a vector
    % samples must be a 2xn cell array

    % input sanitation
    switch (nargin)
        case 2
            if ~isvector(pulse)
                error('Pulse must be a vector');
            end
            if ~iscolumn(pulse)
                pulse=pulse';
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

    % actual synchronization algo
    function [offsetFD] = computeOffsetFD(input, ref)
        if ~iscolumn(input)
            input=input';
        end
        if ~iscolumn(ref)
            ref=ref';
        end
        L=2^(nextpow2(length(input)+length(ref)-1)+3);
%         L=length(input)+length(ref)-1;
        % zero pad to same length L using second argument of fft();
        %hwindow=fft(hamming(1000),L);
        inputFD=fft(input,L);
        refFD=fft(ref,L);
        corrFD = refFD.*conj(inputFD);
        corrFD = corrFD(1:(L/2+1));
        corrected_phase = unwrap(angle(corrFD));
        xvals = 1:round(length(corrected_phase)*3/4);
        %         calculate the slope
        dataFit = polyfit(xvals',corrected_phase(1:length(xvals)),1);
        % dataFit(1) is the slope. Convert slope to offset in samples
        offsetFD = dataFit(1)*L/(2*pi);
    end

    for i=1:numberOfPhones
        o = computeOffsetFD(samples{2,i},pulse);    
        % return the offsets
        offsets(i) = o;
    end
end
