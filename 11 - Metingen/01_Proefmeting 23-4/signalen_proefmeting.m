%Wat wij vandaag hebben gedaan

[MLS_sequence MLS]=GenerateMLSSequence(10,14,1); %10x orde 14 MLS met alignmentpulse
[TSP_sequence TSP]=GenerateTSPSequence(10,14,1,'circ'); %10x orde 14 TSP met alignmentpulse met circulaire convolutie

Fs=48E3; %Hz

%uitvoeren:
sound(MLS_sequence,Fs);
sound(TSP_sequence,Fs);

MLS_measurement=audioplayer(MLS_sequence, Fs);
play(MLS_measurement);

TSP_measurement=audioplayer(TSP_sequence, Fs);
play(TSP_measurement);