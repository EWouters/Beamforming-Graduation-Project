close all;
clear all;
clc;
%% INITIALIZE

d = 0.12;                    %afstand tussen de micofoons
N = 2;                      %hoeveelheid microfoons
c = 343;                    %geluidssnelheid
freq = 1700;                %frequency of interest
theta1 = 3*pi/8;          %pi/2;%hoek in radialen
theta2 = pi/2;
fs = 8000;                  % 8000 samples/ s
time_frame = 0.02;          % 20 ms
sptf = fs * time_frame;     % samples per time frame; 160 samples per 20 ms
L = 2^(ceil(log2(sptf)));
noise =0.1;
totaaltijd = 1;

%[bal, sf] = wavread('bal_m.wav');
bal=randn(8000,1);
bal = 10 * bal;
%kerk = 10*wavread('kerk_m.wav');
kerk=randn(8000,1);
%% SIGNAL
tt = linspace(0,totaaltijd, fs * totaaltijd).';
tau1 = d / c * sin(theta1);
tau2 = d / c * sin(theta2);

noise1 = noise*randn(fs*totaaltijd,1);
noise2 = noise*randn(fs*totaaltijd,1);

noise1 = sin(2*pi*2500*tt)+noise1; % noise1 - 0.5*noise; %sin(2*pi*1500*t);%  %%%%%%%%%%%%%%ruisbron
noise2 = sin(2*pi*2500*(tt-tau2))+noise2; % noise2 -0.5*noise;%sin(2*pi*1500*t); %

signal1 = sin(2*pi*freq*tt) + noise1; %sin(2*pi*1500*t);%
signal2 = sin(2*pi*freq*(tt-tau1)) +noise2;%sin(2*pi*1500*t); %

noise = [noise1,noise2];
signal = [signal1,signal2];

%fft_signal = [fft(signal1,L), fft(signal2,L)];
estimate_signal = zeros(256,1);

nr_frames = floor((length(signal1) - sptf) / (sptf/2));
rec_signal = zeros(size(signal(:,1)));
%%%schatten van correlatie matrix
for J = 1 : 50 + 1
    
    win = [sqrt(hanning(sptf)), sqrt(hanning(sptf))];
    frame_noise = noise((sptf/2)*(J-1)+1:(sptf/2)*(J-1)+sptf,:).*(win);
    fft_noise = fft(frame_noise,L);
    
    fft_noise([1,L/2+1],:) = real(fft_noise([1,L/2+1],:));
    part1 = fft_noise(1:L/2+1,:);
    fft_signal = [part1;conj(flipud(part1(2:end-1,:)))];  
    
    for I =1 :L/2+1
              
        noise_cor(1,1,I,J) =   abs(part1(I,1)).^2;
        noise_cor(2,2,I,J) =   abs(part1(I,2)).^2;
        noise_cor(1,2,I,J) =   part1(I,1)*conj(part1(I,2));
        noise_cor(2,1,I,J) =   part1(I,2)*conj(part1(I,1));
    end
     
end
 noise_cor= mean(noise_cor,4);
%%%



for J = 1 : nr_frames + 1
    
    win = [sqrt(hanning(sptf)), sqrt(hanning(sptf))];
    frame_signal = signal((sptf/2)*(J-1)+1:(sptf/2)*(J-1)+sptf,:).*(win);
    fft_signal = fft(frame_signal,L);
    
    fft_signal([1,L/2+1],:) = real(fft_signal([1,L/2+1],:));
    part1 = fft_signal(1:L/2+1,:);
    fft_signal = [part1;conj(flipud(part1(2:end-1,:)))];
     fft_signal_mat(:,J)= fft_signal(:,1);
    %noise_coh_func = corrcoef(fft_signal, fft_signal');
    
    
    for I = 0 : L/2
        %% BOUWEN VAN DE NOISE COHERENCE FUNCTION
        f_center = I * fs / L;
        %     TAU = f_center*d/c;
        %     noise_coh_func = [1 sin(TAU+0.0001)/(TAU+0.0001); sin(TAU+0.0001)/(TAU+0.0001) 1];
        
        %% Berekenen van de center frequencies en de filter weights
        % De delay die gebruikt gaat worden in de weegcoefficienten voor alle
        % center frequencies
        zeta = -1i*2*pi*f_center*d*sin(theta1) / c;
        
        % The amplitude weights
        a_n = 1 / N;
        
        % Delay vector
        c_ = [1; exp(zeta)];
        
             
        % Weight vector
        
        w = (noise_cor(:,:,I+1)\c_) / ((c_'/noise_cor(:,:,I+1))*c_);
        flabber(:,I+1) = w;
        w = conj(w);       
          
        
        
        estimate_signal(I+1) = w.'*fft_signal(I+1,:).';
        
            
        
    end
    fft_estimate_signal_mat(:,J)=  estimate_signal;
    estimate_signal=estimate_signal(1:L/2+1);
    estimate_signal([1,L/2+1],:) = real(    estimate_signal([1,L/2+1],:)); % geforceerd
    estimate_signal=[estimate_signal;flipud(conj(estimate_signal(2:end-1)))];
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
title('abs plot van in signaal en het beamgeformde signaal')

figure;
plot(linspace(0,totaaltijd,length(signal1)),signal1, 'b');
hold on
plot(linspace(0,totaaltijd,length(rec_signal)),rec_signal, '-.r');
plot(linspace(0,totaaltijd,length(signal1)),sin(2*pi*freq*(tt)), '--k')
legend('noisy in', 'estimate', 'desired in')
title('in, uit en gewenste signalen')
axis([0.02 0.03 -2 2]);

figure;
plot(linspace(1,fs,L),10*log10( mean(abs(fft_signal_mat).^2,2) ) );
hold on
plot(linspace(1,fs,L),10*log10( mean(abs( fft_estimate_signal_mat).^2,2) ) ,'r');
title('plots van in signaal en signaal na beamforming in dB')

%% polar plotje


polarbin = zeros(1,4);
figure;

f_center = linspace(0,fs-fs / (2 * L), L).';
polarfreq = [500, 850, 1250, 1500, 1700, 2000] ;  %polar plot is voor deze frequentie
for i = 1:length(polarfreq);
polarbin(i) = floor(polarfreq(i)/(((fs-fs / (2 * L)))/256));

delta = (c/f_center(polarbin(i)))/d;
[w_dakje polarhoek] = beam_resp(flabber(:,polarbin(i)),L,delta);


subplot(2,ceil(length(polarfreq)/2),i)
polar90(polarhoek, abs(w_dakje));
title(['frequency = ', num2str(polarfreq(i))])

end
