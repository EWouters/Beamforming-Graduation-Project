function dst = distance(x,y,N,type,opt)

% DISTANCE - distance computation y = distance(x,y,N,type,option)
%
% This function computes the distance between vectors x and y.
% The following distance measures are supported:
%  cep    - Cepstrum
%  wcep   - Weighted cepstrum (by a ramp)
%  snr    - Signal to noise ratio
%  IS     - Itakura-Saito
%  LR	    - Likelihood ratio
%  LLR    - log-likelihood ratio
%  WLR    - Weighted likelihood ratio
%  KLATT  - Weighted slope distance metric (Klatt's)
%
% Copyright (c) 1998 by Philipos C. Loizou
%
%

global Srate Bklatt Aklatt als bls centKlatt zi1 zi2 zi11 zi22 
global curFig Srate2

DBG=0;
if nargin==5, 
 if strcmp(opt,'single')
   DISP=1;
   if isempty(curFig)
	curFig=figure('Position',get(0,'DefaultFigurePosition'),...
		'NumberTitle','Off');
   end
 else	
   DBG=2; DISP=0;
 end 
else 
   DBG=0; 
end;



if strcmp(type,'cep') | strcmp(type,'wcep') % ========== cepstrum ==========

  cx1 = rceps(x);
  cy1 = rceps(y');
 
  cx=cx1(2:N+1); cy=cy1(2:N+1);
  
  if strcmp(type,'wcep') % weighted cepstrum distance
    weigts=1:N;
    cx=cx.*weigts';
    cy=cy.*weigts';
  end 
    
  x1 = norm(cx-cy,2);
 
  dst = x1*x1; 

     if DISP==1,  % ---------- plot the smoothed spectra----------- 
	figure(curFig);
	lenx=length(x);
	fr=Srate/lenx;
	freq=0:fr:(Srate/2-fr); 
	seg=zeros(1,lenx); seg(1)=cx1(1);
	seg(2:N+1)=cx; seg(lenx-N+1:lenx)=flipud(cx);
	mag=fft(seg); 
	subplot(2,1,1),plot(freq,real(mag(1:lenx/2))); 
		title (['ceps= ', sprintf('%f',dst)]);
	ylabel('Magnitude (dB)');
	seg=zeros(1,lenx); seg(1)=cy1(1);
	seg(2:N+1)=cy; seg(lenx-N+1:lenx)=flipud(cy);
	mag=fft(seg); 
	subplot(2,1,2),plot(freq,real(mag(1:lenx/2)));
	set(curFig,'Name','Cepstrum ');
	ylabel('Magnitude (dB)');
	
      end

elseif strcmp(type,'snr') % ========== SNR ==============

  er= norm(x-y',2);
  eg= norm(x,2);
  
  dst= 10*log10(eg*eg/(er*er));

   if DISP==1, 
	figure(curFig);
	subplot(2,1,1),plot(x); title(['SNR= ', sprintf('%f',dst)]);
	ylabel('Amplitude');
	subplot(2,1,2),plot(y);
	set(curFig,'Name','SNR'); 
	ylabel('Amplitude'); xlabel('Sample');
   end
else % ============== LPC-based measures ===========================

 if strcmp(type,'KLATT') ==0 % if its the KLATT measure, dont bother
  [ax,rx] = ilpc(x,N);
  [ay,ry] = ilpc(y,N);
 end
 
  
  if DISP==1 & strcmp(type,'KLATT') ==0
	figure(curFig);
	[h1,f]=freqz([1],ax,512,Srate);
	[h2,f]=freqz([1],ay,512,Srate2);
	subplot(2,1,1),plot(f,20*log10(abs(h1))); 
	ylabel('Magnitude (dB)');
	subplot(2,1,2),plot(f,20*log10(abs(h2))); 
	ylabel('Magnitude (dB)'); xlabel ('Frequency (Hz)');
	set(curFig,'Name','LPC-based measure'); 
   end

  
   

 if strcmp(type,'LLR') % ========== Log Likelihood Ratio ==========
 
     rx = rx/rx(1);
     ry = ry/ry(1);

     R =toeplitz(rx);
     num = ay'*R*ay;
     den = ax'*R*ax;

     dst = log(num/den); 
     if DISP==1, figure(curFig); subplot(2,1,1);
		 title(['LLR= ', sprintf('%f',dst)]);
     end		
  elseif strcmp(type,'LR') % ========== Likelihood Ratio ==========
 
     rx = rx/rx(1);
     ry = ry/ry(1);

     R =toeplitz(rx);
     num = ay'*R*ay;
     den = ax'*R*ax;

     dst = num/den-1; 
     if DISP==1, figure(curFig); subplot(2,1,1);
		 title(['LR= ', sprintf('%f',dst)]);
     end	
  elseif strcmp(type,'IS') % ========== Itakura-Saito ==========

     gx = ax'*rx'; % sigma^2
     gy = ay'*ry';

     R =toeplitz(rx);
     num = ay'*R*ay;
     den = ax'*R*ax;
     dst = gx*num/(gy*den)+log(gy/gx)-1; 
     
     if DISP==1, figure(curFig); subplot(2,1,1);
		 title(['Itak-Saito= ', sprintf('%f',dst)]);
     end	
 elseif strcmp(type,'WLR') % ======== Weighted Likelihood Ratio ==========
 
     cx1 = rceps(x);
     cy1 = rceps(y');
     cx=cx1(2:N+1); cy=cy1(2:N+1);
     rx1 = rx(2:N+1)/rx(1);
     ry1 = ry(2:N+1)/ry(1);
 
     term = (rx1-ry1)'.*(cx-cy);
     dst=sum(term);	if isnan(dst), rx1, ry1, cx, cy, end;
     if DISP==1, figure(curFig); subplot(2,1,1);
		 title(['WLR= ', sprintf('%f',dst)]);
     end	

  elseif strcmp(type,'KLATT') % ============= KLATT ==============

    nCh=24; FS=Srate/2; nOrd=6;
    if isempty(Bklatt)  % -------- design the mel-spaced filters -----
	
	[bls,als]=butter(8,200/FS);  % Low-Pass filter
	low=zeros(1,nCh); up=zeros(1,nCh);
	centKlatt=zeros(1,nCh);
	[low,centKlatt,up]=mel(nCh,100,FS-500);	
	Aklatt=zeros(nCh,nOrd+1); Bklatt=zeros(nCh,nOrd+1); 
	
 
	 for i=1:nCh
		W1=[low(i)/FS, up(i)/FS];
		if i==nCh &  FS<up(i)
		  [b,a]=butter(6,W1(1),'high');
		else
		  [b,a]=butter(3,W1);
		end
		Bklatt(i,:)=b;  
		Aklatt(i,:)=a;   
 
	  	if DBG==1
	   	  	[h1,f]=freqz(b,a,512,Srate);
	   		plot(f,20*log10(abs(h1)));
	   		axis([0 FS -40 2]);
	   		hold on
	  	end
	end
	
        zi1=zeros(nCh,nOrd); % zero conditions for filters.Very important !!!!
        zi2=zeros(nCh,8);
        zi11=zeros(nCh,nOrd);
        zi22=zeros(nCh,8);

 end %-----------end of filter design------------------

    if DISP==1
        zi1=zeros(nCh,nOrd); % zero conditions for filters.
        zi2=zeros(nCh,8);
        zi11=zeros(nCh,nOrd);
        zi22=zeros(nCh,8);
    end
    
   
    
    FilterBanks_x=zeros(1,nCh);
    FilterBanks_y=zeros(1,nCh);
    for i=1:nCh
       [x1,zf1]=filter(Bklatt(i,:),Aklatt(i,:),x,zi1(i,:));
       [x2,zf2]=filter(bls,als,abs(x1'),zi2(i,:));
       FilterBanks_x(i)=10*log10(norm(x2,2));
       zi1(i,:)=zf1'; zi2(i,:)=zf2'; % set final filter states to initial states

       [y1,zf11]=filter(Bklatt(i,:),Aklatt(i,:),y,zi11(i,:));
       [y2,zf22]=filter(bls,als,abs(y1'),zi22(i,:));
       FilterBanks_y(i)=10*log10(norm(y2,2));
        zi11(i,:)=zf11'; zi22(i,:)=zf22'; % set final filter states to initial state
     end


    % --- now, compute spectral slope differences (Klatt, ICASSP 82, p.1278) -----------
    %
    sl_x=diff(FilterBanks_x);
    sl_y=diff(FilterBanks_y);
    differnce=(sl_x-sl_y).*(sl_x-sl_y);
    weights=ones(1,nCh-1);
    
    dst = sum(weights .* differnce);
    dst = dst/(nCh-1);

    if DISP==1
	mx=max(max(FilterBanks_x),max(FilterBanks_y));
	mn=min(min(FilterBanks_x),min(FilterBanks_y));
  	figure(curFig);
   	a=lpc(x,14);
   	[h1,f]=freqz([1],a,512,Srate);
	magn=20*log10(abs(h1));
   	subplot(3,1,1),plot(f,magn);
   	axis([0 centKlatt(nCh) min(magn)-1 max(magn)+1]);
	ylabel('Magnitude (dB)');
	title(['WSM= ', sprintf('%f',dst)]);
   	subplot(3,1,2),plot(centKlatt,FilterBanks_x);
	axis([0 centKlatt(nCh) mn-1 mx+1]);
	ylabel('Magnitude (dB)');
	subplot(3,1,3)
	plot(centKlatt,FilterBanks_y);
	axis([0 centKlatt(nCh) mn-1 mx+1]);
	%plot(centKlatt(1:14),sl_x(1:14),'r-');
	ylabel('Magnitude (dB)');
	xlabel('Frequency (Hz)');
 	set(curFig,'Name','Klatt');
     end  

   else
     fprintf('ERROR! Unknown option in distance computation.\n');
  end


 

end % of if cepstrum

 
