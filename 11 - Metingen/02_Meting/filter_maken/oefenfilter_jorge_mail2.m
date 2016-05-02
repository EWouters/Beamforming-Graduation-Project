close all;

fs=1000;
lengte_filter=1000;

    %% generate inputsequence
    t0=0.5125345;
    
    t=(0:1/fs:1)';                                  % time vector

    s=sin(2*pi*(t-t0)*3)+.25*sin(2*pi*(t-t0)*40);   % input signal

    %% convolve input with a filter
    g1=[zeros(500,1); 1; zeros(500,1)];
    g2=[zeros(10,1); 1; zeros(990,1)];
    
for i=1:2
    if i==1
        g=g1;
    else
        g=g2;
    end
    
    
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
    plot(s);hold on;plot(s_reproduce(1:2000),'g');plot(x(1:2000),'r');legend('sampled inputsignal','reconstructed inputsignal','filtered inputsignal');
    axis([0 2000 -1 1])
    hold off
    if i==1
        title('Delta-peek after 500 samples')
    else
        title('Delta-peek after 10 samples')
    end
    
    figure;plot(conv(g,h));
    title('Convolution(filter,inverse filter): idealy a deltapeek at x=0')
end