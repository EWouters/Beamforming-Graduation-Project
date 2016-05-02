% phi 0 9 18 en dan met stappen van 8 tot 162 171 180
 phi = [0 9 18 26:8:162 171 180];

 % theta van 0 tot 360
 theta = [0:9:360]; 
 
for i=1:length(phi)
    for j=1:length(theta)
        Phi=phi(i);
        Theta=theta(j);
        
        if Theta<100
           if Theta<10
              Theta_naam=num2str(Theta,'00%d');
           else
              Theta_naam=num2str(Theta,'0%d');
           end
        else
           Theta_naam=num2str(Theta,'%d');
        end
        
        if Phi<100
           if Phi<10
              Phi_naam=num2str(Phi,'00%d');
           else
              Phi_naam=num2str(Phi,'0%d');
           end
        else
           Phi_naam=num2str(Phi,'%d');
        end
        
        naam=['telefoon_' Phi_naam '_' Theta_naam];
        opdracht=[naam '=h;'];
        eval(opdracht);
        
        opdracht=['save directivity.mat ' naam ' -append'];
        eval(opdracht);
    end
    
end
