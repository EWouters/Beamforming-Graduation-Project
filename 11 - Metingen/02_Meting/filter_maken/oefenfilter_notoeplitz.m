fs=1000;

%% generate inputsequence
t=(0:1/fs:1)';                                  % time vector

s=sin(2*pi*t*3)+.25*sin(2*pi*t*40);             % input signal

%% convolve input with a filter
g=ones(1,10)/10;                                % filter
x=conv(s,g);                                    % output signal

%% undo effect of filter
s_zeros=[s; zeros(2*length(x)-length(s)-1,1)];        % enlarge s

r=[x(1); zeros(length(x)-1,1)];                 % r for toeplitz matrix
x_toepl=[x; zeros(length(x)-1,1)];
X=toeplitz(x_toepl,r);        % inverse filter: conv(x,h)=s -> X h=s -> h=Xinv s
Xinv=pinv(X);                                   % pseudo-inverse

h=Xinv*s_zeros;                                       % find inverse filter

%% reproduce s with inverse filter and output signal x
s_reproduce=conv(h,x);

%% try to compress the toeplitz
    % function from the internet: sptoeplitz()
X_sp=sptoeplitz(x_toepl,r);

%% determine pseudoinverse
    % pinv doesn't work with sparsed matrices, so used function
    % from the internet: pseudoinverse()
X_sp_inv=pseudoinverse(X_sp);

%% inverse filter
h_sp=X_sp_inv*s_zeros;

s_reproduce_sp=conv(h_sp,x);

%% plot them
figure
plot(t,s(1:length(t)));hold on;plot(t,s_reproduce(1:length(t)),'g');plot(t,s_reproduce_sp(1:length(t)),'r');legend('sampled inputsignal','reconstructed inputsignal','reconstructed inputsignal (parse)');hold off
title('Sample frequency of 100 Hz')