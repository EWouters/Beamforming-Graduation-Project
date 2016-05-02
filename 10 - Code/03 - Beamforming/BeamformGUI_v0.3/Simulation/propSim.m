function [sigout] = propSim(audio, Fs, micPos, sigPos, startTime, endTime)
%  This function simulates recording multiple audio sources in a room with
%  multiple microphones.
%
%   Inputs
%   audio       Matrix with the seperate (to be recorded) audio files from
%               the sources
%   Fs          The sampling frequency of the audio (assumed to be the same
%               for each audio file
%   micPos      Array with the positions of the microphones [x y z]'
%   sigPos      Array with the positions of the sources
%   startTime   Time to start the simulation
%   endTime     Time to stop the simulation

%   Output
%   sigout  The sound recorded by the microphones (one column per
%           microphone, one row per sample)

%%  Example

%   filenames = {'man1.wav';'man2.wav';'woman1.wav';'woman2.wav'};      Placed the names of the audio files in a cell 
%   sigNum = 4;

%   For loop to place the signals in a matrix
%   for ii = 1 : sigNum
%       [audio{ii}, Fs(ii)]= audioread(filenames{ii});                      Save y and Fs for each audio file
%   end    
%   
%   Fs = Fs(1);                                                         The different audio files are assumed to have the same sampling frequency


%   micPos =    [ 1 1 0; 99 1 0; 99 99 0; 1 99 0]';                     Enter the positions of the microphones
               
   
%   sigPos =    [0  0   0;  100 0   0; 100 100 0; 0   100 0]';          Enter the positions of the audio sources
             
%   Set start and end time in seconds
%   startTime = 0;
%   endTime = 5;


%% Trim the audio file down to the desired length
tTrim = [startTime endTime];                                        %   Set the time interval to trim down to
sig = trimSig(audio, Fs, tTrim);

%% Simulate the microphones recording the signals
c = 343.216;                                                        %   Speed of sound at 20 degrees celsius
sigout = simRec(sig, sigPos, micPos, Fs, c);                 %   Simulate recording the audio files
end