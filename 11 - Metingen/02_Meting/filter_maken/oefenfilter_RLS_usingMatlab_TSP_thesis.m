%% Oefenen met het maken van een filter door gebruik te maken van RLS: Recursive Least Squares method
% voor betere benadering: pas de forgetting factor en de lengte van het
% filter aan!
close all;

signaal_goed_maken;

fs=100;

%% generate inputsequence
t0=0.005125345;

t=(0:1/fs:1)';                                  % time vector

s=input_enkel;   % input signal

%% convolve input with a filter
%g=sinc(fs*(t-t0));                               % filter
%g=ones(1,10)/10;
g=[zeros(5,1); 1; zeros(500,1)];
%g=[1; zeros(100,1)];

x=conv(s,g);                                    % output signal
x=output_enkel;

%% initializing the RLS algoritm from Matlab:
hrls=dsp.RLSFilter(300, 'ForgettingFactor', 0.99999);
[y,e]=step(hrls,x,[s;zeros(length(x)-length(s)-1,1)]);
w=hrls.Coefficients;

s_reproduce=conv(w,x);
s=[s;zeros(length(s_reproduce)-length(s),1)];
e=s-s_reproduce;

% subplot(2,1,1), plot(1:length(x), [x,y,e]);
% title('System Identification of an FIR filter');
% legend('Desired', 'Output', 'Error');
% xlabel('time index'); ylabel('signal value');
% subplot(2,1,2); stem([g'; w].');
% legend('Actual','Estimated'); 
% xlabel('coefficient #'); ylabel('coefficient value');

delta=conv(g,w)';
g=g';
g=[g zeros(1,length(delta)-length(g))];
w=[w zeros(1,length(delta)-length(w))];

figure;
%subplot(2,1,1)
plot(1:length(e), [s,s_reproduce,e]);
legend('Input signal','Reconstructed inputsignal','Error');
title('FIR filter for the inverse soundsystem using RLS','FontSize',12);
xlabel('Entry no.')
ylabel('amplitude')
%axis([0 length(e) -2 2])
%subplot(2,1,2); stem([g;w;delta].');
%legend('Filter','Estimated inverse filter','Conv')

%%
% check whether you made it
% h=w;
% s_reproduce= conv(h,x);
% check=conv(g,h);
% 
% %plot!
% figure;
% subplot(2,2,1)
% plot(s);hold on; plot(x,'r');
% legend('input signaal systeem','output signaal systeem')
% axis([1 length(x) -max(max(s),max(x)) max(max(s),max(x))])
% subplot(2,2,2)
% plot(h,'g');
% axis([1 length(h) -max(h)-0.1 max(h)+0.1])
% legend('filter')
% subplot(2,2,3);
% plot(s);hold on; plot(s_reproduce,'r');
% axis([1 length(s_reproduce) -max(max(s),max(s_reproduce)) max(max(s),max(s_reproduce))])
% hold off; legend('input signaal systeem','Conv(h,ouput)(=?input)')
% subplot(2,2,4);
% plot(check,'k');legend('conv(g,h)=?delta');axis([-0.1*length(check) length(check) -max(abs(check)) max(abs(check))])