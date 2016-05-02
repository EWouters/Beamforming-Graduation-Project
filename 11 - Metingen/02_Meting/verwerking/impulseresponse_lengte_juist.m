function output=impulseresponse_lengte_juist(vector,lengte)
    %% definities
    turn=0;

    %% controleren of het een liggende of een staande vector is
    [lang breed]=size(vector);
    if lang<breed
        turn=1;
        vector=vector';
    end
    
    %% knippen in impulse responsie
    [max_value max_place]=max(abs(vector));
    clear max_value;
    if max_place>lengte+25
        output=vector(max_place-lengte-25:end);
        nullen=zeros(length(vector)-length(output),1);
        output=[output; nullen];
    else
        output=vector;
    end
    
    %% terugdraaien als nodig
    if turn==1
        output=output';
    end
end