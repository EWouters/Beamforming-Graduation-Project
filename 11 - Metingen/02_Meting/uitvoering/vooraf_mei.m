% voor de metingen
% path('C:\Users\Tim\Documents\GitHub\android-beamforming\11 - Metingen\02_Meting\uitvoering')
addpath('C:\Users\Tim\Documents\GitHub\android-beamforming\10 - Code\02 - Implementatie\02 - MATLAB');

bkstep('init');

% test 123
bkstep('turn relative', 90);
bkstep('turn relative', -90);
bkstep('set absolute', 0);

conn = MeasurementApp(1337,48e3);   % poort en samplefrequentie
conn2 = MeasurementApp(1336,48e3);   % poort en samplefrequentie
conn.audio_source=uint8(6);         % nr 6 is voice recognition