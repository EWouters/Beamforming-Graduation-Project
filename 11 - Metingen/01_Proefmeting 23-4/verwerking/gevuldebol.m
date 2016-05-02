figure
[Thetas,Phis]= ndgrid(linspace(-pi/45,2*pi+pi/45,45),deg2rad(linspace(-7.5,67.5,6)));
Rhos = ones(size(Thetas));
[X,Y,Z] = sph2cart(Thetas,Phis,Rhos);
freq=7000;
C = [TSP_0_dB(freq,:)' TSP_15_dB(freq,:)' TSP_30_dB(freq,:)' TSP_45_dB(freq,:)' TSP_60_dB(freq,:)'];
fig=surf(X,Y,Z,C);
shading flat;
%shading interp;
colorbar;
title('De gain voor een frequentie van 1 Hz');
view(2)

% fs = sample freq
% Each bin frequency is separated by fs/N Hertz
% https://dadorran.wordpress.com/2014/02/20/plotting-frequency-spectrum-using-matlab/


% while(1)
%     prompt = 'Stoppen? 1=ja, 0=nee ';
%     stop = input(prompt);
%     if stop==1
%         break;
%     else
%         prompt = 'Welke frequentie? [1-16384] ';
%         f = round(input(prompt));
%         if f<16384 && f>0
%             fig = scatter3(x,y,z,100,data(f,:),'filled');
%             colorbar;
%             str = sprintf('De gain voor een frequentie van %i Hz',f);
%             title(str);
%         else
%             break;
%         end
%     end
% end