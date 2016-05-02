function ir=directivity(phone_pos,source_pos)

direction=source_pos-phone_pos(1:3);

% Theta = hoek t.o.v. x-as
% gemeten in x-y-vlak
if direction(2)>0
    % y>0
    theta=dot([direction(1) direction(2)],[1 0])/norm([direction(1) direction(2)]);
    theta=acos(theta);
elseif direction(2)<0
    % y<0
    theta=dot([direction(1) direction(2)],[-1 0])/norm([direction(1) direction(2)]);
    theta=acos(theta)+pi;
else
    % y=0
    if direction(1)>=0
        theta=0;
    else
        theta=pi;
    end
end

% Phi = hoek t.o.v. z-as
% gemeten in x-z-vlak
% Phi in [0,pi]
if direction(1)<0
    % als x<0, dan phi>pi, dus vector omslaan
    direction(1)=-direction(1);
    phi=dot([direction(1) direction(3)],[0 1])/norm([direction(1) direction(3)]);
    phi=acos(phi);
elseif direction(1)==0
    % als x=0, dan phi of 0 of pi
    if direction(3)>=0
        % dus nul als in het bovenste z-vlak
        phi=0;
    else
        % dus pi als in het onderste z-vlak
        phi=pi;
    end
else
    % dan x>0, dus gaat het in een keer goed!
    phi=dot([direction(1) direction(3)],[0 1])/norm([direction(1) direction(3)]);
    phi=acos(phi);
end

ir=directivity_ir(theta+phone_pos(4),phi+phone_pos(5));

end