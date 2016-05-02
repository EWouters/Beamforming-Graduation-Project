%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Het maken van de volle bol met de meetresultaten voor een equiangular grid:
% Bol voor de sukkels #oeps, jwz
delta_theta=9;
delta_phi=8;

stap_theta=360/delta_theta + 2;
stap_phi=(2*72)/delta_phi;

theta=linspace(-4.5,360+4.5,stap_theta);
phi=[90 90-4.5 90-9-4.5 linspace(72-4,-(72-4),stap_phi) -(90-9-4.5) -(90-4.5) -90];

[Thetas,Phis]= ndgrid(deg2rad(theta),deg2rad(phi));
Rhos = 1;
[X,Y,Z] = sph2cart(Thetas,Phis,Rhos);
% surf(X,Y,Z);

clear i;
[l b]=size(Z);
C=i*ones(l-1, b-1);

%% C maken!

% invullen:
naam_telefoon='NX506';
%method='MLS';
freq=10e3;
%equalize=0;     %equalize=1 = AAN, =0 = UIT

Fs=48e3;

%% eenmalig uitvoeren:
phi_naam=['000';'009';'018';'026';'034';'042';'050';'058';'066';'074';'082';'090';'098';'106';'114';'122';'130';'138';'146';'154';'162';'171';'180'];

for i=1:length(phi_naam)
    opdracht=[naam_telefoon '_' phi_naam(i,:) '= matfile(''' naam_telefoon '_' phi_naam(i,:) '_irdB.mat'');'];
    eval(opdracht);
end

%% PLOT!
% de plotcode:
opdracht=['Hz=Fs/(length(' naam_telefoon '_' phi_naam(2,:) '.' naam_telefoon '_' phi_naam(2,:) '_irdB));'];
eval(opdracht);

index=round(freq/Hz);

a=-0.5;
% opdracht=['a=' naam_telefoon '_' phi_naam(1,:) '.' naam_telefoon '_' phi_naam(1,:) '_analysed(' num2str(index) ',1);'];
% eval(opdracht);
C(:,1)=a*ones(41,1);

% opdracht=['a=' naam_telefoon '_' phi_naam(23,:) '.' naam_telefoon '_' phi_naam(23,:) '_analysed(' num2str(index) ',1);'];
% eval(opdracht);
C(:,23)=a*ones(41,1);

for i=2:22
    opdracht=['a=' naam_telefoon '_' phi_naam(i,:) '.' naam_telefoon '_' phi_naam(i,:) '_irdB(' num2str(index) ',:);'];
    eval(opdracht);
    C(:,i)=a';
end

% C voorbeeld:
% C=[ones(41,1) 2*ones(41,1) 3*ones(41,1) 4*ones(41,1) 5*ones(41,1) 6*ones(41,1) 7*ones(41,1) 8*ones(41,1) 9*ones(41,1) 10*ones(41,1) 11*ones(41,1) 12*ones(41,1) 13*ones(41,1) 14*ones(41,1) 15*ones(41,1) 16*ones(41,1) 17*ones(41,1) 18*ones(41,1) 19*ones(41,1) 20*ones(41,1) 21*ones(41,1) 22*ones(41,1) 23*ones(41,1) 24*ones(41,1)];

hs = surf(X,Y,Z,C);
zlabel('Screen up -->', 'FontSize', 14)

%view van links
titel=[naam_telefoon ' Frequency\approx' num2str(freq) ' Hz, from the left'];
title(titel);
view([0 0])
xlabel('<-- Listeningside   ||   Speechside -->', 'FontSize', 14)

%view van rechts
titel=[naam_telefoon ' Frequency\approx' num2str(freq) ' Hz, from the right'];
title(titel);
xlabel('<-- Speechside   ||   Listeningside -->', 'FontSize', 14)
view([180 0]) 

h = colorbar;
%caxis([min(C_dB(:)) max(C_dB(:))])
caxis([-30 10])
set(get(h,'title'),'string','Gain in dB');

colormap jet
shading flat