%uitgebreid grid
[Thetas,Phis]= ndgrid(deg2rad(linspace(-2,362,89)),deg2rad(linspace(-15/4,60+15/4,10)));
Rhos = ones(size(Thetas));
[X,Y,Z] = sph2cart(Thetas,Phis,Rhos);

freq=100;

%uitbreiden data
C_init = [TSP_0_dB(freq,:)' TSP_15_dB(freq,:)' TSP_30_dB(freq,:)' TSP_45_dB(freq,:)' TSP_60_dB(freq,:)'];
[kolom,rij]=size(Z);
C=zeros(kolom,rij-1);
for i=1:rij
    for j=1:kolom
        if mod(j,2)==1
            if mod(i,2)==1
                %C(j,i)=C_init((j+1)/2,(i+1)/2);
                C(j,i)=C_init((j+1)/2,(i+1)/2); %als functie van dB
            end
        end
    end
end

for i=1:rij
    for j=1:kolom
        if mod(j,2)==0 && mod(i,2)==1
            %C(j,i)=0.5*(C(j+1,i)+C(j-1,i));
            C(j,i)=db((db2mag(C(j+1,i))+db2mag(C(j-1,i)))/2); %als functie van dB
        end
    end
end

for i=1:rij-1
    for j=1:kolom
        if mod(i,2)==0
            %C(j,i)=0.5*(C(j,i+1)+C(j,i-1));
            C(j,i)=db((db2mag(C(j,i+1))+db2mag(C(j,i-1)))/2); %als functie van dB
        end
    end
end

figure
fig=surf(X,Y,Z,C);
axis([-1 1 -1 1 -1 1]);
shading flat;
%shading interp;
colorbar;
title('De gain voor een frequentie van 1 Hz');