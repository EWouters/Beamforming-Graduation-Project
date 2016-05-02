%% INITIALIZE
clear all; close all; clc;

% Properties of the Phone
d = 0.10;   % Distance between the mics
N = 2;      % Amount of mics

% Physical Constants
c = 343;

% Properties of the Signal
freq = 2000;
freq2 = 3000;
theta = 0;             % hoek is in radialen
theta2 = pi/4; %140/360*2*pi;       % hoek voor de vieze cosinus uit verkeerde richting.
fs = 8000;              % 8000 samples / s
time_frame = 0.02;      % 20 ms
sptf = fs * time_frame; % samples per time frame; 160 samples per 20 ms
noise = 0.1;

bal = 10*wavread('bal_m.wav');
%% INPUT SIGNAL
% Source Signal (should be input)
totaaltijd = length(bal)/fs; %totale tijd in seconde
tt = linspace(0,totaaltijd, fs * totaaltijd).'; %samples tot totaaltijd 

tau1 = d / c * sin(theta); %tijdvertraging naar mic2 voor s1
tau2 = d / c * sin(theta2); %tijdsvertraging naar mic2 voor (ruis) s2

%het te ontvangen signaal s1
s1_mic1 = bal; %signal s1 bij mic1
s1_mic2 = bal;  %signal s1 bij mic2

%ruissignaal uit andere hoek s2
%s2_mic1 = 0.1 * randn(totaaltijd * fs,1);
%s2_mic2 = 0.1 * randn(totaaltijd * fs,1);

s2_mic1 = 1/30*(sin(2*pi*freq2*tt)+sin(2*pi*2000*tt)+sin(2*pi*500*tt)+sin(2*pi*1500*tt)); %signal s2 bij mic1
s2_mic2 = 1/30*(sin(2*pi*freq2*(tt-tau2)) + sin(2*pi*2000*(tt-tau2)) + sin(2*pi*500*(tt-tau2)) + sin(2*pi*1500*(tt-tau2))); %signal s2 bij mic2

%som van signaal met ruis ssum
ssum_mic1 = s1_mic1 + s2_mic1; %het somsignaal bij mic1
ssum_mic2 = s1_mic2 + s2_mic2; %het somsignaal bij mic2

wavplay(bal);
wavplay(ssum_mic1);
%ingangssignalen mics in matrixvorm
x1 = [s1_mic1, s1_mic2]; %s1 op beide mics
xsum = [ssum_mic1, ssum_mic2]; %ssum op beide mics

L = 2^(ceil(log2(sptf))); %de kleinste 2-macht groter dan sptf
f_center = linspace(0,fs-fs / (2 * L), L).';

% De delay die gebruikt gaat worden in de weegcoefficienten voor alle
% center frequencies
zeta = -1i*2*pi*f_center*d*sin(theta) / c;

% The amplitude weights
a_n = 1 / N;

% Weights with delays
w = a_n * [(exp(zeta)), ones(L, 1)];

%% Simuleren van de 2 microfoons door het signaal te vermenigvuldigen met 1 en de vertraging
% fft_x = fft_s * [1, exp(-1i*2*pi*freq*d*sin(theta) / c)];
% 
% 
% fft_x2(:,1) = fft_ssum;
% fft_x2(:,2) = exp(-1i*2*pi*freq*d*sin(theta) / c) *fft_s + exp(-1i*2*pi*freq*d*sin(theta2) / c) * fft_s2;
% Adding the noise
% fft_x(1, :) = fft_x(1, :) + fft_noise_1;
% fft_x(2, :) = fft_x(2, :) + fft_noise_2;

% x1=randn(fs,2) ;
% x2=x1;

nr_frames = floor((length(s1_mic1) - sptf) / (sptf/2));
rec_s1 = zeros(size(s1_mic1(:,1)));
rec_ssum = zeros(size(ssum_mic1(:,1)));
  
for I = 1 : nr_frames   
    %% Wegen van de ingangssignalen uit de microfoons en signaal reconstrueren
    
    % Data uit de microfoons wegen met de weegfactoren en optellen (Delay en
    % Sum)
    win = [sqrt(hanning(sptf)), sqrt(hanning(sptf))];
    frame_x1 = x1((sptf/2)*(I-1)+1:(sptf/2)*(I-1)+sptf,:).*(win);
    fft_x1 = fft(frame_x1,L);
    
    frame_xsum = xsum((sptf/2)*(I-1)+1:(sptf/2)*(I-1)+sptf,:).*(win);
    fft_xsum = fft(frame_xsum,L);
    
    fft_x1([1,L/2+1],:) = real(fft_x1([1,L/2+1],:));
    part1 = fft_x1(1:L/2+1,:);
    fft_x1 = [part1;conj(flipud(part1(2:end-1,:)))]; % eventueel conj(flipud(part1))
    
    fft_xsum([1,L/2+1],:) = real(fft_xsum([1,L/2+1],:));
    part1 = fft_xsum(1:L/2+1,:);
    fft_xsum = [part1;conj(flipud(part1(2:end-1,:)))]; % eventueel conj(flipud(part1))
    estimate_fft_s1 = (w).*(fft_x1);
    estimate_fft_s1_2 = estimate_fft_s1(:,1)+estimate_fft_s1(:,2);
    
    
    estimate_fft_ssum = (w).*(fft_xsum);
    estimate_fft_ssum_2 = estimate_fft_ssum(:,1) + estimate_fft_ssum(:,2);
    
  
    % Terugbrengen van DAS signaal naar tijddomein
    
    estimate_s1 = real(ifft(estimate_fft_s1_2));
    
    estimate_ssum = real(ifft(estimate_fft_ssum_2));
    rec_s1((sptf/2)*(I-1)+1:(sptf/2)*(I-1)+sptf) = rec_s1((sptf/2)*(I-1)+1:(sptf/2)*(I-1)+sptf)+estimate_s1(1:sptf).*(sqrt(hanning(sptf)));
    rec_ssum((sptf/2)*(I-1)+1:(sptf/2)*(I-1)+sptf) = rec_ssum((sptf/2)*(I-1)+1:(sptf/2)*(I-1)+sptf)+estimate_ssum(1:sptf).*(sqrt(hanning(sptf)));
    
end

wavplay(rec_ssum);

%% PLOTS
frequency = 0:(fs / (L - 1)):fs;
%t = linspace(0,time_frame,sptf);

figure;
plot(frequency, abs(fft_x1(:,1)));
hold on;
plot(frequency,abs(estimate_fft_s1_2), '-.r');
title('magnitude van 1 ingangssignaal en onze estimate van het laatste tijdsframe')
legend('signaal 1', 'uitgang beamformer')

figure;
plot(frequency, abs(fft_xsum(:,1)));
hold on;
plot(frequency,abs(estimate_fft_ssum_2), '-.r');
%title('Magnitude van hele ingangssignaal en onze estimate van het laatste tijdsframe')
legend('signal in mic 1', 'output beamformer')
xlabel('frequency (in Hertz)');
ylabel('magnitude');
axis([0 4000 0 50]);

% figure
% plot(frequency, angle(fft_x(2,:)));
% hold on;
% plot(frequency, angle(estimate_fft_s_2), '-.r');
% title('angle plot van de fftx en estimate')
% figure;
% plot(frequency,real(estimate_fft_s_2sum),'-.r')
% hold on
% plot(frequency,real(fft_x2(2,:)));
% title('plot van de real delen van estimate fft s 2 en fft x')
% legend('estimate', 'fft x')
% figure;
% plot(frequency,imag(estimate_fft_s_2sum), '-.r')
% hold on
% plot(frequency,imag(fft_x2(2,:)));
% title('plot van de imag delen van estimate fft s 2 en fft x')
% legend('estimate', 'fft x')

%s1_mic2 = ifft(fft_x1(:,2));
t = linspace(0,totaaltijd,totaaltijd*fs);

figure;
plot(t, s1_mic2(1:totaaltijd*fs),'');
hold on
plot(t, real(rec_s1(1:totaaltijd*fs)), '--r');
title('in en uitgangsignaal voor alleen het deel uit de goede richting')
legend('in signaal', 'uit signaal')
axis([0 1 -1 1]);

test2 = ifft(transpose(fft_xsum(:,2)));
test3 = ifft(transpose(fft_xsum(:,1)));

figure;
plot(t, real(ssum_mic2(1:totaaltijd*fs)));
hold on
plot(t, real(rec_ssum(1:totaaltijd*fs)), '.-r');
hold on
plot(t, real(s1_mic2(1:totaaltijd*fs)),'--g');
legend('signal in', 'output beamformer', 'signal in only from right direction')
%axis([0.200 0.202 -2 2]);
%title('time-domain signal reconstruction');
xlabel('time (in seconds)');
ylabel('amplitude');

%         figure
%         plot((1:10), exp(-1i*2*pi*freq*d*sin(linspace(0,pi,10) / c)))
%         title('plot van de vertraging voor verschillende theta')