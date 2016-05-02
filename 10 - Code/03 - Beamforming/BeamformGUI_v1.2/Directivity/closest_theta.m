function [theta_closest] = closest_theta(theta)
% Convert theta from radians to degrees: 
theta = radtodeg(theta);

% Define theta between 0 and 360 degrees: 
if theta>361
   multiple = floor(theta/360);
   theta = theta - (multiple*360);
else 
    theta = theta;
end 
% choose nearest theta:
if theta<361 
   theta_mod = mod(theta,9);
   if theta_mod <= 4
      theta_closest = theta - theta_mod;
   else 
      theta_closest = theta -theta_mod + 9;  
   end
else 
   'error' ;
end
end 