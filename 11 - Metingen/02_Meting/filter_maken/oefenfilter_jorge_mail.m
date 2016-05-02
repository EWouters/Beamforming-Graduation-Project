close all;

for i=1:2
    if i==1
        fs=100;
    else
        fs=1000;
    end

    %% generate inputsequence
    t=(0:1/fs:1)';                                  % time vector

    s=sin(2*pi*t*3)+.25*sin(2*pi*t*40);             % input signal

    %% convolve input with a filter
    g=sinc(fs*t-fs*t0);                                % filter
    x=conv(s,g);                                    % output signal

    %% undo effect of filter
    s=[s; zeros(2*length(x)-length(s)-1,1)];        % enlarge s

    r=[x(1); zeros(length(x)-1,1)];                 % r for toeplitz matrix
    X=toeplitz([x; zeros(length(x)-1,1)],r);        % inverse filter: conv(x,h)=s -> X h=s -> h=Xinv s
    Xinv=pinv(X);                                   % pseudo-inverse

    h=Xinv*s;                                       % find inverse filter

    %% reproduce s with inverse filter and output signal x
    s_reproduce=conv(h,x);

    %% plot them
    figure
    plot(t,s(1:length(t)));hold on;plot(t,s_reproduce(1:length(t)),'g');legend('sampled inputsignal','reconstructed inputsignal');hold off
    if i==1
        title('Sample frequency of 100 Hz')
    else
        title('Sample frequency of 1000 Hz')
    end
end