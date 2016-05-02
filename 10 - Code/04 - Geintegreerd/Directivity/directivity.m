function [ir, theta, phi, radius] = directivity(phone_pos,source_pos)

    %% toepassen elevation en azimuth telefoon

    % Face up or face down
    if phone_pos(6)~=1
        %hij ligt op zijn kop, dus het hele verhaal spiegelen in de z-as!
        source_pos(3)=-source_pos(3);
    end

    [theta,phi,radius]=direction(phone_pos,source_pos);
    % nieuwe source_pos

    if phone_pos(4)~=0 && phone_pos(4)~=0
        theta=theta+phone_pos(4);
        phi=phi+phone_pos(5);

        source_pos(1)=radius*sin(phi)*cos(theta);
        source_pos(2)=radius*sin(phi)*sin(theta);
        source_pos(3)=radius*cos(phi);

        [theta,phi,radius]=direction([0 0 0 0 0 0],source_pos);
    end

    %% eindproduct
    ir=directivity_ir(theta,phi);

end