% Metingen directivities, zoals beschreven in het meetplan
% Meten in de phi-richting over stappen van negen graden
% Meten in de theta-richting over stappen van negen graden
% Op de polen (phi=0 / pi) wordt slechts een meting verricht

% stel in:
naam_telefoons=['CHINAt';'CHINAb'];
methods=['MLS';'TSP'];       % methode
% phi=122;            % graden vanaf de z-as
stap=9;             % stapgrootte

close all;

for i=1:2
    naam_telefoon=naam_telefoons(i,:);
    for j=1:2
        method=methods(i,:);

%afblijven
if strcmp(method,'TSP')
    grens=20/2^15;
elseif strcmp(method,'MLS')
    grens=50/2^15;
end

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

next=0;
prompt='Gezien? ja=1 opnieuw=0';
next=input(prompt);
if next==0
    j=j-1;
end

close all;

    end
end