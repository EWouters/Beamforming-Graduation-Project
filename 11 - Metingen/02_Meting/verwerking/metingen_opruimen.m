naam_telefoon='NX501';
Phi=81;            % graden vanaf de z-as

methods=['MLS';'TSP'];
Stap=9;             % stapgrootte theta
PhiStap=9;
Phi_max=90;

while Phi<Phi_max+1;

    if Phi<100
        if Phi<10
            Phi_naam=num2str(Phi,'00%d');
        else
            Phi_naam=num2str(Phi,'0%d');
        end
    else
        Phi_naam=num2str(Phi,'%d');
    end

    naam_mat_file=[naam_telefoon '_' Phi_naam];
    opdracht=['load(''' naam_mat_file '.mat'');'];
    eval(opdracht);

    for i=1:2
        method=methods(i,:);
        Theta=0;
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

            naam_vector=[naam_telefoon '_' method '_' Phi_naam '_' Theta_naam];
            if Theta==0 && i==1
                opdracht=['save ' naam_mat_file '_raw.mat ' naam_vector];
            else
                opdracht=['save ' naam_mat_file '_raw.mat ' naam_vector ' -append'];
            end
            eval(opdracht);
            
            opdracht=['clear ' naam_vector '; clear ' naam_vector '_clean'];
            eval(opdracht);
            Theta=Theta+Stap;
        end;
        opdracht=['clear ' naam_telefoon '_' method '_' Phi_naam];
        eval(opdracht);
    end
    Phi=Phi+PhiStap;
end

clear all;
clc
h = msgbox('Opgeruimd!','Opgeruimd!');