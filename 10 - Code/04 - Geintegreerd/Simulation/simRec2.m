function sigout = simRec2(sources, louds_pos, mics_pos, fs, sound_vel, room_dim, offset, alphas, reverb, SNR, poserr, plotflag)
    
%   offset = [3.07 1.01 0.73];                          % Offset of the room [x y z] in m

    % Initialize parameters
%     alphas = [0.54 -0.56 0.58 -0.53 -0.55 0.57];        % Reflection coefficients [x1 x2 y1 y2 z1 z2]
%     reverb = true;                                      % Reverberations on/off
%     SNR  = 60;                                          % iid noise SNR in dB.
    L_b = 2048;                                         % Positive half of fft spectrum, block length
    dims = reverb.*ones(1,3);                           % Reverberations
    hsiz = 0.064;                                       % Hanning window length in sec
    
    [Nmics,~] = size(mics_pos);                         % Number of mics
    [Nlouds,~] = size(louds_pos);                       % Number of loudspeakers
     
    
    % Random position offset
    
    
%   Apply the offset to the positions
    mics_pos = mics_pos + repmat(offset,[Nmics,1]);
    louds_pos = louds_pos + repmat(offset,[Nlouds,1]);      
    
    h = rir_generator_x(sound_vel, fs, mics_pos, louds_pos, room_dim, ...
                        alphas, L_b, 'o', -1, dims, 0, false, true, hsiz);
    
    % plotflag - flag, enable to plot impulse response
    if plotflag
        tax = (0:L_b-1)./fs;
        figure;
        title('Room impulse response')
        subplot(2,1,1);
        plot(tax,h(:,1,1),'b');
        grid on;
        axis tight;
        subplot(2,1,2);
        plot(tax,20.*log10(abs(h(:,1,1)./max(abs(h(:,1,1))))),'b');
        grid on;
        axis tight;
    end
                   
    sim_l = size(sources,1);                            % Simulation length in samples             
        
    source_reb = fftfilt(h(:,:,1),sources(:,1));        % Applying the room impulse to the source
	
    [~,SourceSiz] = size(sources); 
    Ninterf = SourceSiz - 1;                            % Number of interfering sources
    
    interf_reb = zeros(sim_l,Nmics);                    % Initialize
    
    % Applying the room impulse to the interfering sound
    for nint = 1:Ninterf;
        interf_reb=interf_reb+fftfilt(h(:,:,nint+1),sources(:,nint+1));
    end
    
    addnoise=randn(sim_l,Nmics);                        % Create noise to add to the signal
    
	addnoise=addnoise./repmat(max(abs(addnoise)),[sim_l 1])./10^(SNR./20); % Normalize and apply the SNR

	sigout = source_reb + interf_reb + addnoise;
end