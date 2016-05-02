% addpath('C:\Users\Tim\Documents\GitHub\android-beamforming\11 - Metingen\02_Meting\uitvoering');

% TSP
a=AnalyseTSPSequence(NX506_TSP_063,0,10,15,0,'circ');
a_dB=db(abs(a));
a_dB=a_dB(1:round(end/2),:);
[y_lang, x_lang]=size(a_dB);
x=linspace(0,360,x_lang); % 0 to 360 graden, x samples
y=logspace(Fs/length(a),log10(Fs/2),length(a_dB)); % 10^-4 tot 10^4 kHz in length(b) samples

figure;
mesh(x,y,flipud(a_dB));
view(2)
axis([0 360 min(y) max(y)])
colorbar
set(gca,'YScale','log');
title('TSP Elevation of phi 63');

% MLS
a=AnalyseMLSSequence(NX506_MLS_063,0,10,15,'false',0);
a_dB=db(abs(fft(a)));
a_dB=a_dB(1:round(end/2),:);
[y_lang, x_lang]=size(a_dB);
x=linspace(0,360,x_lang); % 0 to 360 graden, x samples
y=logspace(Fs/length(a),log10(Fs/2),length(a_dB)); % 10^-4 tot 10^4 kHz in length(b) samples

figure;
mesh(x,y,flipud(a_dB));
view(2)
axis([0 360 min(y) max(y)])
colorbar
set(gca,'YScale','log');
title('MLS Elevation of phi 63');