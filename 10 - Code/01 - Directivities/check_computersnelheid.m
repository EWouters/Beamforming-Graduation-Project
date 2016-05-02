Fs=48000;
rep=5;
N=15;
[TSP_test_seq TSP_test]=GenerateTSPSequence(rep, N, 0, 'circ');
test_analyse=TSP_test_seq*linspace(2,1,40);

tic;

test_result=AnalyseTSPSequence(test_analyse,0,rep,N,0,'circ');
t=toc;
t

geluid=audioplayer(TSP_test_seq,Fs);
play(geluid);

aantal_metingen=762; %equiangular 9 graden

tijd_totaal=(length(TSP_test_seq)/Fs)*762/3600 %in uren