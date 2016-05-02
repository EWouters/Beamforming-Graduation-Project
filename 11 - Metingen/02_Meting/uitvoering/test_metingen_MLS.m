close all;

MLS_sequence=GenerateMLSSequence(10,15,0);
gain=-7;
Fs=48e3;

gain=db2mag(gain);
MLS_sequence=MLS_sequence*gain;
plot(MLS_sequence);
MLS_play=audioplayer(MLS_sequence,Fs);

conn.startRecording;pause(0.5);
playblocking(MLS_play);
pause(0.5);
test=conn.stopRecording;
figure;
plot(double(test)/2^15);