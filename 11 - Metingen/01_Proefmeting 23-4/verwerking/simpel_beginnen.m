% simpel beginnen
[Thetas,Phis] = ndgrid(linspace(0,pi,90),linspace(0,pi,180));
Rhos = ones(size(Thetas));
[X,Y,Z] = sph2cart(Thetas,Phis,Rhos);
C = Thetas;
surf(X,Y,Z,C)
shading flat;

[Thetas,Phis]= ndgrid(linspace(0,2*pi,45),deg2rad([0 15 30 45 60]));
Rhos = ones(size(Thetas));
[X,Y,Z] = sph2cart(Thetas,Phis,Rhos);
C = [TSP_0_dB(1,:)' TSP_15_dB(1,:)' TSP_30_dB(1,:)' TSP_45_dB(1,:)' TSP_60_dB(1,:)'];
surf(X,Y,Z,C)
%shading flat;
shading interp