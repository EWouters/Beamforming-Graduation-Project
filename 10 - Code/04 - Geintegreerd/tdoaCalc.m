function tdoa = tdoaCalc(locations,c) % locations [x y z]

distances = distcalc(locations(1,:), locations(2:end,:)); % dist from source to mic 

    for ii = 1 : length(locations)-1
        tdoa(ii) = distances(ii)/c;
    end

end

function D=distcalc(Mpos,Lpos)
    % DISTCAL Binary distance calculator for valid device matrices.
    % Author: dr. Jorge Martinez (J.A.MartinezCastaneda@TuDelft.nl)

    M=size(Mpos,1);
    L=size(Lpos,1);

    dotprods=Lpos*Mpos.';
    Lsqrprods=diag(Lpos*Lpos.');
    Msqrprods=diag(Mpos*Mpos.').';
    D=(repmat(Lsqrprods,1,M)+repmat(Msqrprods,L,1)-(2.*dotprods)).^0.5;
end