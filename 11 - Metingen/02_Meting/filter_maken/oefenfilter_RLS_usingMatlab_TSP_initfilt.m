%% Oefenen met het maken van een filter door gebruik te maken van RLS: Recursive Least Squares method
% voor betere benadering: pas de forgetting factor en de lengte van het
% filter aan!
close all;

signaal_goed_maken;

fs=100;

%% generate inputsequence
t0=0.5125345;

t=(0:1/fs:1)';                                  % time vector

s=input;   % input signal

%% convolve input with a filter
g=sinc(fs*(t-t0));                               % filter
%g=ones(1,10)/10;
%g=[zeros(100,1); 1; zeros(500,1)];
%g=[1; zeros(100,1)];

x=conv(s,g);                                    % output signal
x=output_padded;

%% initializing the RLS algoritm from Matlab:
hrls=dsp.RLSFilter(200, 'ForgettingFactor', 0.999999);
%[y,e]=step(hrls,[s;zeros(length(g)-1,1)],x);
[y,e] = step(hrls, s, x);
w=hrls.Coefficients;

x_reproduce=conv(s,w);

if length(x)<length(x_reproduce)
    x=[x;zeros(length(x_reproduce)-length(x),1)];
else
    x_reproduce=[x_reproduce;zeros(length(x)-length(x_reproduce),1)];
end

e=x-x_reproduce;
y=x_reproduce;

g=g';
if length(w)<length(g)
    w=[w zeros(1,length(g)-length(w))];
else
    g=[g zeros(1,length(w)-length(g))];
end

subplot(2,1,1), plot(1:length(x), [x,y,e]);
title('System Identification of an FIR filter');
legend('Desired', 'Output', 'Error');
xlabel('time index'); ylabel('signal value');
subplot(2,1,2); stem(w);
legend('Estimated'); 
xlabel('coefficient #'); ylabel('coefficient value');