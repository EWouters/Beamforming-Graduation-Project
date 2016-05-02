function closem(type)

% Copyright (c) 1995 Philipos C. Loizou
%

global  pFig anFig aFig f1Fig hFig vFig sFig spFig smspEc
global  filtFig ftrFig tf yaxF clsWin amFig clsedFrm shaFig sinF
global  labFig eFig glFig recFig

if strcmp(type,'dig')
	delete(pFig)
	pFig=[];
elseif strcmp(type,'an')
	delete(anFig)
	anFig=[];
elseif strcmp(type,'f0f1f2') % F0F1F2 or MPEAK
	delete(f1Fig)
	f1Fig=[];
	clsWin=1;
	delete(amFig);
	amFig=[];
elseif strcmp(type,'house')
	delete(hFig)
	hFig=[];
elseif strcmp(type,'vienna')
	delete(vFig)
	vFig=[];
elseif strcmp(type,'smsp')
	delete(sFig)
	sFig=[];
	delete(spFig);
	spFig=[];
	smspEc=0;
elseif strcmp(type,'filtFig')
	delete(filtFig)
	filtFig=[];
elseif strcmp(type,'ftr')
	delete(ftrFig)
	ftrFig=[];
	clsedFrm=1; % create buttons again
elseif strcmp(type,'tf') % Text window
	delete(tf)
	tf=[];
elseif strcmp(type,'yaxF') % Y-axis window
	delete(yaxF)
	yaxF=[];
elseif strcmp(type,'anls')
	delete(aFig);
	aFig=[];
elseif strcmp(type,'shan')
	delete(shaFig);
	shaFig=[];
elseif strcmp(type,'sinF') %-- sinewave generator ---
	delete(sinF);
	sinF=[];
elseif strcmp(type,'labFig') % Label tool
	delete(labFig);
	labFig=[];
elseif strcmp(type,'efig') % Pitch contour figure
	delete(eFig);
	eFig=[];
elseif strcmp(type,'glfig') % Glottal wave figure
	delete(glFig);
   glFig=[];
elseif strcmp(type,'recFig') % Glottal wave figure
	delete(recFig);
	recFig=[];
   
end
