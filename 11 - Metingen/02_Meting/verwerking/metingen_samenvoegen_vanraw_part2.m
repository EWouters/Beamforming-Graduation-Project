% Metingen directivities, zoals beschreven in het meetplan
% Meten in de phi-richting over stappen van negen graden
% Meten in de theta-richting over stappen van negen graden
% Op de polen (phi=0 / pi) wordt slechts een meting verricht

% stel in:
% naam_telefoon='NX501';
% method='MLS';       % methode
% phi=122;            % graden vanaf de z-as
stap=9;             % stapgrootte

if strcmp(method,'TSP')
    grens=20/2^15;
elseif strcmp(method,'MLS')
    grens=40/2^15;
end

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

langste=0;
metingen=0;

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
    
    opdracht=['load ' naam_mat_file '.mat ' naam];
    eval(opdracht);
    
    opdracht=['output=' naam ';'];
    eval(opdracht);
    
    if jun==0
        output=double(output)/2^15;
    end
    output=output(5e3:end);
    
    nietnul_voor=min(find((abs(output)>grens),1,'first'))-1e3;
    if nietnul_voor<1
        nietnul_voor=1;
    end
    
    nietnul_na=min(find((abs(output)>grens),1,'last'))+3e3;
    if nietnul_na>length(output)
        nietnul_na=length(output);
    end
    output=output(nietnul_voor:nietnul_na);
    
    lengte_output=length(output);
    if lengte_output>langste
        langste=lengte_output;
    end
    metingen=metingen+1;
    
    %figure;
    %plot(output);
    %title(naam);
    
    opdracht=['clear ' naam];
    eval(opdracht);
    
    naam=[naam '_clean'];
    
    assignin('base',naam,output);
    clear output;
    
    theta=theta+stap;
end;

naam_matrix=[naam_telefoon '_' method '_' phi_naam];
opdracht=['output=zeros(' num2str(langste) ',' num2str(metingen) ');'];
pause(0.02);
eval(opdracht);

i=1;

% reset theta
theta=0;
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
        
    naam=[naam_telefoon '_' method '_' phi_naam '_' theta_naam '_clean'];
    opdracht=['hulp=' naam '; clear ' naam];
    eval(opdracht);
    
    if length(hulp)<langste
        hulp=[hulp;zeros(langste-length(hulp),1)];
    end
    
    output(:,i)=hulp;
    i=i+1;
    theta=theta+stap;
end;

assignin('base',naam_matrix,output);
clear output;

opdracht=['save ' naam_matrix '.mat ' naam_matrix ';'];
%eval(opdracht);

theta=0;
plot_elevation_vanraw_save_equalized

opdracht=['clear ' naam_matrix];
eval(opdracht);