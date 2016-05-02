load('NX506_090.mat')
close all;

t=linspace(0,1800/48e3,1800);

figure;
plot(NX506_090_000/max(abs(NX506_090_000)),'Color','g');
axis([1 1800 -1 1])
axis([0 max(t) -1 1])
hold on;
plot(t,NX506_090_189/max(abs(NX506_090_000)),'r');
hold off;
legend('NX506, \phi=90^\circ, \theta=0^\circ','NX506, \phi=90^\circ, \theta=189^\circ')
xlabel('Time [ms]')
xlabel('Vector entry')
ylabel('Amplitude (normalized)')
title('Impulse response','FontSize',12)

figure;
plot(t,db(abs(NX506_090_000/max(abs(NX506_090_000)))),'g');
hold on;
plot(t,db(abs(NX506_090_189/max(abs(NX506_090_000)))),'r');
hold off;
line([0 max(t)], [-60 -60])
axis([0 max(t) -70 0])
legend('NX506, \phi=90^\circ, \theta=0^\circ','NX506, \phi=90^\circ, \theta=189^\circ')
xlabel('Time [ms]')
ylabel('Amplitude (normalized) [dB]')
title('Power spectrum of the impulse response','FontSize',12)