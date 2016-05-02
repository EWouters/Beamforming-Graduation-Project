function labtext


%
% Copyright (c) 1995 by Philipos C. Loizou
%

global lbaUp lbVals labSave 
	

if isempty(labSave)
  labSave=zeros(50,10);
end


cnt0=size(lbVals);
cnt=cnt0(1);

str=get(lbaUp(cnt),'String');
codstr=abs(str); 
len=length(codstr);

labSave(cnt,1:len)=codstr;



label('savef');


