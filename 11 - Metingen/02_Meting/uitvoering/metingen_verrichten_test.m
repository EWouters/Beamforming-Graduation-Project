% Metingen directivities, zoals beschreven in het meetplan
% Meten in de phi-richting over stappen van negen graden
% Meten in de theta-richting over stappen van negen graden
% Op de polen (phi=0 / pi) wordt slechts een meting verricht

% stel in:
naam_telefoon='NX506';
method='TSP';       % methode
phi=0;            % graden vanaf de z-as
stap=9;             % stapgrootte

theta=0;            % graden vanaf de x-as
wachttijd=0.1;

%max_length_signal=1.1*(TSP_measurement.TotalSamples+wachttijd*TSP_measurement.SampleRate);
max_length_signal=10;

% start connectie MATLAB - telefoon

h = waitbar(theta/360,sprintf('Please wait... measurement at %i of 360',theta));

output_clear=zeros(1,max_length_signal);
output=output_clear;

if phi<100
    if phi<10
        phi_naam=num2str(phi,'00%d');
    else
        phi_naam=num2str(phi,'0%d');
    end
else
    phi_naam=num2str(phi,'%d');
end

while theta<360
    
    if theta<100
        if theta<10
            theta_naam=num2str(theta,'00%d');
        else
            theta_naam=num2str(theta,'0%d');
        end
    else
        theta_naam=num2str(theta,'%d');
    end
        
    naam=[naam_telefoon '_' method '_' phi_naam '_' theta_naam];
    
    output=output_clear;
    
    % Start opname
    
    % speel het TSP-signaal
    % playblocking(TSP_measurement);
    
    % kleine pauze voor de zekerheid
    pause(wachttijd);
    
    % Stop opname
    output=theta*ones(2,1);% stopopname
    assignin('base',naam,output);
    clear output;
    
    % verander hoek turntable
    theta=theta+stap;
    % bkstep('turn relative', stap);
    % pause(0.5)
    
    % update waitbar
    waitbar(theta/360,h,sprintf('Please wait... measurement at %i of 360',theta))
    
end;

% bericht: measurement completed
delete(h)
h = msgbox('Measurement Completed','Measurement Completed');

% Sluit connectie MATLAB - telefoon

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Voeg meetresultaten in één matrix
clear output;
output=zeros(360/stap+1,max_length_signal);
naam_output=[naam_telefoon '_' method '_' phi_naam];
assignin('base',naam_output,output);

delete(naam_output);

theta=0;
for i=1:(360/stap+1)
    if theta<100
        if theta<10
            theta_naam=num2str(theta,'00%d');
        else
            theta_naam=num2str(theta,'0%d');
        end
    else
        theta_naam=num2str(theta,'%d');
    end
    
    naam=[naam_telefoon '_' method '_' phi_naam '_' theta_naam];
    theta=theta+stap;
    
    if i==1
        save([naam_output '.mat']);
    else
        save([naam_output '.mat'],naam,'-append');
    end
end
