load('bestmic_jun_TSP_090_analysed.mat')
h=mean(bestmic_jun_TSP_090_analysed,2);

f_min=125;
f_max=20e3;
Fs=48e3;

h_fft=fft(h);

h_dB=db(abs(h_fft));

h_dB=h_dB(1:round(end/2));

Hz=Fs/length(h_fft);
x=linspace(0,Fs/2,length(h_dB));

begin=round(f_min/Hz);
eind=round(f_max/Hz);

Gamma_desired=mean(h_dB(begin:eind));

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

% clearvars -except w

w_smooth=conv(w,ones(1,7)/7);
%plot(w_smooth);hold on;plot(w,'r');

w(begin:eind)=w_smooth(begin+2:eind+2);

%a=fft(a);
a_dB=db(abs(a));
a_dB=a_dB(1:round(end/2),:);
f=linspace(0,24e3,length(a_dB));

plot(f,a_dB(:,1),'g');hold on; plot(f,w,'r');plot(f,a_dB(:,1)+w-mean(w));hold off;
axis([125 2e4 -40 -15])
legend('Gain smartphone microphone','Weights','Log-equalized gain')
xlabel('Frequency [Hz]')
ylabel('Amplitude')
title('Adding the weights to the measurement of: NX506, 2 June 2015, \phi=90, \theta=0, TSP')
grid

plot(f,h_dB,'g');hold on; plot(f,w,'r');plot(f,h_dB+w-mean(w));hold off;
axis([125 2e4 mean(w)-10 mean(w)+10])
legend('Gain microphone','Weights','Log-equalized gain')
xlabel('Frequency [Hz]')
ylabel('Amplitude')
title('Adding the weights to the gain of the microphone: measurement 2 June 2015, TSP')
grid