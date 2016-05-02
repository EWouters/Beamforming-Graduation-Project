% voor de metingen
% path('C:\Users\Tim\Documents\GitHub\android-beamforming\11 - Metingen\02_Meting\uitvoering')
addpath('C:\Users\Tim\Documents\GitHub\android-beamforming\10 - Code\02 - Implementatie\02 - MATLAB');

bkstep('init');

% test 123
bkstep('turn relative', 90);
bkstep('turn relative', -90);
bkstep('set absolute', 0);

conn = MeasurementApp(1337,48e3,441,1);   % poort en samplefrequentie
conn.startSITM;

conn.startRecording;pause(5);blaat=conn.stopRecording;
any(blaat(:,1)-blaat(:,2))
player=audioplayer(blaat(:,1),44.1e3);
player.play;