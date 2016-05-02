function [ w_dakje, theta ] = beam_resp(filter, N, delta)

    if (nargin <= 2)
       delta = 1/2;    
    end

    theta = 0 : (2*pi/(N - 1)) : 2*pi;
    w = zeros(N,1);
    w(1:length(filter)) = filter;
    w_dakje = 0;

    for n = 0:N-1
        w_dakje = w_dakje + w(n + 1)*exp(-1i*2*pi*delta*sin(theta)*n);
    end

end