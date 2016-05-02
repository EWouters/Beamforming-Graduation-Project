function [ir] = directivity_ir(phone_name,theta, phi)

% choose closest phi: (phi from 0 to 180 degrees)
phi_closest=closest_phi(phi);
% choose nearest theta:  (theta from 0 - 360 degrees)
theta_closest = closest_theta(theta);

% Define vector with closest_phi and closest_theta:
if phi_closest<100
   if phi_closest <10
      Phi_naam=num2str(phi_closest,'00%d');
   else
      Phi_naam=num2str(phi_closest,'0%d');
   end
else
   Phi_naam=num2str(phi_closest,'%d');
end


if theta_closest<100
   if theta_closest<10
      Theta_naam=num2str(theta_closest,'00%d');
   else
      Theta_naam=num2str(theta_closest,'0%d');
   end
else
   Theta_naam=num2str(theta_closest,'%d');
end

naam_vector=[phone_name '_' Phi_naam '_' Theta_naam];
    
% Get vector from .mat file:
eval(['load directivity.mat ' naam_vector]);
eval(['ir =' naam_vector ';']);

% Impulse response output:
ir=ir;

end 