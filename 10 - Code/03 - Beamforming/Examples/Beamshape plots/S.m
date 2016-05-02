function f = S(N,d,p)
% creates f(angle,radius) (of dim 361,201)
% takes args of N=numelements, d=spacing(rads), p=delay(rads)

for a=0:360;
  t=a*2*pi/360;  % convert to radians
  for r=0:200;
    g=0;
    for n = -(N-1)/2 : (N-1)/2       % current element number
      g = g + sig( (sqrt((r*cos(t)-n*d)^2+(r*sin(t))^2) + n*p ) );
    end;
    f(a+1,r+1)=g;
  end;
end;

