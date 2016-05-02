%%INITIALIZE
clear all; close all; clc;

% Properties of the phone
d=0.12;             % Distance between the mics
N=2;                % Amount of mics

% Physical constants
c=343;              %Speed of sound in air

% Properties of the signal
freq=300;% The frequency of the source signal
freq2=600;% The frequency of the noise signal
theta=pi;% Angle of the source signal
theta2 = 2 * pi/9;% Angle of the noise signal

% Our chosen properties
fs = 80000;%Sample frequency
time_frame = 0.02;%Duration of 1 time frame
sptf = fs * time_frame;%The amountofsamplespertimeframe
noise_amp = 0.1;%Thenoiseamplitude
L=2^(ceil(log2(sptf)));%Thepowerof2fortheFFT
totaltime = 1;%Thetotaltimeofthesignal

%%INPUTSIGNAL
tt = linspace (0, totaltime, fs * totaltime).';%Samplestilltotaltime
tau1=d/c * sin(theta);%Timedelaytomic2forsignal
tau2=d/c * sin(theta2);%Timedelaytomic2fornoise
signal=sin(2 * pi * freq * tt);%Signalmic1
signal2=sin(2 * pi * freq * (tt - tau1));%Signalmic2
noise=4 *sin(2 *pi * freq2 * tt)+noise_amp *randn(totaltime *fs,1);%- Noise mic 1
noise2=4 *sin(2 *pi * freq2 * (tt - tau2)) + noise_amp *randn(totaltime *fs,1);%- Noise mic 2
signal_total=signal+noise;%Sumofthesignalandnoiseatmic1
signal_total2=signal2+noise2;%Sumofthesignalandnoiseatmic2
x1=[signal,signal2];
xsum=[signal_total,signal_total2];
f_center=linspace(0, fs - fs /(2 *L),L).';%Thecenterfrequenciesforeachbin

zeta= -1i *2 *pi *f_center *d *sin(theta)/c;%Thephaseshiftofthesignalfor-mic2
a_n=1/N;%Theamplitudeweights
w = a_n *[(exp(zeta)),ones(L,1)];%Weightswithdelays

%%RECONSTRUCTINGTHEORIGINALSIGNAL
nr_frames=floor((length(signal)-sptf)/(sptf/2));
rec_signal=zeros(size(signal(:,1)));
rec_signal_total=zeros(size(signal_total(:,1)));

testsignal1=zeros(L,nr_frames);
testsignal2=zeros(L,nr_frames);

for I=1:nr_frames
	win=[sqrt(hanning(sptf)),sqrt(hanning(sptf))];
	frame_x1=x1((sptf/2) *(I - 1) + 1: (sptf/2) *(I - 1) + sptf, :) .*(win);
	fft_x1=fft(frame_x1, L);
	
    frame_xsum=xsum((sptf/2) *(I - 1) + 1:(sptf / 2) *(I - 1)+sptf, :).*(win);
	fft_xsum=fft(frame_xsum,L);
	fft_xsum(end,:)=real(fft_xsum(end,:));
	
    fft_x1([1,L/2+1],:)=real(fft_x1([1,L/2+1],:));
	part1=fft_x1(1:L/2+1,:);
	fft_x1=[part1; conj(flipud(part1(2 : end - 1,:)))];
	
    fft_xsum([1, L/2 + 1], :) = real(fft_xsum([1,L/2+1],:));
	part1 = fft_xsum(1: L/2 + 1, :);
	fft_xsum=[part1; conj(flipud(part1(2 : end - 1, :)))];
	estimate_fft_signal=w .*(fft_x1);
	estimate_fft_signal_2 = estimate_fft_signal(:, 1) + estimate_fft_signal(:, 2);
	
    estimate_fft_signal_total = w .*(fft_xsum);
	estimate_fft_signal_total_2 = estimate_fft_signal_total(:, 1) + estimate_fft_signal_total(:,2);
	
    testsignal2(:,I) = estimate_fft_signal_total_2;
	testsignal1(:,I) = fft_xsum(:, 1);
	
    estimate_signal = real(ifft(estimate_fft_signal_2));
	
    estimate_signal_total=real(ifft(estimate_fft_signal_total_2));
	
    rec_signal((sptf/2) *(I - 1) + 1:(sptf/2) *(I - 1)+sptf) = rec_signal((sptf/2) *(I - 1) + 1:(sptf/2) *(I - 1)+sptf)+estimate_signal(1:sptf).*(sqrt(hanning(sptf)));
	
    rec_signal_total((sptf/2) *(I - 1) + 1:(sptf/2) *(I - 1)+sptf) = rec_signal_total((sptf/2) *(I - 1) + 1:(sptf/2) *(I - 1) + sptf) + estimate_signal_total(1:sptf).*(sqrt(hanning(sptf)));
end

%%PLOTS
%Timeplot
t=linspace(0,totaltime,totaltime *fs);
figure;
subplot(2,1,2)
plot(t,real(signal_total2(1:totaltime *fs)));
hold on
plot(t,real(rec_signal_total(1:totaltime *fs)),'.-r');
plot(t,real(signal2(1:totaltime *fs)),'--g');
legend('noisyin','beamformed','desired in')
title('Incoming, beamformed and desired signals')
axis([0.200 0.210 -5 5]);
xlabel('Time(inseconds)');
ylabel('Amplitude');
%Frequencyplot
subplot(2,1,1)
plot(linspace(1, fs, L), 10 *log10(mean(abs(testsignal1).^2, 2)));
hold on
plot(linspace(1, fs, L), 10 *log10(mean(abs(testsignal2).^2,2)),'r');
title('Spectrum plots of in signal and signal after beamforming in dB')
legend('insignal','beamformedsignal')
axis([0 4000 10 50]);
xlabel('Frequency (in Hertz)');
ylabel('Magnitude (in dB)');
% Polarplot
figure;
polarfreq=[300, 600];
polarbin=zeros(1, length(polarfreq));
for I=1:length(polarfreq);
    polarbin(I) = floor(polarfreq(I)/fs *L);
    delta=((c / f_center(polarbin(I)))/d)^-1;
    [w_dakjepolarhoek] = beam_resp(w(polarbin(I), :) ,L , delta);
    subplot(ceil(length(polarfreq)/2), 2, I)
    polar90(polarhoek, abs(w_dakje));
    title(['Frequency=',num2str(polarfreq(I))])
end