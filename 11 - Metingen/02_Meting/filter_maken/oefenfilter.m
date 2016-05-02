% % eenkeer_MLS=bestmic_MLS_090(:,1);
% % eenkeer_MLS_resample=resample(eenkeer_MLS,48,8);
% % 
% % ir_oefen=AnalyseMLSSequence(eenkeer_MLS_resample,0,10,15,'false',0);
% 
% eenkeer_TSP=bestmic_TSP_090(:,1);
% figure;plot(eenkeer_TSP);
% eenkeer_TSP_resample=downsample(eenkeer_TSP,2);
% figure; plot(eenkeer_TSP_resample);
% 
% ir_oefen=AnalyseTSPSequence(eenkeer_TSP_resample,0,10,15,0,'circ');
% g=fft(ir_oefen);
% 
% s=GenerateTSPSequence(10,15,0,'circ');
% s=resample(s,8,48);
% 
% nullen=zeros(length(s)-length(eenkeer_TSP_resample),1);
% 
% x=fft([eenkeer_TSP_resample; nullen]);
% s=fft(s);
% 
% G=toeplitz([g; zeros(length(x)-length(g),1)]);
% H=pinv(G);

%% test filtering
fs = 100;                               % Sampling frequency
t = 0:1/fs:1;                           % Time vector
x = sin(2*pi*t*3)+.25*sin(2*pi*t*40);   % Input Signal
b = ones(1,10)/10;  % 10 point averaging filter
y = fftfilt(b,x);   % FIR filtering using overlap-add method
plot(t,x,t,y,'--');

t2 = 0:0.00001:1;
x2 = sin(2*pi*t2*3)+.25*sin(2*pi*t2*40);
plot(t2,x2,t,y,'--');
legend('Original Signal','Filtered Signal')

%% eigen test
t3=-10:0.1:10;
x3=sinc(t3)'.*hamming(length(t3));

s=GenerateTSPSequence(10,15,0,'circ');
h=x3;
x=fftfilt(h,s);
x=downsample(x,50);
X=toeplitz(x);
