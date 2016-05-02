% addpath('C:\Users\Tim\Documents\GitHub\android-beamforming\11 - Metingen\02_Meting\uitvoering');

%% stel in:
% naam_telefoon='NX501';
% phi=122;            % graden vanaf de z-as
% stap=9;             % stapgrootte

%% creating phi_naam

if phi<100
    if phi<10
        phi_naam=num2str(phi,'00%d');
    else
        phi_naam=num2str(phi,'0%d');
    end
else
    phi_naam=num2str(phi,'%d');
end
%% directory

figdir='C:\Users\Tim\Documents\GitHub\android-beamforming\11 - Metingen\02_Meting\resultaten\jun';

%% TSP plot
toplot=[naam_telefoon '_TSP_' phi_naam];
opdracht=['a=AnalyseTSPSequence(' toplot ',0,10,15,0,''circ'');'];
eval(opdracht);

a_dB=db(abs(a));
a_dB=a_dB(1:round(end/2),:);
% a_dB=a_dB(3000:12000,:);
[y_lang, x_lang]=size(a_dB);
x=linspace(0,360,x_lang); % 0 to 360 graden, x samples
y=logspace(Fs/length(a),log10(Fs/2),length(a_dB)); % 10^-4 tot 10^4 kHz in length(b) samples

figure;
mesh(x,y,a_dB);
view(2)
axis([0 360 min(y) max(y)])
colorbar
colormap jet
set(gca,'YScale','log');
titel=['TSP ' naam_telefoon ' at Elevation of \phi=' num2str(phi,'%d')];
title(titel);
saveas(gcf,strcat(figdir,[naam_telefoon '_TSP_' phi_naam]),'png');

%% MLS plot
toplot=[naam_telefoon '_MLS_' phi_naam];
opdracht=['a=AnalyseMLSSequence(' toplot ',0,10,15,''false'',0);'];
eval(opdracht);

a_dB=db(abs(fft(a)));
a_dB=a_dB(1:round(end/2),:);
[y_lang, x_lang]=size(a_dB);
x=linspace(0,360,x_lang); % 0 to 360 graden, x samples
y=logspace(Fs/length(a),log10(Fs/2),length(a_dB)); % 10^-4 tot 10^4 kHz in length(b) samples

figure;
mesh(x,y,a_dB);
view(2)
axis([0 360 min(y) max(y)])
colorbar
colormap jet
set(gca,'YScale','log');
titel=['MLS ' naam_telefoon ' at Elevation of \phi=' num2str(phi,'%d')];
title(titel);
saveas(gcf,strcat(figdir,[naam_telefoon '_MLS_' phi_naam]),'png');

%% save workspace
save([naam_telefoon '_' phi_naam]);
close all;