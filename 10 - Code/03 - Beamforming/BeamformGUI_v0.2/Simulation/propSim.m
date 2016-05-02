%function [micSignals, micLocations] = simData(micPos, roomDim, sigPos,     %input: xRoom, tR
%function [sigout, fs] = propSim(varargin)             

% Generate microphone placement adapted code from testmicgeom.m from
% the array toolbox (line 50-69) http://www.engr.uky.edu/~donohue/audio/Arrays/MAToolbox.htm

%   The input variables are expected in the following way
%   micPos = [x1 y1 z1; x2 y2 z2; x3 y3 z3]
%   roomDim = [xRoom yRoom]
%   micNum = X
%   sigPos =    [1.1  1.4  1.5;
%               0.9  1.2  1.3;
%               2.1  0.6  1.1;
%               2.6  0.8  1.3;
%               3.1  3.0  0.9;
%               3.4  3.5  1.4]';
%
%  
%


%%  Load default data if 1 or more of the variables is not given as input
%
%   Default:    micNum = 6
%               xRoom = 3
%               yRoom = 6
%               zRoom = 0

clear
if ~exist ('micPos', 'var')        
    if ~exist ('roomDim', 'var') && ~exist ('micNum', 'var')  %   if micPos and roomDim are not given
        micNum = 6;                                  %   Number of random mics to generate
        xRoom = 3;                                  %   Room size on the x-axis
        yRoom = 6;                                  %   Room size on the y-axis
        
    elseif ~exist ('roomDim', 'var') && exist ('micNum', 'var')
        xRoom = 3;                                  %   Room size on the x-axis
        yRoom = 6;
        
    elseif exist ('roomDim', 'var') && ~exist ('micNum', 'var')
        micNum = 6;
        xRoom = roomDim(1);
        yRoom = roomDim(2);
        
    elseif exist ('roomDim', 'var') && exist ('micNum', 'var')
        xRoom = roomDim(1);
        yRoom = roomDim(2);
        
    end
    xRange = [0 xRoom];                         %   x range over which to distribute (with starting point 0 assumed)
    yRange = [0 yRoom];                         %   y range over which to distribute (with starting point 0 assumed)
    
    %dstx = (rng(2)-rng(1));                    %   Compute Square distance

    mposx = rand(1,micNum)*xRoom;               %   Generate random number over array
    mposy = rand(1,micNum)*yRoom; 
    mposz = [0 0 0 0 0 0];

    micPos = [mposx ;mposy ;mposz];
        
else                                            %   Room dimensions must be specified
    micPos = micPos';                           %   Transpose array
    
    xRoom = roomDim(1);
    yRoom = roomDim(2);

    xRange = [0 xRoom];                         %   x range over which to distribute (with starting point 0 assumed)
    yRange = [0 yRoom];                         %   y range over which to distribute (with starting point 0 assumed)
end

% save('mic_positions', 'micPos')                   %   Save microphone positions
% 
% %plot the microphone locations
% figure(4)
% %set(gcf,'Position', [272   209   560   420])   %   set [left bottom width height]
% plot(micPos(1,:), micPos(2,:), 'x')             %   Plot mic position
% axis([xRange, yRange])                          %   set plot axis to full room
%                                                 %   label mics with index from MPOS
% xlabel('Meters')
% ylabel('Meters')
% title(['Positions of mics over a ' num2str(xRoom) ' by ' num2str(yRoom) ' area'])

%% Load the audio file
%filename = uigetfile({'*.*'},'File Selector'); %   Get the audio file
filenames = {'man1.wav';'man2.wav';'man3.wav';'woman1.wav';'woman2.wav';'woman3.wav'};             %   The names of the audio files placed in a cell
%sigPos = [x1 y1 z1; x2 y2 z2;..]'; %   



tTrim = [0 5]; %    Trim the sound signals down to the first 5 seconds

sigPos = [1.1  1.4  1.5;
        0.9  1.2  1.3;
        2.1  0.6  1.1;
        2.6  0.8  1.3;
        3.1  3.0  0.9;
        3.4  3.5  1.4]';

c = 340;

[sig, fs] = signals(filenames, tTrim);

fs = fs(1);

%% Simulate the microphones recording the signals
%   Calculate the attenuation in air
f = (fs/2)*[0:200]/200; 
airAtten = airAtten(f);                      % Output in dB

%   Simulate recording the audio files
[sigout, tax] = record(airAtten, micPos, sigPos, sig, fs, c) ; 

%audiowrite('filename','sigout','fs')

if micNum < 3   % Number of mics may be less than 4
        mn = 1:micNum;
else    % Create 3 random numbers for mic playback
        [x,mn] = sort(rand(1,micNum));
       % mn = mn(1:3);
end
    
% Play the simulated input to the mics
for i=1:length(mn)
        disp(['Playing the input of the mic located at (', ...
            num2str(micPos(1,mn(i))), ', ', ...
            num2str(micPos(2,mn(i))), ', ', ...
            num2str(micPos(3,mn(i))), ')']);
        soundsc(sigout(:,mn(i)),fs);
        pause(5);
end
























%                
% sigpos = [1; 3];                      %   Position of the source signal [x; y; z]
% 
% %% Properties of the propagation of the sound
% prop.c = 340;                                  %   Set the speed of sound
% % %prop.dbd
% 
% numStep = 200                                   %   Number of steps 
% prop.freq = fs/2 * [0:numStep]/numStep          %   
% % prop.atten = 1300;                            %   Attenuation of the sound in dB per meter-Hz
% 
% % mpath example
% % mpath = mpos+[0; 0.40; 0]*ones(1,micnum);  % for each mic place a satterer behind it (relative to speaker) at 40 cm to simulate a wall/scatterer behind the mic array
% 
% %prop.mpath                                 %   3 or 4 row vecotor containing the x,y,z (z if 3D included)
%                                             %   coordinates of multipath scatterers in the last 2 or 3 rows.
%                                             %   The first row is the isotropic scattering coefficient (unitless
%                                             %   and less than 1 for a passive scatterer).  Only first order
%                                             %   multipath is considered.  If not present, multipath is not generated.
% 
% %% Calculate the audio files for each placed microphone
% 
% [sigout, tax] = simarraysig(y, fs, sigpos, mpos, prop) ; %sigout gives one column for each microphone and tax gives the time axis.
% 
%end
