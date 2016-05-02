%%
% Metingen directivities, zoals beschreven in het meetplan
% Meten in de phi-richting over stappen van negen graden
% Meten in de theta-richting over stappen van negen graden
% Op de polen (phi=0 / pi) wordt slechts een meting verricht

%%
% stel in:
naam_telefoon='CHINA';
phi=90;             % graden vanaf de z-as
stap=9;                 % stapgrootte

%% aanpassing turntable stepsize (omgekeerde telefoon)
% if phi>90
     ttstep=-stap;
% else
%     ttstep=stap;
% end

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

h = waitbar(theta/360,sprintf('Please wait... TSP measurement at %i of 360',theta));

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
while theta<361
    
    if theta<100
        if theta<10
            theta_naam=num2str(theta,'00%d');
        else
            theta_naam=num2str(theta,'0%d');
        end
    else
        theta_naam=num2str(theta,'%d');
    end
        
    naam1=[naam_telefoon 't_' method '_' phi_naam '_' theta_naam];
    naam2=[naam_telefoon 'b_' method '_' phi_naam '_' theta_naam];
    
%    output=output_clear;
    
    % Start opname
    conn.startRecording;
    
    if strcmp(method,'TSP')
        pause(0.1);
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
    output1=output(:,1);
    output2=output(:,2);
    assignin('base',naam1,output1);
    assignin('base',naam2,output2);
    clear output output1 output2;
    
    % verander hoek turntable
    if(theta<360)
        theta=theta+stap;
        bkstep('turn relative', ttstep);
        pause(0.5)
    else
        theta=theta+stap;
    end
    
    % update waitbar
    waitbar(theta/(2*360),h,sprintf('Please wait... TSP measurement at %i of 360',theta))
    
end;

%% MLS measurements

method='MLS';       % methode

theta=0;

waitbar(0.5,h,sprintf('Please wait... MLS measurement at %i of 360',theta));

while theta<361
    
    if theta<100
        if theta<10
            theta_naam=num2str(theta,'00%d');
        else
            theta_naam=num2str(theta,'0%d');
        end
    else
        theta_naam=num2str(theta,'%d');
    end
        
    naam1=[naam_telefoon 't_' method '_' phi_naam '_' theta_naam];
    naam2=[naam_telefoon 'b_' method '_' phi_naam '_' theta_naam];
    
%    output=output_clear;
    
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
    output1=output(:,1);
    output2=output(:,2);
    assignin('base',naam1,output1);
    assignin('base',naam2,output2);
    clear output output1 output2;
    
    % verander hoek turntable
    if(theta<360)
        theta=theta+stap;
        bkstep('turn relative', ttstep);
        pause(0.5)
    else
        theta=theta+stap;
    end
    
    % update waitbar
    waitbar((360+theta)/(2*360),h,sprintf('Please wait... MLS measurement at %i of 360',theta))
    
end;

waitbar(1,h,sprintf('Please wait... saving workspace'))

%% save workspace
save([naam_telefoon '_' phi_naam]);

%%
% bericht: measurement completed
delete(h)
h = msgbox('Measurement Completed','Measurement Completed');

next=0;
prompt='Klaar voor de eerste plots? 1=ja 0=nee';
next=input(prompt);
if next==1
    metingen_checkinhoud_jun
    prompt='Metingen samenvoegen, plotten en opslaan? 1=ja 0=nee';
    next=input(prompt);
    if next==1
        naam_telefoons=['CHINAt';'CHINAb'];
        methods=['MLS';'TSP'];       % methods
        stap=9;             % stapgrootte
        close all;

        for i=1:2
            naam_telefoon=naam_telefoons(i,:);
            for j=1:2
                method=methods(i,:);
                
                metingen_samenvoegen_jun
            end
            plot_elevation_v2_jun
        end
    end
end