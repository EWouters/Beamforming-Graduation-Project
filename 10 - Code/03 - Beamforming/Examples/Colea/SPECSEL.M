function specsel

% Copyright (c) 1995 Philipos C. Loizou
%

global SpcUp LPCSpec S0

x = get(SpcUp,'Value');

if (x > 1)

 if     (x==2) LPCSpec=1;
   else        LPCSpec=0;
  end

pllpc(S0)

end