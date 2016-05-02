azimuth=[linspace(0,2*pi,45) linspace(0,2*pi,45) linspace(0,2*pi,45) linspace(0,2*pi,45) linspace(0,2*pi,45)];
elevation=deg2rad([zeros(1,45) 15*ones(1,45) 30*ones(1,45) 45*ones(1,45) 60*ones(1,45)]);
r=1;
[x, y, z]=sph2cart(azimuth,elevation,r);
data=[TSP_0_dB TSP_15_dB TSP_30_dB TSP_45_dB TSP_60_dB];

fig = scatter3(x,y,z,100,data(1,:),'filled');
colorbar;
title('De gain voor een frequentie van 1 Hz');
while(1)
    prompt = 'Stoppen? 1=ja, 0=nee ';
    stop = input(prompt);
    if stop==1
        break;
    else
        prompt = 'Welke frequentie? [1-16384] ';
        f = round(input(prompt));
        if f<16384 && f>0
            fig = scatter3(x,y,z,100,data(f,:),'filled');
            colorbar;
            str = sprintf('De gain voor een frequentie van %i Hz',f);
            title(str);
        else
            break;
        end
    end
end