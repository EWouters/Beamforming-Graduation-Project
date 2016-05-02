%%
% Metingen directivities, zoals beschreven in het meetplan
% Meten in de phi-richting over stappen van negen graden
% Meten in de theta-richting over stappen van negen graden
% Op de polen (phi=0 / pi) wordt slechts een meting verricht

%%
% stel in:
naam_telefoon='NX501FD';
phi=0;             % graden vanaf de z-as

%%
%blijf af
method='TSP';       % methode
theta=0;            % graden vanaf de x-as
wachttijd=0.1;
gain=-7;
Fs=48e3;

gain=db2mag(gain);

% initialize turntable and
% start connectie MATLAB - telefoon

% reset turntable
bkstep('turn absolute',0);
pause(5);

if phi<100
    if phi<10
        phi_naam=num2str(phi,'00%d');
    else
        phi_naam=num2str(phi,'0%d');
    end
else
    phi_naam=num2str(phi,'%d');
end
%%
   
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
    
   
    % Start opname
    conn.startRecording;
    
    if strcmp(method,'TSP')
        play_sequence=GenerateTSPSequence(10,15,0,'circ'); %6.5 min per meting
    elseif strcmp(method,'MLS')
        play_sequence=GenerateMLSSequence(10,15,0);          %6.7 min per meting
    else
        'error: no method'
        break;
    end
            

    play_sequence=play_sequence*gain;
    
    audio_play=audioplayer(play_sequence,Fs);
    
    % speel het TSP-signaal
    playblocking(audio_play);
    
    % kleine pauze voor de zekerheid
    pause(wachttijd);
    
    % Stop opname
    output=conn.stopRecording();
    output=output';                 % transponeren anders worden we gek met de Analyse***
    assignin('base',naam,output);
    clear output;
    
    figure;
    opdracht=['plot(' naam ');'];
    eval(opdracht);
    title('TSP pool')

%% MLS measurements

method='MLS';       % methode

theta=0;
    
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
    
    
    % Start opname
    conn.startRecording;
    
    if strcmp(method,'TSP')
        play_sequence=GenerateTSPSequence(10,15,0,'circ');      % 6.5 min per meting
    elseif strcmp(method,'MLS')
        play_sequence=GenerateMLSSequence(10,15,0);             % 6.7 min per meting
    else
        'error: no method'
        break;
    end
            

    play_sequence=play_sequence*gain;
    
    audio_play=audioplayer(play_sequence,Fs);
    
    % speel het TSP-signaal
    playblocking(audio_play);
    
    % kleine pauze voor de zekerheid
    pause(wachttijd);
    
    % Stop opname
    output=conn.stopRecording();
    output=output';                 % transponeren anders worden we gek met de Analyse***
    assignin('base',naam,output);
    clear output;
    
    figure;
    opdracht=['plot(' naam ');'];
    eval(opdracht);
    title('MLS pool');

%% save workspace
save([naam_telefoon '_' phi_naam]);

%%
% bericht: measurement completed
h = msgbox('Measurement Completed','Measurement Completed');
