function prnt(orientation)

global fno

figure(fno)


if strcmp(orientation,'landsc')==1
	set(fno,'PaperOrientation','Landscape')
	set(fno,'PaperPosition',[0.25 1.5 11 7]);
else
	set(fno,'PaperOrientation','Portrait')
	set(fno,'PaperPosition',[0.25 1.5 8 8]);
end

print

