close all;
load voor_jorge.mat h_TSP

h=h_TSP;
clear h_TSP;

f_min=125;
f_max=20e3;
Fs=48e3;

h_plot=h(1:650);
t=1000*linspace(0,length(h_plot)/Fs,length(h_plot));

h_fft=fft(h);

h_dB=db(abs(h_fft));

h_dB=h_dB(1:round(end/2));

Hz=Fs/length(h_fft);
x=linspace(0,Fs/2,length(h_dB));

Gamma_desired=mean(h_dB(round(f_min/Hz):round(f_max/Hz)));

w=zeros(size(h_dB));

for i=1:length(h_dB)
    if i<round(f_min/Hz)
        w(i)=Gamma_desired;
    elseif i>round(f_max/Hz)
        w(i)=Gamma_desired;
    else
        w(i)=2*Gamma_desired-h_dB(i);
    end
end

ax_max=10+max(max(h_dB),max(w));
ax_min=min(min(h_dB),min(w));

subplot(1,3,1)
plot(t,h_plot);
xlabel('time [ms]');
ylabel('amplitude')
title('Impulse response measured by the microphone');
axis([min(t) max(t) -1.1*max(abs(h_plot)) 1.1*max(abs(h_plot))]);

subplot(1,3,2)
plot(x,h_dB,'r');hold on;
plot(x,w,'g');hold off;
xlabel('frequency [Hz]')
ylabel('Amplitude [dB]')
legend('Gain measured by the microphone','Computed weights','location','SouthWest');
title('Computation of weights')
line([f_min f_min], [ax_min ax_max]);
line([f_max f_max], [ax_min ax_max]);
axis([0 Fs/2 ax_min ax_max]);

subplot(1,3,3)
semilogx(x,h_dB,'r');hold on;
semilogx(x,w,'g');hold off;
legend('Gain measured by the microphone','Computed weights','location','SouthWest');
xlabel('frequency [Hz]')
ylabel('Amplitude [dB]')
title('Computation of weights')
line([f_min f_min], [ax_min ax_max]);
line([f_max f_max], [ax_min ax_max]);
axis([0 Fs/2 ax_min ax_max]);