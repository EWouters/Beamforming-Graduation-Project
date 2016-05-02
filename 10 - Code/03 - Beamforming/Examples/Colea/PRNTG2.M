function prntg(orientation)

global plavFig

figure(plavFig)


if strcmp(orientation,'landsc')==1
	set(plavFig,'PaperOrientation','Landscape')
	set(plavFig,'PaperPosition',[0.25 0.75 13 21]);
	print
elseif strcmp(orientation,'portr')==1
	set(plavFig,'PaperOrientation','Portrait')
	set(plavFig,'PaperPosition',[0.1 0.5 8.5 10]);
	print
elseif strcmp(orientation,'bwps')==1
	[pth,fname] = dlgopen('save','*.eps;*.ps');
 	if ((~isstr(fname)) | ~min(size(fname))), return; end	
	 fname1=[pth,fname];
	set(plavFig,'PaperPosition',[0.1 0.5 8.5 10]);
	eval(['print -deps ' fname1]);

elseif strcmp(orientation,'ceps')==1
	[pth,fname] = dlgopen('save','*.eps;*.ps');
 	if ((~isstr(fname)) | ~min(size(fname))), return; end	
	 fname1=[pth,fname];
	set(plavFig,'PaperPosition',[0.1 0.5 8.5 10]);
	eval(['print -depsc ' fname1]);
	

elseif strcmp(orientation,'bmp')==1
	[pth,fname] = dlgopen('save','*.bmp');
 	if ((~isstr(fname)) | ~min(size(fname))), return; end	
 	fname1=[pth,fname];
	set(plavFig,'PaperPosition',[0.1 0.5 8.5 10]);
	eval(['print -dbitmap ' fname1]);
end



