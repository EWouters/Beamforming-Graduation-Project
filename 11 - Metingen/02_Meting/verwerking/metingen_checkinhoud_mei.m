% Metingen directivities, zoals beschreven in het meetplan
% Meten in de phi-richting over stappen van negen graden
% Meten in de theta-richting over stappen van negen graden
% Op de polen (phi=0 / pi) wordt slechts een meting verricht

% stel in:
naam_telefoon='NX501';
method='MLS';       % methode
phi=122;            % graden vanaf de z-as
stap=9;             % stapgrootte
grens=50/2^15;      % grens knippen

close all;

%afblijven
theta=0;            % graden vanaf de x-as

if phi<100
    if phi<10
        phi_naam=num2str(phi,'00%d');
    else
        phi_naam=num2str(phi,'0%d');
    end
else
    phi_naam=num2str(phi,'%d');
end

while theta<361
    
    if theta<100
        if theta<10
            theta_naam=num2str(theta,'00%d');
        else
            theta_naam=num2str(theta,'0%d');
        end
    else
        theta_naam=num2str(theta,'%d');
    end
        
    naam=[naam_telefoon '_' method '_' phi_naam '_' theta_naam];
    figure;
    opdracht=['plot(' naam ');'];
    eval(opdracht);
    titel=[phi_naam theta_naam];
    title(titel);
    
    theta=theta+stap;
end;

close all;