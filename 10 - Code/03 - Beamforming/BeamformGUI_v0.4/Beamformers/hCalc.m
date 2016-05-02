function data = hCalc (y, sourcePos, micPos)
%   This function 
%   
%   Inputs
%   sig     
%
%   Output
%   data    The beamformed data

%% acoustic transfer function for anechoic environment

% For each mic
for ii = 1:length(micPos)
   dist = norm((sourcePos(1:3)-micPos(ii,:)),2);
   H(ii) = exp(-omega*dist*1i)/(4*pi*dist);
end