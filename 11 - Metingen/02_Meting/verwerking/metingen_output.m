%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Voorheen, met de oude metingen
[Thetas,Phis]= ndgrid(linspace(-pi/45,2*pi+pi/45,45),deg2rad(linspace(-7.5,67.5,6)));
Rhos = ones(size(Thetas));
[X,Y,Z] = sph2cart(Thetas,Phis,Rhos);
C = ones(size(Z));
surf(X,Y,Z,C);

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Het maken van de volle bol met de meetresultaten voor een equiangular grid:
delta_theta=9;
delta_phi=delta_theta;

stap_theta=360/delta_theta + 2;
stap_phi=180/delta_phi;

theta=linspace(-4.5,360+4.5,stap_theta);
phi=[90 linspace(90-4.5,-(90-4.5),stap_phi) -90];

[Thetas,Phis]= ndgrid(deg2rad(theta),deg2rad(phi));
Rhos = 1;
[X,Y,Z] = sph2cart(Thetas,Phis,Rhos);
surf(X,Y,Z);

C=ones(size(Z));
C=[ones(41,1) 2*ones(41,1) 3*ones(41,1) 4*ones(41,1) 5*ones(41,1) 6*ones(41,1) 7*ones(41,1) 8*ones(41,1) 9*ones(41,1) 10*ones(41,1) 11*ones(41,1) 12*ones(41,1) 13*ones(41,1) 14*ones(41,1) 15*ones(41,1) 16*ones(41,1) 17*ones(41,1) 18*ones(41,1) 19*ones(41,1) 20*ones(41,1) 21*ones(41,1)];
surf(X,Y,Z,C);

% % het samenstellen van plot resultaat
% input=1;
% freq=input;
% resultaat=[VULIN_90_dB(input)*ones(41,1) VULIN_81_dB(input,:)' VULIN_72_dB(input,:)' VULIN_63_dB(input,:)' VULIN_54_dB(input,:)' VULIN_45_dB(input,:)' VULIN_36_dB(input,:)' VULIN_27_dB(input,:)' VULIN_18_dB(input,:)' VULIN_9_dB(input,:)' VULIN_0_dB(input,:)' VULIN_min9_dB(input,:)' VULIN_min18_dB(input,:)' VULIN_min18_dB(input,:)' VULIN_min36_dB(input,:)' VULIN_min45_dB(input,:)' VULIN_min54_dB(input,:)' VULIN_min63_dB(input,:)' VULIN_min72_dB(input,:)' VULIN_min81_dB(input,:)' VULIN_min90_dB(input)*ones(41,1)];
% % kan waarschijnlijk slimmer met multidimensional arrays http://nl.mathworks.com/help/matlab/math/multidimensional-arrays.html
% 
% surf(X,Y,Z,resultaat);
% shading flat

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Het maken van een bol van phi=[0,135] graden (tafeltje)
theta=linspace(-4.5,360+4.5,stap_theta);
phi=[90 linspace(90-4.5,-(45+4.5),stap_phi)];

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
naam_telefoon='NX506FU';
method='MLS';
freq=8e3;
equalize=0;     %equalize=1 = AAN, =0 = UIT

Fs=48e3;

% eenmalig uitvoeren:
phi_naam=['000';'009';'018';'027';'036';'045';'054';'063';'072';'081';'090';'099';'108';'117';'126';'135'];

opdracht=['bestmic_' method '= matfile(''bestmic_' method '_090_analysed.mat'');'];
eval(opdracht);

for i=1:length(phi_naam)
    opdracht=[naam_telefoon '_' method '_' phi_naam(i,:) '= matfile(''' naam_telefoon '_' method '_' phi_naam(i,:) '_analysed.mat'');'];
    eval(opdracht);
end

% het samenstellen van plot resultaat
input=1;
freq=input;
resultaat=[VULIN_90_dB(input)*ones(41,1) VULIN_81_dB(input,:)' VULIN_72_dB(input,:)' VULIN_63_dB(input,:)' VULIN_54_dB(input,:)' VULIN_45_dB(input,:)' VULIN_36_dB(input,:)' VULIN_27_dB(input,:)' VULIN_18_dB(input,:)' VULIN_9_dB(input,:)' VULIN_0_dB(input,:)' VULIN_min9_dB(input,:)' VULIN_min18_dB(input,:)' VULIN_min18_dB(input,:)' VULIN_min36_dB(input,:)' VULIN_min45_dB(input,:)'];
% kan waarschijnlijk slimmer met multidimensional arrays http://nl.mathworks.com/help/matlab/math/multidimensional-arrays.html

surf(X,Y,Z,resultaat);
shading flat

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
method='MLS';
freq=8e3;
equalize=1;     %equalize=1 = AAN, =0 = UIT

Fs=48e3;

% eenmalig uitvoeren:
phi_naam=['000';'009';'018';'026';'034';'042';'050';'058';'066';'074';'082';'090';'098';'106';'114';'122';'130';'138';'146';'154';'162';'171';'180'];

opdracht=['bestmic_' method '= matfile(''bestmic_' method '_090_analysed.mat'');'];
eval(opdracht);

for i=1:23
    opdracht=[naam_telefoon '_' method '_' phi_naam(i,:) '= matfile(''' naam_telefoon '_' method '_' phi_naam(i,:) '_analysed.mat'');'];
    eval(opdracht);
end

%% PLOT!
% de plotcode:
opdracht=['Hz=Fs/(length(' naam_telefoon '_' method '_' phi_naam(i,:) '.' naam_telefoon '_' method '_' phi_naam(i,:) '_analysed));']
eval(opdracht);

index=round(freq/Hz);

if(equalize)
    opdracht=['eq=bestmic_' method '.bestmic_' method '_090_analysed_mean(' num2str(index) ',1);'];
    eval(opdracht);
else
    eq=1;
end

opdracht=['a=' naam_telefoon '_' method '_' phi_naam(1,:) '.' naam_telefoon '_' method '_' phi_naam(1,:) '_analysed(' num2str(index) ',1)'];
eval(opdracht);
C(:,1)=a/eq*ones(41,1);

opdracht=['a=' naam_telefoon '_' method '_' phi_naam(23,:) '.' naam_telefoon '_' method '_' phi_naam(23,:) '_analysed(' num2str(index) ',1)'];
eval(opdracht);
C(:,23)=a/eq*ones(41,1);

for i=2:22
    opdracht=['a=' naam_telefoon '_' method '_' phi_naam(i,:) '.' naam_telefoon '_' method '_' phi_naam(i,:) '_analysed(' num2str(index) ',:);'];
    eval(opdracht);
    C(:,i)=(1/eq)*a';
end

% C voorbeeld:
% C=[ones(41,1) 2*ones(41,1) 3*ones(41,1) 4*ones(41,1) 5*ones(41,1) 6*ones(41,1) 7*ones(41,1) 8*ones(41,1) 9*ones(41,1) 10*ones(41,1) 11*ones(41,1) 12*ones(41,1) 13*ones(41,1) 14*ones(41,1) 15*ones(41,1) 16*ones(41,1) 17*ones(41,1) 18*ones(41,1) 19*ones(41,1) 20*ones(41,1) 21*ones(41,1) 22*ones(41,1) 23*ones(41,1) 24*ones(41,1)];
C_dB=db(abs(C));
surf(X,Y,Z,C_dB);
if(equalize)
    titel=[method ' equalized Frequency\approx' num2str(freq)];
else
    titel=[method ' Frequency\approx' num2str(freq)];
end
title(titel);

h = colorbar;
%caxis([min(C_dB(:)) max(C_dB(:))])
caxis([4 max(C_dB(:))])

colormap jet
shading flat