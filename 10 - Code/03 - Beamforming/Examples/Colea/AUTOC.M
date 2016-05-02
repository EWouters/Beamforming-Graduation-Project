function rxx = autoc(x,p)


x=x(:);

N=length(x);

for k=0:p
   
   rxx(k+1)=x(k+1:N)'*x(1:N-k);
   
end




