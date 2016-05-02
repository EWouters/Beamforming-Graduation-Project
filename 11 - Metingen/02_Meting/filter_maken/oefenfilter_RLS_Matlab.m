hrls1 = dsp.RLSFilter(11, 'ForgettingFactor', 0.98);
hfilt = dsp.FIRFilter('Numerator',fir1(10, .25)); % Unknown System
x = randn(1000,1);                       % input signal
d = step(hfilt, x) + 0.01*randn(1000,1); % desired signal
[y,e] = step(hrls1, x, d);
w = hrls1.Coefficients;
subplot(2,1,1), plot(1:1000, [d,y,e]);
title('System Identification of an FIR filter');
legend('Desired', 'Output', 'Error');
xlabel('time index'); ylabel('signal value');
subplot(2,1,2); stem([hfilt.Numerator; w].');
legend('Actual','Estimated'); 
xlabel('coefficient #'); ylabel('coefficient value');

hrls2 = dsp.RLSFilter('Length', 11, 'Method', 'Householder RLS');
hfilt2 = dsp.FIRFilter('Numerator',fir1(10, [.5, .75]));
x = randn(1000,1);                           % Noise
d = step(hfilt2, x) + sin(0:.05:49.95)';     % Noise + Signal
[y, err] = step(hrls2, x, d);
figure;
subplot(2,1,1), plot(d), title('Noise + Signal');
subplot(2,1,2), plot(err), title('Signal');