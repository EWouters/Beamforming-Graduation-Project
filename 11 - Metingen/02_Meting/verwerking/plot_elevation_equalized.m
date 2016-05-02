% addpath('C:\Users\Tim\Documents\GitHub\android-beamforming\11 - Metingen\02_Meting\uitvoering');

%% stel in:
% naam_telefoon='NX501';
% phi=122;            % graden vanaf de z-as
% stap=9;             % stapgrootte

Fs=48e3;
y_as_min=125; %Hz
y_as_max=20e3; %Hz

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

figdir='C:\Users\Tim\Documents\GitHub\android-beamforming\11 - Metingen\02_Meting\resultaten\';

% if strcmp(method,'TSP')
%     %% TSP plot
%     toplot=[naam_telefoon '_TSP_' phi_naam];
%     opdracht=['a=AnalyseTSPSequence(' toplot ',0,10,15,0,''circ'');'];
%     eval(opdracht);
% elseif strcmp(method,'MLS')
%     %% MLS plot
%     toplot=[naam_telefoon '_MLS_' phi_naam];
%     opdracht=['a=AnalyseMLSSequence(' toplot ',0,10,15,''false'',0);'];
%     eval(opdracht);
%     a=fft(a);
% end

[l b]=size(a);
a_eq=zeros(l,b);

if strcmp(method,'MLS')
    load bestmic_MLS_090_analysed.mat bestmic_MLS_090_analysed_mean
    for i=1:b
        a_eq(:,i)=a(:,i)./bestmic_MLS_090_analysed_mean;
    end
elseif strcmp(method,'TSP')
    load bestmic_TSP_090_analysed.mat bestmic_TSP_090_analysed_mean
    for i=1:b
        a_eq(:,i)=a(:,i)./bestmic_TSP_090_analysed_mean;
    end
end

    a=a_eq;
    clear a_eq;

    Hz=Fs/length(a);
    
    a_dB=db(abs(a));
    a_dB=a_dB(1:round(end/2),:);
    a_dB=a_dB(round(y_as_min/Hz):round(y_as_max/Hz),:);
    [y_lang, x_lang]=size(a_dB);
    x=linspace(0,360,x_lang); % 0 to 360 graden, x samples
    y=linspace(y_as_min,y_as_max,length(a_dB)); % 10^-4 tot 10^4 kHz in length(b) samples

    figure;
    mesh(x,y,a_dB);
    view(2)
    axis([0 360 min(y) max(y)])
    xlabel('Angle in degrees');
    ylabel('Frequency in Hz')
    colorbar
    if strcmp(method,'TSP')
        caxis([-15 40])
    elseif strcmp(method, 'MLS')
        caxis([-15 15])
    end
    colormap jet
    titel=[method ' ' naam_telefoon ' at Elevation of \phi=' num2str(phi,'%d') ' equalized lineair'];
    title(titel);
    saveas(gcf,strcat(figdir,[naam_telefoon '_' method '_' phi_naam '_eq_lin']),'png');
    titel=[method ' ' naam_telefoon ' at Elevation of \phi=' num2str(phi,'%d') ' equalized logaritmic'];
    title(titel);
    set(gca,'YScale','log');
    saveas(gcf,strcat(figdir,[naam_telefoon '_' method '_' phi_naam '_eq_log']),'png');

%     a_dB=db(abs(a));
%     a_dB=a_dB(1:round(end/2),:);
%     a_dB=a_dB(3000:12000,:);
%     [y_lang, x_lang]=size(a_dB);
%     x=linspace(0,360,x_lang); % 0 to 360 graden, x samples
%     y=linspace(3000*1.5,12000*1.5)
%     %y=linspace(Fs/length(a),Fs/2,length(a_dB)); % 10^-4 tot 10^4 kHz in length(b) samples
% 
%     figure;
%     mesh(x,y,a_dB);
%     view(2)
%     axis([0 360 min(y) max(y)])
%     colorbar
%     colormap jet
%     set(gca,'YScale','log');
%     titel=['MLS ' naam_telefoon ' at Elevation of \phi=' num2str(phi,'%d')];
%     title(titel);
%     saveas(gcf,strcat(figdir,[naam_telefoon '_MLS_' phi_naam]),'png');

% %% save analysed
% assignin('base',[toplot '_analysed'],a);
% opdracht=['save ' toplot '_analysed.mat ' toplot '_analysed; clear ' toplot '_analysed;'];
% eval(opdracht);
close all;