close all;

TSP_sequence=GenerateTSPSequence(10,15,0,'circ');
gain=-7;
Fs=48e3;

gain=db2mag(gain);
TSP_sequence=TSP_sequence*gain;
plot(TSP_sequence);
TSP_play=audioplayer(TSP_sequence,Fs);

conn.startRecording;pause(0.5);
playblocking(TSP_play);
pause(0.5);
test=conn.stopRecording;
figure;
plot(double(test)/2^15);