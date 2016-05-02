function mout = mapfun(xin)

% Copyright (c) 1995 Philipos C. Loizou
%

global nChannels MAPLaw AB inpMap Xmax Xmin DyrMat

mout=zeros(nChannels,1);

if strcmp(MAPLaw,'log')
   mout = AB(1,1)*log10(xin)+AB(1,2);
elseif strcmp(MAPLaw,'log20')
   mout = 20*log10(xin);
elseif strcmp(MAPLaw,'lin')
   mout= AB(2,1)*xin+AB(2,2);
elseif strcmp(MAPLaw,'pow2')
   mout = AB(3,1)*xin.^(1/2) + AB(3,2);
elseif strcmp(MAPLaw,'pow3')
   mout = AB(4,1)*xin.^(1/3) + AB(4,2);
elseif strcmp(MAPLaw,'pow4')
   mout = AB(5,1)*xin.^(1/4) + AB(5,2);
elseif strcmp(MAPLaw,'pow5')
   mout = AB(6,1)*xin.^(1/5) + AB(6,2);
elseif strcmp(MAPLaw,'userSelected') % mapping function was loaded from file 
   stp=Xmax/64;
   xm=Xmin:stp:Xmax; 
   ind=find(xin<Xmin); if ~isempty(ind), xin(ind)=Xmin.*ones(length(ind),1); end;
   mout= interp1(xm,inpMap,xin);
 
elseif strcmp(MAPLaw,'userSelected_dyr') % dynamic ranges were loaded from file 
  % stp=Xmax/64;
  % xm=Xmin:stp:Xmax; 
  % ind=find(xin<Xmin); if ~isempty(ind), xin(ind)=Xmin.*ones(length(ind),1); end;
  % for i=1:nChannels % -- apply a different map function for each channel 
  %  mout(i)=interp1(xm,DyrMat(:,i),xin(i));
  % end
	for i=1:nChannels
		mout(i)=loimp(xin(i),i,'lin');
	end
 
end
