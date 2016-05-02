

j=sqrt(-1);
i=1
stp=5500/512;
for f=1:stp:5500
   tran(i) = (1+j*f/1200)/(1+j*f/3000);
   i=i+1;
  if i<=512 r(i)=f; end;
end
FS=11000;
%--------------------
b = exp(-1200*2*pi/FS);
a = exp(-3000*2*pi/FS);

[H,F]=freqz([1 -b],[1 -a],512);
%subplot(2,1,1),semilogx(r,10*log10(abs(tran)))
%subplot(2,1,2),semilogx(r,10*log10(abs(H)))
max(10*log10(abs(H)))-min(10*log10(abs(H)))
max(10*log10(abs(tran)))-min(10*log10(abs(tran)))
subplot(2,1,1),plot(r,10*log10(abs(tran)))
axis([ 0 FS/2 min(10*log10(abs(tran))) max(10*log10(abs(tran)))])
subplot(2,1,2),plot(r,10*log10(abs(H)))
axis([ 0 FS/2 min(10*log10(abs(H))) max(10*log10(abs(H)))])

