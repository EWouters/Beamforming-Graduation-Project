load('filter_signals.mat')
h=filter_mei;

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

%w_mei=w;
w_mei=w+ones(size(w))*7.7971;
plot(w_mei);hold on;plot(w_jun,'r'); hold off
%w_jun=w;