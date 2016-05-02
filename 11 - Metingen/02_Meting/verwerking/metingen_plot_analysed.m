% vanuit metingen_samenvoegen_vanraw

% Metingen directivities, zoals beschreven in het meetplan
% Meten in de phi-richting over stappen van negen graden
% Meten in de theta-richting over stappen van negen graden
% Op de polen (phi=0 / pi) wordt slechts een meting verricht

% stel in:
naam_telefoon='NX506FD';
% method='MLS';       % methode
% phi=122;            % graden vanaf de z-as
% stap=9;             % stapgrootte

methods=['MLS';'TSP'];
% Stap=9;             % stapgrootte
% Phi_max=Phi;

%% automatisch doorlopen alle matfiles
Phi=83;
while Phi<96;

    if Phi<100
        if Phi<10
            Phi_naam=num2str(Phi,'00%d');
        else
            Phi_naam=num2str(Phi,'0%d');
        end
    else
        Phi_naam=num2str(Phi,'%d');
    end

    naam_mat_file=[naam_telefoon '_' Phi_naam '_raw'];
    opdracht=['matObj=matfile(''' naam_mat_file '.mat'');'];
    eval(opdracht);
    
    for i=1:2
        method=methods(i,:);
    
        % THETA BEPALEN
        Theta=0;
        nietleeg=0;
        while Theta<361
            if Theta<100
                if Theta<10
                    Theta_naam=num2str(Theta,'00%d');
                else
                    Theta_naam=num2str(Theta,'0%d');
                end
            else
                Theta_naam=num2str(Theta,'%d');
            end

            naam_vector=[ naam_telefoon '_' method '_' Phi_naam '_' Theta_naam];

            opdracht=['leeg=isempty(whos(matObj,''' naam_vector '''));'];
            eval(opdracht);
            if (leeg == 0)
                % naam_vector
                nietleeg=nietleeg+1;
                % doe dan het knipscriptje
                if Phi>0 && Phi<180
                    phi=Phi;
                    load([naam_telefoon '_' method '_' Phi_naam '_analysed.mat']);
                    opdracht=['a=(1/0.55)*' naam_telefoon '_' method '_' Phi_naam '_analysed; clear ' naam_telefoon '_' method '_' Phi_naam '_analysed'];
                    eval(opdracht);
                    % plot_elevation_vananalysed
                    plot_elevation_equalized
                end
            end
            Theta=Theta+361;
        end
    end
    Phi=Phi+1;
end