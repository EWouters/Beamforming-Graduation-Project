function setchan(numch)

% Copyright (c) 1995 by Philipos C. Loizou
%

global ChanpUp nChannels S0 filterWeights LowFreq UpperFreq fftSize Srate
global center filterA filterB pFig ratePps anFig aFig TWOFILES DiffSrate
global filterA2 filterB2 Srate2 TOP FILT_TYPE


if nargin==0

	x = get(ChanpUp,'Value');

	if (x > 1)

	  if (x<7)
		nChannels=x+1;
  	  else
  		nChannels=2*(x-3);
  	  end
	else
	  return;
	end
else
    	nChannels=numch;
end


if strcmp(FILT_TYPE,'broad')% =========== Broadband filters ==========

   nOrd=6;
   [filterA,filterB]=filtdesi('broad',Srate,nChannels,nOrd);

elseif strcmp(FILT_TYPE,'narrow') % ============ Narrowband ==============

   nOrd=12;
   [filterA,filterB]=filtdesi('narrow',Srate,nChannels,nOrd);

end



% =============== if there are two files ==========================
%
 if TWOFILES==1
       if DiffSrate==0 % same sfreq, no need to redesign
	 filterA2=zeros(nChannels,nOrd+1); 
         filterB2=zeros(nChannels,nOrd+1);
	 filterA2=filterA; filterB2=filterB;
       else
	
	  if strcmp(FILT_TYPE,'broad')% 
	   [filterA2,filterB2]=filtdesi('broad',Srate2,nChannels,nOrd);
          elseif strcmp(FILT_TYPE,'narrow') % 
           [filterA2,filterB2]=filtdesi('narrow',Srate2,nChannels,nOrd);
          end
       end
  end
 
% ===============================================================
if (S0 > 0)
 	pllpc(S0);

	if ~isempty(pFig) 
	   pulse(ratePps);
	end
	if ~isempty(anFig)
		analog('noLPF')
	end
	if ~isempty(aFig)
		analysis(ratePps);
	end
   end

  






