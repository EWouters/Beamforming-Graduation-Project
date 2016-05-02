naam_telefoon='NX506';

for phi=[9 18 26 34 42 50 58 66 74 82 90 98 106 114 122 130 138 146 154 162 171]

if phi<100
    if phi<10
        naam_phi=num2str(phi,'00%d');
    else
        naam_phi=num2str(phi,'0%d');
    end
else
    naam_phi=num2str(phi,'%d');
end

opdracht=['load ' naam_telefoon '_' naam_phi '_ir.mat'];
eval(opdracht);

for i=1:41
    theta=(i-1)*9;
    
    if theta<100
        if theta<10
            theta_naam=num2str(theta,'00%d');
        else
            theta_naam=num2str(theta,'0%d');
        end
    else
        theta_naam=num2str(theta,'%d');
    end
    
    opdracht=['a=' naam_telefoon '_' naam_phi '_ir(:,' num2str(i) ');'];
    eval(opdracht);
    
    opdracht=[naam_telefoon '_' naam_phi '_' theta_naam '=a;'];
    eval(opdracht);
    
    if i==1
        opdracht=['save(''' naam_telefoon '_' naam_phi '.mat'',''' naam_telefoon '_' naam_phi '_' theta_naam ''');'];
    else
        opdracht=['save(''' naam_telefoon '_' naam_phi '.mat'',''' naam_telefoon '_' naam_phi '_' theta_naam ''',''-append'');'];
    end
    eval(opdracht);
end

end