function crsrline(np,Ylim,button)

% Draws the cursor lines

% Copyright (c) 1995 Philipos C. Loizou
%

global TWOFILES TOP  hl hr doit
global htop hbot lastClick hwi frst1 frst0 doit0 doit1


if strcmp(button,'left')  % -- left mouse button was clicked
	if TWOFILES==1

		if TOP==1
			 if doit1==1 | frst0==1
	  			 hwi(1,1)=line('Xdata',[np np],'Ydata',Ylim,...% 'Linestyle','--',...
	   			'color','r','Erasemode','xor');
	 			 hwi(1,2)=line('Xdata',[np+4 np+4],'Ydata',Ylim,...%'Linestyle','--',...
	   			'color',[0 0 0],'Erasemode','xor');
	  		 	 frst0=0; 
				doit1=0; 
			else
	  			set(hwi(1,1),'Xdata',[np np],'Ydata',Ylim,'color','r');
			end
		else
		
			if doit0==1 | frst1==1
	  			 hwi(2,1)=line('Xdata',[np np],'Ydata',Ylim,...% 'Linestyle','--',...
	   			'color','r','Erasemode','xor');
	 			 hwi(2,2)=line('Xdata',[np+4 np+4],'Ydata',Ylim,...%'Linestyle','--',...
	   			'color',[0 0 0],'Erasemode','xor');
	  			 frst1=0; 
				 doit0=0;  
			else
	  			set(hwi(2,1),'Xdata',[np np],'Ydata',Ylim,'color','r');
			end
		end
	else
	
	 invalid=0;
	 eval('findobj(hl);','invalid=1;');
	 if doit==1 | invalid==1
	  hl=line('Xdata',[np np],'Ydata',Ylim,...% 'Linestyle','--',...
	   'color','r','Erasemode','xor');
	  hr=line('Xdata',[np+4 np+4],'Ydata',Ylim,'Linestyle','--',...
	   'color',[0 0 0],'Erasemode','xor');
	  
	 else
	  set(hl,'Xdata',[np np],'Ydata',Ylim,'color','r');
	 end
	end

elseif strcmp(button,'right') %---rigt button was clicked

	if TWOFILES==1
		if TOP==1
			 if doit1==1 | frst0==1
	  			 hwi(1,1)=line('Xdata',[np+4 np+4],'Ydata',Ylim,...% 'Linestyle','--',...
	   			'color',[0 0 0],'Erasemode','xor');
	 			 hwi(1,2)=line('Xdata',[np np],'Ydata',Ylim,... %'Linestyle','--',...
	   			'color','m','Erasemode','xor');
	  		 	frst0=0; doit1=0;
			else
	  			set(hwi(1,2),'Xdata',[np np],'Ydata',Ylim,'color','m');
			end
		else
		
			if doit0==1 | frst1==1
	  			 hwi(2,1)=line('Xdata',[np+4 np+4],'Ydata',Ylim,...% 'Linestyle','--',...
	   			'color',[0 0 0],'Erasemode','xor');
	 			 hwi(2,2)=line('Xdata',[np np],'Ydata',Ylim,... %'Linestyle','--',...
	   			'color','m','Erasemode','xor');
	  			frst1=0; doit0=0;
			else
	  			set(hwi(2,2),'Xdata',[np np],'Ydata',Ylim,'color','m');
			end
		end
	else

	invalid=0;
	eval('findobj(hr);','invalid=1;');
	if doit==1 | invalid==1 
	  hl=line('Xdata',[np+4 np+4],'Ydata',Ylim,'Linestyle','-',...
	     'color',[0 0 0],'Erasemode','xor');
	 hr=line('Xdata',[np np],'Ydata',Ylim,'Linestyle','--',...
	   'color','m','Erasemode','xor');
	else
	  set(hr,'Xdata',[np np],'Ydata',Ylim,'color','m');
	end
       end	
     end
