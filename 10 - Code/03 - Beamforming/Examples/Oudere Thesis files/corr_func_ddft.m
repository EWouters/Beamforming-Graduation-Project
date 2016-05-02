function R = corr_func_ddft(in_data,L)
N=length(in_data);
if(nargin <2)
    L= 2^nextpow2(2*N-1);
end
% tic
R = 1/N*ifft(abs(fft(in_data,L)).^2);
R = R(1:N);
% t=toc;