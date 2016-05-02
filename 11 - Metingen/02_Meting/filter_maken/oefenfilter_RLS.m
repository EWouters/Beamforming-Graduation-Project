%% Oefenen met het maken van een filter door gebruik te maken van RLS: Recursive Least Squares method
close all;

fs=200;

%% generate inputsequence
t0=0.005125345;

t=(0:1/fs:1)';                                  % time vector

s=sin(2*pi*(t-t0)*3)+.25*sin(2*pi*(t-t0)*40);   % input signal

%% convolve input with a filter
%g=sinc(fs*(t-t0));                               % filter
%g=ones(1,10)/10;
g=[zeros(10,1); 1; zeros(500,1)];
%g=[1; zeros(100,1)];

x=conv(s,g);                                    % output signal

%% initializing the RLS algoritm
iteraties=200;
delta=0.000001;
lambda=0.2;          % lambda in (13.6) as forgetting factor: (1-lambda)^-1

% X h = s  <->  Phi w = z

% u is the tap-input vector at time i, defined by (13.3) 
% u is the reference signal (13.40)
u=s;

P=(1/delta)*eye(length(u));

% w is the tap-input vector at time n, defined by (13.4)
w=zeros(length(u),1);

% d is the desired response (13.26)
% d is the primary signal (13.40)
d=x;

for i=1:iteraties
    k=((1/lambda)*P*u)/(1+(1/lambda)*ctranspose(u)*P*u);
    ksi=d(i)-ctranspose(w)*u;
    w=w+k*conj(ksi);
    P=(1/lambda)*P - ((1/lambda)*(k*ctranspose(u))*P);
end

% from the single weight adaptive noise canceler figure 13.3
% for n=1:length(u)
%     k(n)=u(n)/(lambda*P(n-1)+norm(u(n))^2);
%     ksi(n)=d(n)-conj(w(n-1))*u(n);
%     w(n)=w(n-1)+k(n)*conj(ksi(n));
%     P(n)=lambda*P(n-1)+norm(u(n))^2;
% end

% check whether you made it
h=w;
s_reproduce= conv(h,x);
check=conv(g,h);

%plot!
figure;
subplot(2,2,1)
plot(s);hold on; plot(x,'r');
legend('input signaal systeem','output signaal systeem')
axis([1 length(x) -max(max(s),max(x)) max(max(s),max(x))])
subplot(2,2,2)
plot(h,'g');
axis([1 length(h) -max(h)-0.1 max(h)+0.1])
legend('filter')
subplot(2,2,3);
plot(s);hold on; plot(s_reproduce,'r');
axis([1 length(s_reproduce) -max(max(s),max(s_reproduce)) max(max(s),max(s_reproduce))])
hold off; legend('input signaal systeem','Conv(h,ouput)(=?input)')
subplot(2,2,4);
plot(check,'k');legend('conv(g,h)=?delta');axis([-0.1*length(check) length(check) -max(abs(check)) max(abs(check))])