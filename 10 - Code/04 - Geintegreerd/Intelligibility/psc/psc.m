%__________________________________________________________________________________________________________________________________
% Phase Spectrum Compensation (PSC) [1] by Stark et al. Implementation by Kamil Wojcicki, 2011 (psc.m)
%
% [1] A.P. Stark, K.K. Wojcicki, J.G. Lyons and K.K. Paliwal, 
%     "Noise driven short time phase spectrum compensation procedure for speech enhancement", 
%     Proc. INTERSPEECH 2008, Brisbane, Australia, pp. 549-552, Sep. 2008.
%
% [2] K.K. Wojcicki, M. Milacic, A. Stark, J.G. Lyons and K.K. Paliwal, 
%     "Exploiting conjugate symmetry of the short-time Fourier spectrum for speech enhancement", 
%     IEEE Signal Processing Letters, Vol. 15, pp. 461-464, 2008.
%
% @inputs       s       - time domain noisy speech signal samples as a vector
%               fs      - sampling frequency (Hz)
%               Tw      - frame duration (ms)
%               Ts      - frame shift (ms)
%               stype   - overlap add synthesis type ('Allen & Rabiner', 'Griffin & Lim', 'Vanilla')
%               lambda  - strength of phase spectrum compensation (see [1])
% 
% @output       y       - PSC enhanced speech signal
%
% @usage        y = psc( s, fs, Tw, Ts, stype, lambda )
%
% @example      noisy = wavread( 'sp10_white_sn10.wav' );
%               enhanced = psc( noisy, fs, 32, 32/4, 'Griffin & Lim', 3.74 );
%__________________________________________________________________________________________________________________________________
function [ y ] = psc( s, fs, Tw, Ts, stype, lambda )


    %______________________________________________________________________________________________________________________________
    if(nargin<6), error(sprintf('Not enough input arguments. Type "help %s" for usage help.', mfilename)); end;

    %______________________________________________________________________________________________________________________________
    s = s(:).'-mean(s);                              % make sure input signal is in row form and zero-mean
    Nw = round(fs*Tw*0.001);                         % frame duration (in samples)
    Ns = round(fs*Ts*0.001);                         % frame shift (in samples)
    nfft = 2^nextpow2(2*Nw);                         % FFT analysis length

    winfunc = @(L,S)(sqrt(2*S/(L*(2*0.5^2+(-0.5)^2)))*(0.5-0.5*cos((2*pi*((0:L-1)+0.5))/L)));
    w = winfunc(Nw, Ns);                             % Griffin & Lim's modified Hanning window 

    %______________________________________________________________________________________________________________________________
    Tn = 120;                                        % initial noise estimate: time (ms)
    M = floor(Tn*0.001*fs/Nw);                       % initial noise estimate: # of frames
    indf = Nw*[0:(M-1)].';                           % frame indices
    inds = [1:Nw];                                   % sample indices in each frame
    refs = indf(:,ones(1,Nw)) + inds(ones(M,1),:);   % absolute sample indices for each frame
    frames = s(refs) * diag(w);                      % split into non-overlapped frames using indexing (frames as rows)
    S = fft(frames, nfft, 2);                        % perform short-time Fourier transform (STFT) analysis
    N = sqrt(mean(abs(S).^2));                       % estimate noise magnitude spectrum
    %N = filter( ones(1,20)/20,1,N ); N(2:nfft/2) = N(end:-1:nfft/2+2); % apply smooting?

    %______________________________________________________________________________________________________________________________
    D = mod(length(s), Ns);                          % we will add Nw-D zeros to the end
    G = (ceil(Nw/Ns)-1)*Ns;                          % we will add G zeros to the beginning
    s = [zeros(1,G) s zeros(1,Nw-D)];                % zero pad signal to allow an integer number of segments
    L = length(s);                                   % length of the signal for processing (after padding)
    M = ((L-Nw)/Ns)+1;                               % number of overlapped segments
    indf = Ns*[0:(M-1)].';                           % frame indices
    inds = [1:Nw];                                   % sample indices in each frame
    refs = indf(:,ones(1,Nw)) + inds(ones(M,1),:);   % absolute sample indices for each frame
    frames = s(refs) * diag(w);                      % split into overlapped frames using indexing (frames as rows), apply analysis window
    S = fft(frames, nfft, 2);                        % perform short-time Fourier transform (STFT) analysis

    % TODO: incorporate a noise estimation algorithm ...
    A = [0, repmat(lambda,1,nfft/2-1), 0, repmat(-lambda,1,nfft/2-1)].*N; % phase spectrum compensation function
    MSTFS = abs(S).*exp(j*angle(S+repmat(A,M,1)));   % compensated STFT spectra


    %______________________________________________________________________________________________________________________________
    x = real(ifft(MSTFS, nfft, 2));                  % perform inverse STFT analysis
    x = x(:, 1:Nw);                                  % discard FFT padding from frames

    switch(upper(stype))
    case {'ALLEN & RABINER','A&R'}                   % Allen & Rabiner's method

        y = zeros(1, L); for i = 1:M, y(refs(i,:)) = y(refs(i,:)) + x(i,:); end; % overlap-add processed frames
        wsum = zeros(1, L); for i = 1:M, wsum(refs(i,:)) = wsum(refs(i,:)) + w; end; % overlap-add window samples
        y = y./wsum;                                 % divide out summed-up analysis windows

    case {'GRIFFIN & LIM','G&L'}                     % Griffin & Lim's method

        x = x .* w(ones(M,1),:);                     % apply synthesis window (Griffin & Lim's method)
        y = zeros(1, L); for i = 1:M, y(refs(i,:)) = y(refs(i,:)) + x(i,:); end; % overlap-add processed frames
        wsum2 = zeros(1, L); for i = 1:M, wsum2(refs(i,:)) = wsum2(refs(i,:)) + w.^2; end; % overlap-add squared window samples
        y = y./wsum2;                                % divide out squared and summed-up analysis windows

    case {'VANILLA'}
        y = zeros(1, L); for i = 1:M, y(refs(i,:)) = y(refs(i,:)) + x(i,:); end; % overlap-add processed frames

    otherwise, error(sprintf('%s: synthesis type not supported.', stype));
    end

    y = y(G+1:L-(Nw-D));                             % remove the padding


%__________________________________________________________________________________________________________________________________
% EOF 

