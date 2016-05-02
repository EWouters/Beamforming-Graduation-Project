function [a] = airAtten(f)

%function [a] = airAtten(Tin,Psin,hrin,dist,f)
% A function to return the atmospheric attenuation of sound due to the vibrational relaxation times of oxygen and nitrogen.
% NOTE:  This function does not account for spherical spreading!
%
% Usage: [a] = atmAtten(T,P,RH,d,f)
%               a - attenuation of sound for input parameters in dB
%               T - temperature in deg C
%               P - static pressure in mmHg
%               RH - relative humidity in %
%               d - distance of sound propagation
%               f - frequency of sound (may be a vector)
%
% Nathan Burnside 10/5/04
% AerospaceComputing Inc.
% nburnside@mail.arc.nasa.gov
%
% References:   [1] Bass, et al., "Journal of Acoustical Society of America", (97) pg 680, January 1995.
%               [2] Bass, et al., "Journal of Acoustical Society of America", (99) pg 1259, February 1996.
%               [3] Kinsler, et al., "Fundamentals of Acoustics", 4th ed., pg 214, John Wiley & Sons, 2000.
%

% default values 
Tin = 22; 
Psin = 29.92; 
hrin = 38;
dist = 1;


T = Tin + 273.15; % temp input in K
To1 = 273.15; % triple point in K
To = 293.15; % ref temp in K

Ps = Psin/29.9212598; % static pressure in atm
Pso = 1; % reference static pressure, Pso are left out of the implemented equations

F = f./Ps; % frequency per atm


% calculate saturation pressure                                 equation 1 from [1]
Psat = 10^(10.79586*(1-(To1/T))-5.02808*log10(T/To1)+1.50474e-4*(1-10^(-8.29692*((T/To1)-1)))-4.2873e-4*(1-10^(-4.76955*((To1/T)-1)))-2.2195983);


h = hrin*Psat/Ps; % calculate the absolute humidity     `       equation 6 from [1]

% Scaled relaxation frequency for Nitrogen                      equation 5 from [1]     
FrN = (To/T)^(1/2)*(9+280*h*exp(-4.17*((To/T)^(1/3)-1)));

% scaled relaxation frequency for Oxygen                        equation 4 from [1]
FrO = (24+4.04e4*h*(.02+h)/(.391+h));                         

% attenuation coefficient in nepers/m                           the equation from [2]
alpha = Ps.*F.^2.*(1.84e-11*(T/To)^(1/2) + (T/To)^(-5/2)*(1.275e-2*exp(-2239.1/T)./(FrO+F.^2/FrO) + 1.068e-1*exp(-3352/T)./(FrN+F.^2/FrN)));

% attenuation of sound in dB                                    equation 8.3.6 from [3]
%a = 10*log10(exp(2*alpha)*dist);
a = 10*log10(exp(2*alpha))*dist;