%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Het maken van een bol van phi=[0,135] graden (tafeltje)
theta=linspace(0,360,41);
phi=linspace(-90,90,21);

[Thetas,Phis]= ndgrid(deg2rad(theta),deg2rad(phi));
Rhos = 1;
[X,Y,Z] = sph2cart(Thetas,Phis,Rhos);
surf(X,Y,Z);

[l b]=size(Z);
C=zeros([l-1 b-1]);
% C=[ones(41,1) 2*ones(41,1) 3*ones(41,1) 4*ones(41,1) 5*ones(41,1) 6*ones(41,1) 7*ones(41,1) 8*ones(41,1) 9*ones(41,1) 10*ones(41,1) 11*ones(41,1) 12*ones(41,1) 13*ones(41,1) 14*ones(41,1) 15*ones(41,1) 16*ones(41,1) 17*ones(41,1) 18*ones(41,1) 19*ones(41,1) 20*ones(41,1) 21*ones(41,1)];
% surf(X,Y,Z,C);

%% C maken!

% invullen:
naam_telefoon='NX501';
%method='MLS';
freq=10e3;

Fs=48e3;

% eenmalig uitvoeren:
% phi_naam=['000';'009';'018';'027';'036';'045';'054';'063';'072';'081';'090'];
% 
% for i=1:length(phi_naam)
%     opdracht=[naam_telefoon '_' phi_naam(i,:) '= matfile(''' naam_telefoon '_' phi_naam(i,:) '_irdB.mat'');'];
%     eval(opdracht);
% end

%% PLOT!
% de plotcode:
% opdracht=['Hz=Fs/(length(' naam_telefoon '_' phi_naam(i,:) '.' naam_telefoon '_' phi_naam(i,:) '_irdB));'];
% eval(opdracht);
% 
% index=round(freq/Hz);
% 
% %opdracht=['a=' naam_telefoon '_' phi_naam(1,:) '.' naam_telefoon '_' phi_naam(1,:) '_irdB(' num2str(index) ',1);'];
% %eval(opdracht);
% a=1;
% 
% for i=2:length(phi_naam)
%     opdracht=['a=' naam_telefoon '_' phi_naam(i,:) '.' naam_telefoon '_' phi_naam(i,:) '_irdB(' num2str(index) ',:);'];
%     eval(opdracht);
%     C(:,i)=a';
% end

% C voorbeeld:
%C=[ones(41,1) 2*ones(41,1) 3*ones(41,1) 4*ones(41,1) 5*ones(41,1) 6*ones(41,1) 7*ones(41,1) 8*ones(41,1) 9*ones(41,1) 10*ones(41,1) 11*ones(41,1) 12*ones(41,1) 13*ones(41,1) 14*ones(41,1) 15*ones(41,1) 16*ones(41,1) 17*ones(41,1) 18*ones(41,1) 19*ones(41,1) 20*ones(41,1) 21*ones(41,1) 22*ones(41,1) 23*ones(41,1) 24*ones(41,1)];
C=ones(size(Z));
surf(X,Y,Z,C);
% zlabel('Screen up -->', 'FontSize', 14)

%view van links
% titel=[naam_telefoon ' Frequency\approx' num2str(freq) ' Hz, from the left'];
% title(titel);
% view([0 0])
% xlabel('<-- Listeningside   ||   Speechside -->', 'FontSize', 14)
% 
% %view van rechts
% titel=[naam_telefoon ' Frequency\approx' num2str(freq) ' Hz, from the right'];
% title(titel);
% xlabel('<-- Speechside   ||   Listeningside -->', 'FontSize', 14)
% view([180 0]) 

h = colorbar;
% caxis([min(C_dB(:)) max(C_dB(:))])
caxis([-30 0])
set(get(h,'title'),'string','Gain in dB');

colormap gray
%shading flat