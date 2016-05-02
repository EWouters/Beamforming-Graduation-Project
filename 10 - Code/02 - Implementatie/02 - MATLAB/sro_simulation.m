% SRO detectie simulatie
f = 10e3;
t = linspace(0,60,48e3*60); % 48e3 samples per second, 60 seconds long
delta_f = f/1e6; % 1 ppm 
signal = sin(2*pi*f*t);
signal_error = sin(2*pi*(f+delta_f)*t);
signal_fd = log10(abs(fftshift(fft(signal))));
signal_error_fd = log10(abs(fftshift(fft(signal_error))));
frequency_scale = linspace(-24e3,24e3,length(t));

hold on;
plot(frequency_scale, signal_fd, 'b')
plot(frequency_scale, signal_error_fd,'r');