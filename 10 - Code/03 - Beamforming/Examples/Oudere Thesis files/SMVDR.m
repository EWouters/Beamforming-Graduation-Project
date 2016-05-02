close all;
clear all;
clc;
%% INITIALIZE

d = 0.1;                    %afstand tussen de micofoons
N = 2;                      %hoeveelheid microfoons
c = 343;                    %geluidssnelheid
freq = 1700;                %frequency of interest
theta = 3*pi/8; %pi/2;      %hoek in radialen

fs = 8000;                  % 8000 samples/ s
time_frame = 0.02;          % 20 ms
sptf = fs * time_frame;     % samples per time frame; 160 samples per 20 ms
L = 2^(ceil(log2(sptf)));
noise = 5;
totaaltijd = 0.2;
%% SIGNAL
tt = linspace(0,totaaltijd, fs * totaaltijd).';
tau = d / c * sin(theta);

noise1 = noise*rand(fs*totaaltijd,1);
noise2 = noise*rand(fs*totaaltijd,1); 

signal1 = sin(2*pi*freq*tt) + noise1 - 0.5*noise; %sin(2*pi*1500*t);% 
signal2 = sin(2*pi*freq*(tt-tau)) + noise2 -0.5*noise;%sin(2*pi*1500*t); %

signal = [signal1,signal2];

%fft_signal = [fft(signal1,L), fft(signal2,L)];
estimate_signal = zeros(256,1);

nr_frames = floor((length(signal1) - sptf) / (sptf/2));
rec_signal = zeros(size(signal(:,1)));

for J = 1 : nr_frames+1
    
    win = [sqrt(hanning(sptf)), sqrt(hanning(sptf))];
    frame_signal = signal((sptf/2)*(J-1)+1:(sptf/2)*(J-1)+sptf,:).*(win);
    fft_signal = fft(frame_signal,L);
    
    fft_signal([1,L/2+1],:) = real(fft_signal([1,L/2+1],:));
    part1 = fft_signal(1:L/2+1,:);
    fft_signal = [part1;conj(flipud(part1(2:end-1,:)))];

    for I = 0 : L -1    
    %% BOUWEN VAN DE NOISE COHERENCE FUNCTION
    f_center = I * fs / L;
    TAU = f_center*d/c;
    noise_coh_func = [1 sin(TAU+0.0001)/(TAU+0.0001); sin(TAU+0.0001)/(TAU+0.0001) 1];
    
    %% Berekenen van de center frequencies en de filter weights
    % De delay die gebruikt gaat worden in de weegcoefficienten voor alle
    % center frequencies
    zeta = -1i*2*pi*f_center*d*sin(theta) / c;
    
    % The amplitude weights
    a_n = 1 / N;
    
    % Delay vector
    c_ = [1; exp(zeta)];
    
    % Weight vector
    numerator = noise_coh_func\c_;
    denominator = (c_'/noise_coh_func)*c_;
    
    w = numerator / denominator; %no shit sherlock
    
    
    estimate = w.'*fft_signal(I+1,:).';

    estimate_signal(I+1) = estimate;
    end
    td_estimate_signal = real(ifft(estimate_signal(1:L)));
    rec_signal((sptf/2)*(J-1)+1:(sptf/2)*(J-1)+sptf) = rec_signal((sptf/2)*(J-1)+1:(sptf/2)*(J-1)+sptf)+td_estimate_signal(1:sptf).*(sqrt(hanning(sptf)));
end

%% RESULTS


%%PLOTS
figure;
plot(linspace(1,fs,L), abs(fft_signal(:,1)));
hold on
plot(linspace(1,fs,L), abs(estimate_signal),'r');
legend('in signaal', 'estimate')

figure;
plot(linspace(0,totaaltijd,length(signal1)),signal1, 'b');
hold on
plot(linspace(0,totaaltijd,length(rec_signal)),rec_signal, '--r');
plot(linspace(0,totaaltijd,length(signal1)),sin(2*pi*freq*tt), '--k')
legend('noisy in', 'estimate', 'desired in')
axis([0.02 0.03 -2 2]);
