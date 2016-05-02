naam_telefoon='NX501';
Phi=81;            % graden vanaf de z-as

methods=['MLS';'TSP'];
Stap=9;             % stapgrootte
Phi_max=81;

while Phi<Phi_max+1;
Phi
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
            
            if Phi_naam=='090'
                Phi_naam_nieuw='090';
            elseif Phi_naam=='099'
                Phi_naam_nieuw='098';
            elseif Phi_naam=='081'
                Phi_naam_nieuw='072';%Phi_naam_nieuw='082';
            elseif Phi_naam=='072'
                Phi_naam_nieuw='074';
            elseif Phi_naam=='108'
                Phi_naam_nieuw='106';
            elseif Phi_naam=='063'
                Phi_naam_nieuw='066';
            elseif Phi_naam=='117'
                Phi_naam_nieuw='114';
            elseif Phi_naam=='054'
                Phi_naam_nieuw='058';
            elseif Phi_naam=='126'
                Phi_naam_nieuw='122';
            elseif Phi_naam=='045'
                Phi_naam_nieuw='050';
            elseif Phi_naam=='135'
                Phi_naam_nieuw='130';
            elseif Phi_naam=='036'
                Phi_naam_nieuw='042';
            elseif Phi_naam=='144'
                Phi_naam_nieuw='138';
            elseif Phi_naam=='027'
                Phi_naam_nieuw='034';
            elseif Phi_naam=='153'
                Phi_naam_nieuw='146';
            elseif Phi_naam=='018'
                Phi_naam_nieuw='026';
            else
                Phi_naam_nieuw=0;
                h = msgbox('Error','Error');
            end;
            naam_mat_file=[naam_telefoon '_' Phi_naam_nieuw];
            
            naam_vector=[naam_telefoon '_' method '_' Phi_naam '_' Theta_naam];
            naam_vector_nieuw=[naam_telefoon '_' method '_' Phi_naam_nieuw '_' Theta_naam];
            
            opdracht=['assignin(''base'',''' naam_vector_nieuw ''',' naam_vector ');'];
            eval(opdracht);
            
            if Theta==0 && i==1
                opdracht=['save ' naam_mat_file '_raw.mat ' naam_vector_nieuw];
            else
                opdracht=['save ' naam_mat_file '_raw.mat ' naam_vector_nieuw ' -append'];
            end
            eval(opdracht);
            
            opdracht=['clear ' naam_vector_nieuw '; clear ' naam_vector '; clear ' naam_vector '_clean'];
            eval(opdracht);
            Theta=Theta+Stap;
        end;
        opdracht=['clear ' naam_telefoon '_' method '_' Phi_naam];
        eval(opdracht);
    end
    Phi=Phi+Stap;
end

clear all;
clc
h = msgbox('Opgeruimd!','Opgeruimd!');