function [phi_closest] = closest_phi(phi)
% Convert phi from radians to degrees: 
phi = radtodeg(phi);

if phi<=180 
% Boven- en onderin bol stappen van 9 graden genomen:
   if phi<=22 || phi>=158
      phi_mod = mod(phi,9);
      if phi_mod <= 4
         phi_closest = phi - phi_mod;
      else 
          phi_closest = phi - phi_mod + 9;
      end
   else
      phi_round= round((phi-22)/8);
      phi_closest = 26+(phi_round*8);  
   end
    'error: phi out of bounds [0,pi]' ;
end

end
  
   