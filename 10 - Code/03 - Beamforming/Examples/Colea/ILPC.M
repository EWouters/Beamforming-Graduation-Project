function [a,rx] = ilpc(x,p) 


 E = zeros(p+1,1);	% Energy vector
 alpha=zeros(p,p);
 

 R = autoc(x,p);        % compute the autocorrelation sequence R(i)
 rx=R;

 E(1)=R(1);		% energy of signal x(n)
 sumaR=0;
 
 for i=1:p  % ========= start recursion ========

      
   if i>1
     sumaR =alpha(1:i-1,i-1)'* R(i:-1:2)';	
   end
  
   ki=-(R(i+1) + sumaR)/E(i);
   

   if abs(ki) >= 1, fprintf('Warning! Unstable LPC filter..\n\n'); end;

   alpha(i,i)=ki;

	     if i>1
        alpha(1:i-1,i)=alpha(1:i-1,i-1)+ki*alpha(i-1:-1:1,i-1);
     end

   E(i+1) = (1 - ki*ki)*E(i);
   
 end  % ========= end of recursion =========



a = [1; alpha(:,p)];		  % Linear prediction coefficients

%Ep = E(p+1);           % --- residual error -- Ep = R(1) + R(2:p+1)*a 
  



