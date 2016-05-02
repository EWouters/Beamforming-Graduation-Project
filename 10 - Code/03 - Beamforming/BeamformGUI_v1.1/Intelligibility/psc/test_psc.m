%__________________________________________________________________________________________________________________________
% Test framework for phase spectrum compensation (PSC) method for speech enhancement by Kamil Wojcicki, 2011 (test_psc.m)
clear all; close all; % clc;

    SNR = @(x,y) (10*log10((sum(x.^2)))/(sum((x(:)-y(:)).^2))); % in-line function for SNR computation 

    file.clean = 'sp10.wav'; % specify the input file
    file.noisy = 'sp10_white_sn10.wav'; % specify the input file
    [speech.clean, fs, nbits] = wavread(file.clean); % read audio samples from the input file
    [speech.noisy, fs, nbits] = wavread(file.noisy); % read audio samples from the input file
    time = [0:length(speech.noisy)-1]/fs; % create time vector

    Tw = 32; % analysis frame duration (ms) 
    Ts = Tw/8; % analysis frame shift (ms)
    lambda = 3.74; % scale of compensation 

    % enhance noisy speech using the PSC method
    [speech.psc_A] = psc(speech.noisy, fs, Tw, Ts, 'G&L', lambda-3); 
    [speech.psc_B] = psc(speech.noisy, fs, Tw, Ts, 'G&L', lambda); 
    [speech.psc_C] = psc(speech.noisy, fs, Tw, Ts, 'G&L', lambda+3); 

    methods = fieldnames(speech); % treatment names
    M = length(methods); % number of treatments

    %system(sprintf('rm -f ./%s.txt', mfilename));
    diary(sprintf('%s.txt', mfilename)); diary on;
    fprintf('\n%12s     %4s  %4s\n', 'Method', 'PESQ', 'SNR');
    for m = 1:M % loop through treatment types and compute SNR scores
        method = methods{m};
        mos.(method) = pesq(speech.clean, speech.(method), fs);
        snr.(method) = SNR(speech.clean, speech.(method));
        fprintf('%12s :   %4.2f  %4.2f\n', method, mos.(method), snr.(method));
    end
    diary off;

    figure('Position', [20 20 800 210*M], 'PaperPositionMode', 'auto', 'Visible', 'on');
    for m = 1:M % loop through treatment types and plot spectrograms
        method = methods{m};

        subplot(M,2,2*m-1); % time domain plots
        plot(time,speech.(method),'k-'); 
        xlim([min(time) max(time)]);
        title(sprintf('Waveform: %s,  PESQ=%0.2f,  SNR=%0.2f dB', method, mos.(method), snr.(method)), 'interpreter', 'none');
        xlabel('Time (s)');
        ylabel('Amplitude');

        subplot(M,2,2*m); % spectrogram plots
        myspectrogram(speech.(method), fs);
        set(gca,'ytick',[0:1000:16000],'yticklabel',[0:16]);
        title(sprintf('Spectrogram: %s,  PESQ=%0.2f,  SNR=%0.2f dB', method, mos.(method), snr.(method)), 'interpreter', 'none');
        xlabel('Time (s)');
        ylabel('Frequency (kHz)');
    end
    print('-depsc2', '-r250', sprintf('%s.eps', mfilename));
    print('-dpng', sprintf('%s.png', mfilename));

    for m = 1:M % loop through treatment types and write audio to wav files
        method = methods{m};
        audio.(method) = 0.999*speech.(method)./max(abs(speech.(method)));
        wavwrite(audio.(method), fs, nbits, sprintf('%s.wav',method));
    end

%__________________________________________________________________________________________________________________________
% EOF
