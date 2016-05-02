function D=distcalc(Mpos,Lpos)
% DISTCAL Binary distance calculator for valid device matrices.

M=size(Mpos,1);
L=size(Lpos,1);

dotprods=Lpos*Mpos.';
Lsqrprods=diag(Lpos*Lpos.');
Msqrprods=diag(Mpos*Mpos.').';
D=(repmat(Lsqrprods,1,M)+repmat(Msqrprods,L,1)-(2.*dotprods)).^0.5;
