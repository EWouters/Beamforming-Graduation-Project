% impulse responsie vinden
% vergeet niet te transponeren

% a=AnalyseMLSSequence(MLS_0_graden(1,:)',0,10,14,'false',0);
% b=AnalyseTSPSequence(TSP_0_graden(1,:)',0,10,14,0,'circ');

Fs=48000; %sample frequency in Hz

% plot TSP
TSP_help=[TSP_0_graden];% zeros(45,480000*2)];
TSP_0=AnalyseTSPSequence(TSP_help',0,10,14,0,'circ');
TSP_0_dB=20*log10(abs(TSP_0));%/min(abs(TSP_0(:))));
%imagesc(TSP_0_dB);

TSP_0_dB=TSP_0_dB(1:round(end/2),:);

[y_lang x_lang]=size(TSP_0_dB);
x=linspace(0,360,x_lang); % 0 to 360 graden, 45 samples
y=logspace(Fs/length(TSP_0),log10(Fs/2),y_lang); % 10^-4 tot 10^4 kHz in length(b) samples

%imagesc(x,y,TSP_0_dB);
%set(gca,'Yscale','log','Ydir','normal');
%set(gca,'Yscale','log','Ydir','normal', 'YTick', [0.25 0.5 1 2 4 8 16]);

figure;
mesh(x,y,flipud(TSP_0_dB));
view(2)
axis([0 360 min(y) max(y)])
colorbar
set(gca,'YScale','log');
title('Elevation of 0 degrees');

    % plot alleen tot 8000 Hz
figure;
tot8k=round(length(TSP_0_dB)*8000/(Fs/2));
mesh(x,flipud(y(1:tot8k)),flipud(TSP_0_dB(1:tot8k,:)));
set(gca,'YScale','log');
view(2)
axis([0 360 y(1) y(tot8k)])
title('Elevation of 0 degrees');
colorbar

% MLS
MLS_0=AnalyseMLSSequence(MLS_15_graden',0,10,14,'false',0);
MLS_0_dB=20*log10(abs(fft(MLS_0)));
MLS_0_dB=MLS_0_dB(1:floor(end/2),:);
x=linspace(0,360,45);
y=logspace(-4,log10(length(MLS_0_dB)),length(MLS_0_dB));

figure;
mesh(x,flipud(y),flipud(MLS_0_dB)); %flipud omdat de set 'Yscale' het hele zaakje omgooit!
set(gca,'YScale','log');
view(2)
axis([0 360 10^-4 length(MLS_0_dB)])
title('MLS op 0 graden');
colorbar

% de rest maken
TSP_60=AnalyseTSPSequence(TSP_60_graden',0,10,14,0,'circ');
TSP_60_dB=20*log10(abs(TSP_60));
mesh(x,flipud(y),flipud(TSP_60_dB));
set(gca,'YScale','log');
view(2)
axis([0 360 10^-4 length(TSP_60)])
title('TSP op 60 graden');
colorbar

% maken 3D plot
figure
azimuth=[linspace(0,2*pi,45) linspace(0,2*pi,45) linspace(0,2*pi,45) linspace(0,2*pi,45) linspace(0,2*pi,45)];
elevation=deg2rad([zeros(1,45) 15*ones(1,45) 30*ones(1,45) 45*ones(1,45) 60*ones(1,45)]);
r=1;
[x, y, z]=sph2cart(azimuth,elevation,r);
data=[TSP_0_dB(1,:) TSP_15_dB(1,:) TSP_30_dB(1,:) TSP_45_dB(1,:) TSP_60_dB(1,:)];
scatter3(x,y,z,100,data,'filled'); %100 is de dikte van de stippen
colorbar
view(2)