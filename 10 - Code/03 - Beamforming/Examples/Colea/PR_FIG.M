function cprint(otype,cmd,nfiles)

% Prints the image so it fills up the page, with orientation 'otype'
%


TWOFILES=str2num(nfiles);

fig = gcf; 
if TWOFILES==0, ax = gca;   end;

if TWOFILES==1
	child=get(gcf,'Children');
	htop=child(2);
	hbot=child(1);
end



%---- Save original settings  ---

ornt = get(fig, 'PaperOrientation');
if strcmp(otype,'landscape')
  orient('landscape');
else
  orient('portrait');
end

if TWOFILES==1
 aunit_t=get(htop,'Units'); apos_t=get(htop,'Position');
 aunit_b=get(hbot,'Units'); apos_b=get(hbot,'Position');
elseif TWOFILES==0
 aunit = get(ax,  'Units');
 apos  = get(ax,  'Position');
end

punit = get(fig, 'PaperUnits');
ppos  = get(fig, 'PaperPosition');


if TWOFILES==0
 set(ax,  'Units',      'inches'); 
 set(ax,  'Units',      'pixels'); 
end

set(fig, 'Units',      'pixels');
set(fig, 'PaperUnits', 'inches');

printsize = get(fig, 'PaperSize');				


% --- set up the margins, depending on orientation ----
%
 if strcmp(otype,'landscape')
	margins= [0.0896    0.1071    0.8182    0.8235];
 else
	margins= [0.1163    0.1511    0.8235    0.8455];
 end 							


	
set(fig, 'PaperPosition', [0 0 printsize]);

if TWOFILES==0  
  set(ax,'Units','normalized','Position',margins);
 else
  set(htop,'Units','normalized','Position',[0.13 0.58 0.775 0.34]);
  set(hbot,'Units','normalized','Position',[0.13 0.17 0.775 0.34]);
 end

 % ...... now ready to print ----------------
 %
  drawnow('discard');
%  set(fno, 'Pointer', 'watch');
  
  if strcmp(cmd, 'printer') % --------send to printer

     print -dwin 

  elseif strcmp(cmd,'eps') %--------- save as postscript file

    [pth,fname] = dlgopen('save','*.eps;*.ps');
    if ((~isstr(fname)) | ~min(size(fname))),
	% ---- Restore original settings -------------
	%
	set(fig, 'Pointer', 'crosshair');

	if TWOFILES==0
  		set(ax,  'Units', aunit);
  		set(ax,  'Position', apos);
	else
   		set(htop,  'Units', aunit_t); set(htop,'Position',apos_t);
   		set(hbot,  'Units', aunit_b); set(hbot,'Position',apos_b);
  
	end

	set(fig, 'PaperUnits', punit);
	set(fig, 'PaperPosition', ppos);
	set(fig, 'PaperOrientation', ornt); 
	return; 
    end	
    fname1=[pth,fname];
    eval(['print -deps ', fname1]);

  elseif strcmp(cmd,'meta')%--------- save as Windows metafile

   [pth,fname] = dlgopen('save','*.wmf');
    if ((~isstr(fname)) | ~min(size(fname))), return; end	
    fname1=[pth,fname];
    eval(['print -dmeta ', fname1]);

  end




% ---- Restore original settings -------------
%
set(fig, 'Pointer', 'crosshair');

if TWOFILES==0
  set(ax,  'Units', aunit);
  set(ax,  'Position', apos);
else
   set(htop,  'Units', aunit_t); set(htop,'Position',apos_t);
   set(hbot,  'Units', aunit_b); set(hbot,'Position',apos_b);
  
end

set(fig, 'PaperUnits', punit);
set(fig, 'PaperPosition', ppos);
set(fig, 'PaperOrientation', ornt);

