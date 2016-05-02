%b -> NX506j2 analysed

subplot(1,2,1)
plot(b(:,1),'g');hold on;plot(b(:,21),'r');hold off;
axis([1 1800 -0.061 0.061])
legend('NX506 equalized \phi=90, \theta=0','NX506 equalized \phi=90, \theta=189')

xlabel('Vector entry', 'FontSize', 14);
ylabel('Amplitude', 'FontSize', 14);
title('Impulse response', 'FontSize', 16);

subplot(1,2,2)
plot(db(abs(b(:,1))),'g');hold on; plot(db(abs(b(:,21))),'r'); hold off;
axis([1 1800 -80 0])
line([1 1800], [-68 -68]);
legend('NX506 equalized \phi=90, \theta=0','NX506 equalized \phi=90, \theta=189')

xlabel('Vector entry', 'FontSize', 14);
ylabel('[dB]', 'FontSize', 14);
title('Powerspectrum of the impulse response', 'FontSize', 16);