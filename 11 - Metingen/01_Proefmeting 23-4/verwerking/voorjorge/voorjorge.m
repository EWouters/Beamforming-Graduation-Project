load('voorjorge.mat')

Fs=48000; %sample frequency in Hz

figure;
plot(TSP_0_graden');
title('Recorded TSP sequences (for 45 different angles) in time domain')

figure;
plot(MLS_0_graden');
title('Recorded MLS sequences (for 45 different angles) in time domain')

% plot TSP
TSP_help=[TSP_0_graden];% zeros(45,480000*2)];
TSP_0=AnalyseTSPSequence(TSP_help',0,10,14,0,'circ');
TSP_0_dB=20*log10(abs(TSP_0));%/min(abs(TSP_0(:))));

TSP_0_dB=TSP_0_dB(1:round(end/2),:);

[y_lang x_lang]=size(TSP_0_dB);
x=linspace(0,360,x_lang); % 0 to 360 graden, 45 samples
y=logspace(Fs/length(TSP_0),log10(Fs/2),y_lang); % 10^-4 tot 10^4 kHz in length(b) samples

figure;
mesh(x,y,flipud(TSP_0_dB));
view(2)
axis([0 360 min(y) max(y)])
colorbar
set(gca,'YScale','log');
title('TSP at elevation of 0 degrees');

% MLS
MLS_0=AnalyseMLSSequence(MLS_0_graden',0,10,14,'false',0);
MLS_0_dB=20*log10(abs(fft(MLS_0)));
MLS_0_dB=MLS_0_dB(1:floor(end/2),:);
x=linspace(0,360,45);
y=logspace(-4,log10(length(MLS_0_dB)),length(MLS_0_dB));

figure;
mesh(x,flipud(y),flipud(MLS_0_dB));
set(gca,'YScale','log');
view(2)
axis([0 360 10^-4 length(MLS_0_dB)])
title('MLS at elevation of 0 degrees');
colorbar