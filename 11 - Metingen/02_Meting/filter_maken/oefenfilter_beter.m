close all;

fs=1000;
lengte_filter=1000;

% for i=1:2
%     if i==1
%         fs=100;
%     else
%         fs=1000;
%     end

    %% generate inputsequence
    t0=0.5125345;
    
    t=(0:1/fs:1)';                                  % time vector

    s=sin(2*pi*(t-t0)*3)+.25*sin(2*pi*(t-t0)*40);   % input signal

    %% convolve input with a filter
    %g=sinc(fs*t-fs*t0);                             % filter
    %g=ones(1,10)/10;
    g=[zeros(500,1); 1; zeros(500,1)];
    
    x=conv(s,g);                                    % output signal

    %% undo effect of filter    
    r=[x(1); zeros(lengte_filter-1,1)];             % r for toeplitz matrix
    
    x_toepl=[x; zeros(lengte_filter-1,1)];
    X=toeplitz(x_toepl,r);                          % inverse filter: x * h = s -> X h = s -> h = Xinv s
    
    Xinv=pinv(X);                                   % pseudo-inverse
    
    if length(s)<length(x_toepl)
        s_mult=[s; zeros(length(x_toepl)-length(s),1)];            % enlarge or cutoff s
    elseif length(s)>length(x_toepl)
        s_mult=s(1:length(x_toepl));
    else
        s_mult=s;
    end
    
    h=Xinv*s_mult;                                       % find inverse filter

    %% reproduce s with inverse filter and output signal x
    s_reproduce=conv(x,h);
    
    % convolution_and_toeplitz=any((X*h==s_reproduce)==0)

    %% plot them
    figure
    plot(s);hold on;plot(s_reproduce,'g');plot(x,'r');legend('sampled inputsignal','reconstructed inputsignal','filtered inputsignal');
    axis([0 length(s_reproduce) -1 1])
    figure;plot(conv(g,h));
    hold off
%     if i==1
%         title('Sample frequency of 100 Hz')
%     else
%         title('Sample frequency of 1000 Hz')
%     end
% end