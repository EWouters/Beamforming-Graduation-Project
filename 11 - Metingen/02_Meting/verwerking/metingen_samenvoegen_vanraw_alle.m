for welketelefoon=3:4
    if welketelefoon==1
        naam_telefoon='NX506';
    elseif welketelefoon==2
        naam_telefoon='NX501';
    elseif welketelefoon==3
        naam_telefoon='NX506FU';
    elseif welketelefoon==4
        naam_telefoon='NX506FD';
    end
    
    metingen_samenvoegen_vanraw
    
    clearvars -except welketelefoon w_jun w_mei
end