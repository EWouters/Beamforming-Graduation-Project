function prnt2(orientation)

global fFig

figure(fFig)


if strcmp(orientation,'landsc')==1
	set(fFig,'PaperOrientation','Landscape')
	set(fFig,'PaperPosition',[0.25 0.75 13 21]);
	print
elseif strcmp(orientation,'portr')==1
	set(fFig,'PaperOrientation','Portrait')
	set(fFig,'PaperPosition',[0.25 1.5 8 8]);
	print
elseif strcmp(orientation,'bwps')==1
	[pth,fname] = dlgopen('save','*.eps;*.ps');
 	if ((~isstr(fname)) | ~min(size(fname))), return; end	
	 fname1=[pth,fname];
	set(fFig,'PaperPosition',[0.25 1.5 8 8]);
	eval(['print -deps ' fname1]);

elseif strcmp(orientation,'ceps')==1
	[pth,fname] = dlgopen('save','*.eps;*.ps');
 	if ((~isstr(fname)) | ~min(size(fname))), return; end	
	 fname1=[pth,fname];
	set(fFig,'PaperPosition',[0.25 1.5 8 8]);
	eval(['print -depsc ' fname1]);
	

elseif strcmp(orientation,'bmp')==1
	[pth,fname] = dlgopen('save','*.bmp');
 	if ((~isstr(fname)) | ~min(size(fname))), return; end	
 	fname1=[pth,fname];
	set(fFig,'PaperPosition',[0.25 1.5 8 8]);
	eval(['print -dbitmap ' fname1]);

elseif strcmp(orientation,'clip')==1
	figure(fFig);
	set(fFig,'PaperPosition',[0.25 1.5 6 6]);
	eval(['print -dbitmap ']);

elseif strcmp(orientation,'wmf')==1
	[pth,fname] = dlgopen('save','*.wmf');
 	if ((~isstr(fname)) | ~min(size(fname))), return; end	
 	fname1=[pth,fname];
	%set(fFig,'PaperPosition',[0.25 1.5 8 8]);
	eval(['print -dmeta ' fname1]);
end



