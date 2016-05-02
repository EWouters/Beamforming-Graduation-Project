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

if strcmp(method,'TSP')
    %% TSP plot
    toplot=[naam_telefoon '_TSP_' phi_naam];
    opdracht=['a=AnalyseTSPSequence(' toplot ',0,10,15,0,''circ'');'];
    eval(opdracht);
elseif strcmp(method,'MLS')
    %% MLS plot
    toplot=[naam_telefoon '_MLS_' phi_naam];
    opdracht=['a=AnalyseMLSSequence(' toplot ',0,10,15,''false'',0);'];
    eval(opdracht);
end
    
    a=fft(a);
    
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
    h=colorbar;
    caxis([-55 -24])
    set(get(h,'title'),'string','Gain in dB');
    colormap jet
    titel=[method ' ' naam_telefoon ' at Elevation of \phi=' num2str(phi,'%d') ' linear'];
    title(titel);
    opslaan_als=[naam_telefoon '_' method '_' phi_naam '_lin'];
    %matlab2tikz('filename',[opslaan_als '.tikz']);
    saveas(gcf,strcat(figdir,opslaan_als),'png');
    titel=[method ' ' naam_telefoon ' at Elevation of \phi=' num2str(phi,'%d') ' logaritmic'];
    title(titel);
    set(gca,'YScale','log');
    opslaan_als=[naam_telefoon '_' method '_' phi_naam '_log'];
    %matlab2tikz('filename',[opslaan_als '.tikz']);
    saveas(gcf,strcat(figdir,opslaan_als),'png');
    
    if jun==1
        w=w_jun;
    else
        w=w_mei;
    end
    
    if equalize && strcmp(method,'TSP')
        b_dB=db(abs(a));
        b_dB=b_dB(1:round(end/2),:);
        w_use=w;
        %w_use=[mean(w)*ones(round(length(w)/3),1); w(round(length(w)/3)+1:end)];
        b_dB=b_dB+w_use*ones(1,41)-mean(w_use);
        b_dB=b_dB+30.198435620833777;
        
        b=make_equalized(a,w_use, round(y_as_min/Hz),round(y_as_max/Hz));
        assignin('base',[naam_telefoon '_ir'],b);
        opdracht=['save ' naam_telefoon '_ir.mat ' naam_telefoon '_ir; clear ' naam_telefoon '_ir;'];
        eval(opdracht);
        
        b_dB=b_dB(round(y_as_min/Hz):round(y_as_max/Hz),:);
        [y_lang, x_lang]=size(b_dB);
        x=linspace(0,360,x_lang); % 0 to 360 graden, x samples
        y=linspace(y_as_min,y_as_max,length(b_dB)); % 10^-4 tot 10^4 kHz in length(b) samples

        figure;
        mesh(x,y,b_dB);
        view(2)
        axis([0 360 min(y) max(y)])
        xlabel('Angle in degrees');
        ylabel('Frequency in Hz')
        h=colorbar;
        caxis([-30 10])
        set(get(h,'title'),'string','Gain in dB');
        colormap jet
        titel=[method ' ' naam_telefoon ' at Elevation of \phi=' num2str(phi,'%d') ' linear, equalized'];
        title(titel);
        opslaan_als=[naam_telefoon '_' method '_' phi_naam '_lin_eq'];
        %matlab2tikz('filename',[opslaan_als '.tikz']);
        saveas(gcf,strcat(figdir,opslaan_als),'png');
        titel=[method ' ' naam_telefoon ' at Elevation of \phi=' num2str(phi,'%d') ' logaritmic, equalized'];
        title(titel);
        set(gca,'YScale','log');
        opslaan_als=[naam_telefoon '_' method '_' phi_naam '_log_eq'];
        %matlab2tikz('filename',[opslaan_als '.tikz']);
        saveas(gcf,strcat(figdir,opslaan_als),'png');
    end
    
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

%% save analysed
a=ifft(a,'symmetric');
assignin('base',[toplot '_analysed'],a);
opdracht=['save ' toplot '_analysed.mat ' toplot '_analysed; clear ' toplot '_analysed;'];
eval(opdracht);


close all;