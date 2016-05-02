% simulate_synchronization.m: run a Monte Carlo simulation on the
% synchronization algorithm.
%
% The simulation consists of several parts. First, a pulse signal is
% generated for correlation processing. This signal is passed through
% a simulated microphone (characterised by a room impulse response),
% delayed, and contaminated with AWGN. Then, processSignals is called to
% attempt to recover the time offset. The estimate is compared to the
% actual delay used.
clear all; close all;

% CONSTANTS
FS = 48e3;     % sample rate       [Hz]

% SIMULATION PARAMETERS
RUNS_PER_PARAM   = 100;
NOISE_SIGMAS     = logspace(-2.5,1.7,30);        % standard deviations of the noise          [sample value]
DELAYS           = linspace(0,0.2,5);            % delay values to use
DELAY_RESOLUTION = 1;                             % fractional digits available for resampling, i.e. 1 yields 0.1 sample delay resolution.
RIR_ORDER        = 12;
ABSORPTIONS      = linspace(0, 1, 10);           % room impulse response absorption coefficients
MIC_GAIN         = 1;

SRC_POS   = [1 0 0];
MIC_POS   = [0 0 0];
ROOM_SIZE = [5 6 2.5];

TOTAL_RUNS  = RUNS_PER_PARAM * length(NOISE_SIGMAS) * length(DELAYS) * length(ABSORPTIONS);

tic();

% generate the synchronization pulse to 'play back'
pulse = generatePulse()';

fprintf('Generating delayed source signals...\n');
% generate delayed source signals
delayed_signals = cell(length(DELAYS),length(ABSORPTIONS));

for absorb_index = 1:length(ABSORPTIONS)
    response   = rir(FS, MIC_POS, RIR_ORDER, ABSORPTIONS(absorb_index), ROOM_SIZE, SRC_POS);
    
    start_index = round(FS*norm(MIC_POS - SRC_POS)/343);  % remove delay due to TOF
    response    = response(start_index:end);
    pulse_conv  = conv(pulse, response) * MIC_GAIN;

    % To generate a fractional delay, we interpolate the pulse by some factor,
    % delay it then decimate the delayed pulse.
    interpolated_signal = interp(pulse_conv, 10^DELAY_RESOLUTION);

    for delay_index = 1:length(DELAYS)
        delay = DELAYS(delay_index);

        % add zeros
        sample_delay     = round(FS*delay*10^DELAY_RESOLUTION);
        delayed_signal   = [ zeros(sample_delay, 1); interpolated_signal ] ;

        % decimate
        delayed_signals{delay_index, absorb_index} = decimate(delayed_signal,10^DELAY_RESOLUTION);
    end;
end;

fprintf('Doing %6d runs total\n', TOTAL_RUNS);

res_errors_TD = zeros(TOTAL_RUNS,1);
res_errors_FD = zeros(TOTAL_RUNS,1);
i = 1;
for absorb_index = 1:length(ABSORPTIONS)
    for delay_index = 1:length(DELAYS)
        fprintf('%4.2fs: Run %6d\n', toc(), i);
        delay = DELAYS(delay_index);
        delayed_signal = delayed_signals{delay_index, absorb_index};
        for sigma_index = 1:length(NOISE_SIGMAS)
            noise_sigma = NOISE_SIGMAS(sigma_index);
            
            parfor run = i:(i+RUNS_PER_PARAM-1)
                % add noise realisation
                mic_signal       = delayed_signal + normrnd(0, noise_sigma, size(delayed_signal));

                % put into expected input format
                mic_signals = { 'simulation input'; mic_signal };

                offsetsTD = processSignalsTD(pulse, mic_signals);
                res_errors_TD(run) = offsetsTD(1) - delay*FS;

                offsetsFD = processSignalsFD(pulse, mic_signals);
                res_errors_FD(run) = offsetsFD(1) - delay*FS;

                %fprintf('echt %8.3f, berekend %8.3f, error %8.3f\n', delay*FS, offsetsTD(1), offsetsTD(1) - delay*FS);
            end
            i = i + RUNS_PER_PARAM;
        end
    end
end

save('results.mat');
fprintf('All done.\n');

% process results
SIGMA_IDX  = 1;
DELAY_IDX  = floor(length(DELAYS)/2);
ABSORB_IDX = 1;

run_idx = @(sig_i, del_i, ab_i) 1 + (ab_i-1)*length(NOISE_SIGMAS)*length(DELAYS)*RUNS_PER_PARAM + (del_i-1)*length(NOISE_SIGMAS)*RUNS_PER_PARAM + (sig_i-1)*RUNS_PER_PARAM;
TD_run  = @(sig_i, del_i, ab_i) res_errors_TD(run_idx(sig_i, del_i, ab_i):run_idx(sig_i, del_i, ab_i)+RUNS_PER_PARAM-1);
FD_run  = @(sig_i, del_i, ab_i) res_errors_FD(run_idx(sig_i, del_i, ab_i):run_idx(sig_i, del_i, ab_i)+RUNS_PER_PARAM-1);

rms_per_sigma_TD  = zeros(length(NOISE_SIGMAS), 1);
rms_per_delay_TD  = zeros(length(DELAYS),       1);
rms_per_absorb_TD = zeros(length(ABSORPTIONS),  1);

rms_per_sigma_FD  = zeros(length(NOISE_SIGMAS), 1);
rms_per_delay_FD  = zeros(length(DELAYS),       1);
rms_per_absorb_FD = zeros(length(ABSORPTIONS),  1);

for sigma_index = 1:length(NOISE_SIGMAS)
    rms_per_sigma_FD(sigma_index) = rms(FD_run(sigma_index, DELAY_IDX, ABSORB_IDX));
    rms_per_sigma_TD(sigma_index) = rms(TD_run(sigma_index, DELAY_IDX, ABSORB_IDX));
end

for absorb_index = 1:length(ABSORPTIONS)
    rms_per_absorb_FD(absorb_index) = rms(FD_run(SIGMA_IDX, DELAY_IDX, absorb_index));
    rms_per_absorb_TD(absorb_index) = rms(TD_run(SIGMA_IDX, DELAY_IDX, absorb_index));
end

for delay_index = 1:length(DELAYS)
    rms_per_delay_FD(delay_index) = rms(FD_run(SIGMA_IDX, delay_index, ABSORB_IDX));
    rms_per_delay_TD(delay_index) = rms(TD_run(SIGMA_IDX, delay_index, ABSORB_IDX));
end

LEGEND = { 'Frequency domain', 'Time domain' };

figure(1);
plot(NOISE_SIGMAS, [rms_per_sigma_FD, rms_per_sigma_TD]);
xlabel('Noise stdev'); ylabel('RMS error [samples]');
legend(LEGEND);

figure(2);
plot(DELAYS*FS, [rms_per_delay_FD, rms_per_delay_TD]);
xlabel('Delay [samples]'); ylabel('RMS error [samples]');
legend(LEGEND);

figure(3);
plot(ABSORPTIONS, [rms_per_absorb_FD, rms_per_absorb_TD]);
xlabel('Absorption coefficient'); ylabel('RMS error [samples]');
legend(LEGEND);