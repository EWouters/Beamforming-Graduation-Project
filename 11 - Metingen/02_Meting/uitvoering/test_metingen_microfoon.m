% for i=1:7
%     conn.audio_source=uint8(i);
close all;
addpath('C:\Users\Tim\Documents\GitHub\android-beamforming\10 - Code\02 - Implementatie\02 - MATLAB');

TSP_sequence=GenerateTSPSequence(10,15,0,'circ');
gain=-7;
Fs=48e3;

gain=db2mag(gain);
TSP_sequence=TSP_sequence*gain;
plot(TSP_sequence);


recorder = audiorecorder(Fs,16,1);

recorder.record();
TSP_play=audioplayer(TSP_sequence,Fs);

conn.startRecording;
pause(0.5);
playblocking(TSP_play);
pause(0.5);
android_output=conn.stopRecording;
stop(recorder);
microfoon_output=recorder.getaudiodata;

figure;
plot(double(android_output)/2^15);

figure;
plot(microfoon_output);
% pause();
% end