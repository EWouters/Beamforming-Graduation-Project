

vls='iyiheyeheraeuhahauouayooar';
hdr='     iy    ih   ey    eh    er    ae    uh    ah    au    ou    ay    oo   ar';

fp = fopen('fb1.dat','r');
if (fp<=0)
	error('cannot read input file');
end

nRows=13;
A=zeros(nRows,12);
for i=1:nRows
	[y,cn]=fscanf(fp,'%f %f %f %f %f %f %f %f %f %f %f %f',12);
	vwl=fscanf(fp,'%s',1)
	if cn==12
		A(i,:)=y';
	else
	 error('error in reading');
	end
end

size(A)


Dist=zeros(nRows,nRows);
Dist13=zeros(nRows,nRows);
Dist36=zeros(nRows,nRows);

SUBTRACTMEAN=1;

if SUBTRACTMEAN==1

  for i=1:13
	x=A(i,1:6);
	A(i,1:6)=A(i,1:6)-mean(x);
	x=A(i,7:12);
	A(i,7:12)=A(i,7:12)-mean(x);
  end

end

%--- Using the whole vector -----------------
fprintf('%s\n',hdr);
k=1;
for i=1:nRows
	fprintf('%s ',vls(k:k+1));
	k=k+2;
	for j=1:nRows
	   x11=A(i,1:6); x12=A(i,7:12);
	   x21=A(j,1:6); x22=A(j,7:12);
	   nrm1=norm(x11-x21,2)/6;
	   nrm2=norm(x12-x22,2)/6;
	   Dist(i,j)=0.5*(nrm1+nrm2);
	   fprintf('%4.2f  ',0.5*(nrm1+nrm2));
	end
 fprintf('\n')
end


%----Use the first 3 channels --------------
fprintf('\n-------------Using only the first 3 channels ----------\n\n');
fprintf('%s\n',hdr);
k=1;
for i=1:nRows
	fprintf('%s ',vls(k:k+1));
	k=k+2;
	for j=1:nRows
	   z11=A(i,1:3); z12=A(i,7:9);
	   z21=A(j,1:3); z22=A(j,7:9);
	   nrm1=norm(z11-z21,2)/3;
	   nrm2=norm(z12-z22,2)/3;
	   Dist13(i,j)=0.5*(nrm1+nrm2);
	   fprintf('%4.2f  ',0.5*(nrm1+nrm2));
	end	
 fprintf('\n')
end

%----Plot now------------------------
center= [0.3936,    0.6391,    1.0378,    1.6852,    2.7365,    4.4435];
center = 1000*center;

k=1;
for i=1:6
  fg=A(i,1:6);
  subplot(6,2,k),plot(center,fg,'-',center,fg,'o');
  ylabel(vls(k:k+1));
  axis([0 4500 min(fg)-2 max(fg)+2]);
  fg=A(i,7:12);
  subplot(6,2,k+1),plot(center,fg,'-',center,fg,'o');
  axis([0 4500 min(fg)-2 max(fg)+2]);
 k=k+2; 
end

figure(2)
j=k;
k=1; 
for i=7:13
   fg=A(i,1:6);
   subplot(7,2,k),plot(center,A(i,1:6),'-',center,A(i,1:6),'o');
   ylabel(vls(j:j+1));
   axis([0 4500 min(fg)-2 max(fg)+2]);

   fg=A(i,7:12); 
   j=j+2;  
   subplot(7,2,k+1),plot(center,A(i,7:12),'-',center,A(i,7:12),'o');
   axis([0 4500 min(fg)-2 max(fg)+2]);
 k=k+2;
end

return
%---Use the last 3 channels ----------------------------
fprintf('\n-------------Using only the last 3 channels ----------\n\n');
fprintf('%s\n',hdr);
k=1;
for i=1:nRows
	fprintf('%s ',vls(k:k+1));
	k=k+2;
	for j=1:nRows
	   x1=A(i,4:6); x2=A(j,4:6);
	   nrm2=norm(x1-x2,2)/3;
	   Dist36(i,j)=nrm2;
	   fprintf('%4.2f  ',nrm2);
	end
 fprintf('\n')
end

