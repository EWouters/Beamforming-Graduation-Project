function I = ishandle(h)
%ISHANDLE True for graphics handles.
%        ISHANDLE(H) returns 1's where the elements of H are valid graphics 
%        handles and 0's where they are not.

%	L. Ljung 4-4-94, AFP 10-25-94
%	Copyright (c) 1994 by the MathWorks, Inc.
%	$Revision: 1.4 $  $Date: 1995/01/17 13:42:57 $

hsize = size(h);
I = ones(hsize);
for j = 1:prod(hsize),
   eval('findobj(h(j));','I(j)=0;');
end

% end ishandle
