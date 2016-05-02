function sigout = simRec2(sources, louds_pos, mics_pos, fs, sound_vel, sim_time)
    
    room_dim = [6.85 3.95 3.2];                     % Room dimensions [x y z] in m
    alphas = [0.54 -0.56 0.58 -0.53 -0.55 0.57];    % Reflection coefficients [x1 x2 y1 y2 z1 z2]
    L_b = 2048;                                     % Positive half of fft spectrum, block length
    reverb = false;                                 % Reverberations on/off
    dims = reverb.*ones(1,3);                       % Reverberations
    hsiz = 0.064;                                   % Hanning window length in sec
    
    h = rir_generator_x(sound_vel, fs, mics_pos, louds_pos, room_dim, ...
                        alphas, L_b, 'o', -1, dims, 0, false, true, hsiz);
    
                    
    sim_l = floor(fs*sim_time);                     % Simulation length in samples             
    [Nmics,~] = size(mics_pos);                     % Number of mics
    
    
    source_reb = fftfilt(h(:,:,1),sources(:,1));    % Applying the room impulse to the source
    
    
    interf_reb = zeros(sim_l,Nmics);                % Initialize
	[~,SourceSiz] = size(sources); 
    Ninterf = SourceSiz - 1;
    % Applying the room impulse to the interfering sound
    for nint = 1:Ninterf;
        interf_reb=interf_reb+fftfilt(h(:,:,nint+1),sources(:,nint+1));
    end
    
    SNR  = 60;                                      %iid noise SNR in dB.
    
    addnoise=randn(sim_l,Nmics);
	addnoise=addnoise./repmat(max(abs(addnoise)),[sim_l 1])./10^(SNR./20);

	sigout = source_reb + interf_reb + addnoise;
end
