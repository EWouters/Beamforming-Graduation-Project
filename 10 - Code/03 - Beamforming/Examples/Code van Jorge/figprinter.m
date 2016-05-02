function figprinter(fig_hand,filename,varargin)
%FIGPRINTER: Prints a figure as a high quality .eps file, optimizing it for 
%             publication with optionally embedded fonts.
%
%usage: FIGPRINTER(figure_handle,filename,...)
%
%Input arguments:
%
%  figure_handle 	Handle to the figure to print.
%
%  filename		Full path and name of the eps file to be created. If 
%			the extension ".eps" is not found in the name, it will 
%			be automatically appended.
%
%Optional input arguments (specified as property/value pairs):
%
%  Embedfonts		Boolean argument to specify if the eps file should be 
%			created with fonts embedded in it. 
%			WARNING: Setting this parameter to 'true' breaks eps
%			compatibility with latex package psfrag.
%			DEFAULT: 'false'.
%
%  Forcepainters	Boolean argument to especify if the painters renderer
%			is has to be used. When true FIGPRINT does not try
%			to find and separate bitmap and vector graphics
%			elements, printing the figure directly as a vector
%			graphics eps file.
%			DEFAULT: 'false'.
%
%  BitMapRenderer	Text string specifing the name of the renderer to use
%			to render bitmap elements.
%			Possible values are: '-zbuffer' and '-opengl'. Please
%			refer to these in the MATLAB documentation for a
%			comprehensive description of their printing 
%			capabilities and differences. 
%			DEFAULT: '-zbuffer'.
%
%  BMres		Text string indicating the resolution in dots per inch 
%			(dpi) of the generated bitmap part of the figure.
%			Example values:	'-r300' to print at 300 dpi.
%					'-r600' to print at 600 dpi.
%			Please refer to the MATLAB documentation (e.g., the
%			help file of the PRINT function) for possible values.
%			DEFAULT: '-r300'.
%
%MOTIVATION:
%
%	One commonly encountered problem while preparing high quality plots and 
%	figures for publication purposes is that MATLAB can either print/save a
%	figure as a vector graphics file (i.e. text is rendered as text and
%	lines and other polygons as vector instructions), or as a bitmap file
%	(i.e. all text and lines are converted to pixels and save as flat
%	images). 
%
%	High quality figures are preferably vector graphics, as these can scale
%	indefinitely and can be printed on paper at any resolution without
%	distortion. In general they are also smaller in size in comparison to
%	bitmap images. However, if the figure contains complex plots like those 
%	generated by surf or mesh, then saving/printing to a vector graphics 
%	file results in large files and long compile times when adding these to 
%	a latex generated document. Moreover, if the figure contains bitmaps 
%	(e.g. when importing an image) then it cannot, by nature, be 
%	saved/printed as a vector graphics file.
%
%	FIGPRINTER by default tries to smartly separate vector graphic elements
%	(e.g., text and lines) from bitmap and other complex vector elements 
%	in the figure. It renders these separated elements into one purely 
%	vector graphics eps file and one purely bitmap eps file, to later 
%	combine both files. In this way, figures containing bitmaps or complex 
%	surface or mesh plots are printed as bitmaps into an eps file that 
%	still has all text, axes and lines rendered correctly as vector 
%	graphics elements. Moreover, figprinter performs some optimization
%	tricks, like tightly cropping of the eps bounding box. This results in 
%	high quality, tightly bounded, and small figure eps files.
%	
%	Optionally, FIGPRINTER can embed all fonts into the resulting eps
%	file. This is a handy feature as some editorials require fonts to be
%	embedded in all figures.
%
%Version:  20141008, tested on MATLAB R2014a.
%Copyleft: Jorge Martinez (J.A.MartinezCastaneda@TuDelft.nl).
%	"I created this function by copying and adapting pieces of many 
%	functions from different sources. Due to a sloppy start I have 
%	unfortunately lose track on all the people I should acknowledge. In 
%	some parts of the code you can still find the corresponding copyright."


if nargin < 2
	help figprinter
	return
end

%Grab the operating system platform we are using.
arch = computer;
arch = arch(1:3);

params.BitMapRenderer = '-zbuffer';
params.BMres = '-r300';
params.Forcepainters = false;
params.Embedfonts=false;

params=parseparams(params,varargin);

embedfonts=params.Embedfonts;
forcepainters=params.Forcepainters;
BMres=params.BMres;
BitMapRenderer=params.BitMapRenderer;

% Construct filenames
if ~strcmpi(filename(end-3:end), '.eps')
    filename = [filename '.eps']; % Add the missing extension
end
tfile1 = [tempname '.eps'];
tfile2 = [tempname '.eps'];
tfile3 = [tempname '.eps'];
tfile4 = [tempname '.pdf'];

allLines	= findall(fig_hand, 'type', 'line');
allText		= findall(fig_hand, 'type', 'text');
allAxes		= findall(fig_hand, 'type', 'axes');
allImages	= findall(fig_hand, 'type', 'image');
allLights	= findall(fig_hand, 'type', 'light');
allPatch	= findall(fig_hand, 'type', 'patch');
allSurf		= findall(fig_hand, 'type', 'surface');
allRect		= findall(fig_hand, 'type', 'rectangle');
allLegend	= findall(fig_hand, 'type', 'axes','tag','legend');
allColorbar	= findall(fig_hand, 'type', 'axes','tag','Colorbar');
	
allAxes = setdiff(allAxes,allColorbar);
	
allNonVector= [allLights; allPatch; allImages; allSurf];
allVector = [allText; allLines; allRect; allLegend];

% SET FIGURE COLOR TO WHITE %%%%%%%%%%%%%%%%%%%%%%
olfc=get(fig_hand,'Color');
set(fig_hand,'Color','w');
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


if forcepainters || isempty(allNonVector)
    % Force the painters renderer
    print(fig_hand,'-loose','-depsc2','-painters','-r864',tfile3);
else

	% ERASE ALL VECTOR ELEMENTS %%%%%%%%%%%%%%%%%%%%%%%
	oldtvis = get(allVector,'Visible');
	if ~iscell(oldtvis)
		oldtvis={oldtvis};
	end
	nullvar = cell(length(oldtvis),1);
	[nullvar{:}] = deal('off');
	set(allVector,{'Visible'},nullvar);
	% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
	% ERASE AXES TICK LABELS %%%%%%%%%%%%%%%%%%%%%%%%%%
	oldaxtl = get(allAxes,'XTickLabel');
	oldaytl = get(allAxes,'YTickLabel');
	oldaztl = get(allAxes,'ZTickLabel');
	
	if ~iscell(oldaxtl)
		oldaxtl={oldaxtl};
		oldaytl={oldaytl};
		oldaztl={oldaztl};
	end
	
	nullvar = cell(length(oldaxtl),1);
	[nullvar{:}] = deal([]);

	set(allAxes,{'XTickLabel'},nullvar);
	set(allAxes,{'YTickLabel'},nullvar);
	set(allAxes,{'ZTickLabel'},nullvar);
	% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	% ERASE COLORBAR AXES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	if ~isempty(allColorbar)
		oldcxt = get(allColorbar,'XTick');
		oldcyt = get(allColorbar,'YTick');
		oldczt = get(allColorbar,'ZTick');

		if ~iscell(oldcxt)
			oldcxt={oldcxt};
			oldcyt={oldcyt};
			oldczt={oldczt};
		end
	
		nullvar = cell(length(oldcxt),1);
		[nullvar{:}] = deal([]);

		set(allColorbar,{'XTick'},nullvar);
		set(allColorbar,{'YTick'},nullvar);
		set(allColorbar,{'ZTick'},nullvar);


		oldcxc=get(allColorbar,'Xcolor');
		oldcyc=get(allColorbar,'Ycolor');
		oldczc=get(allColorbar,'Zcolor');

		if ~iscell(oldcxc)
			oldcxc={oldcxc};
			oldcyc={oldcyc};
			oldczc={oldczc};
		end

		[nullvar{:}] = deal('w');

		set(allColorbar,{'Xcolor'},nullvar);
		set(allColorbar,{'Ycolor'},nullvar);
		set(allColorbar,{'Zcolor'},nullvar);
	end
	% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	% PRINT THE BITMAP PART OF THE FIGURE %%%%%%%%%%%%
	print(fig_hand,BitMapRenderer,'-depsc',BMres,tfile1);
	% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




	% RESTORE ALL VECTOR ELEMENTS %%%%%%%%%%%%%%%%%%%%
	set(allVector,{'Visible'},oldtvis);
	% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	% RESTORE AXES TICK LABELS %%%%%%%%%%%%%%%%%%%%%%%
	set(allAxes,{'XTickLabel'},oldaxtl);
	set(allAxes,{'YTickLabel'},oldaytl);
	set(allAxes,{'ZTickLabel'},oldaztl);
	% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
	% RESTORE COLORBAR AXES %%%%%%%%%%%%%%%%%%%%%%%%%%
	if ~isempty(allColorbar);
		set(allColorbar,{'XTick'},oldcxt);
		set(allColorbar,{'YTick'},oldcyt);
		set(allColorbar,{'ZTick'},oldczt);
		set(allColorbar,{'Xcolor'},oldcxc);
		set(allColorbar,{'Ycolor'},oldcyc);
		set(allColorbar,{'Zcolor'},oldczc);
	end
	% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	% ERASE ALL BITMAP ELEMENTS %%%%%%%%%%%%%%%%%%%%%%
	oldvis = get(allNonVector,'Visible');
	
	if ~iscell(oldvis)
		oldvis={oldvis};
	end
	nullvar = cell(length(allNonVector),1);
	[nullvar{:}] = deal('off');
	set(allNonVector,{'Visible'},nullvar);
	% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	% ERASE AXES GRID %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	oldaxg = get(allAxes,'XGrid');
	oldayg = get(allAxes,'YGrid');
	oldazg = get(allAxes,'ZGrid');
	
	if ~iscell(oldaxg)
		oldaxg={oldaxg};
		oldayg={oldayg};
		oldazg={oldazg};
	end
	nullvar = cell(length(oldaxg),1);
	[nullvar{:}] = deal('off');
	
	set(allAxes,{'XGrid'},nullvar);
	set(allAxes,{'YGrid'},nullvar);
	set(allAxes,{'ZGrid'},nullvar);
	% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
	% SET AXES AND COLORBAR COLOR TO NONE %%%%%%%%%%%
	oldc   = get(allAxes,'Color');
	if ~iscell(oldc)
		oldc = {oldc};
	end
	nullvar = cell(length(oldc),1);
	[nullvar{:}] = deal('none');
	set(allAxes,{'Color'},nullvar);
	
	if ~isempty(allColorbar)
		oldcc = get(allColorbar,'Color');
		if ~iscell(oldcc)
			oldcc = {oldcc};
		end
		nullvar = cell(length(oldcc),1);
		[nullvar{:}] = deal('none');
		set(allColorbar,{'Color'},nullvar);
	end
	% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
	% PRINT THE VECTOR PART OF THE FIGURE %%%%%%%%%%%%
	set(fig_hand,'Color','none','Inverthardcopy','off');

	print(fig_hand,'-depsc2','-r864','-painters',tfile2);
	% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




	% RESTORE ALL BITMAP ELEMENTS %%%%%%%%%%%%%%%%%%%%
	set(allNonVector,{'Visible'},oldvis);
	% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	% RESTORE AXES GRID %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	set(allAxes,{'XGrid'},oldaxg);
	set(allAxes,{'YGrid'},oldayg);
	set(allAxes,{'ZGrid'},oldazg);
	% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	% RESTORE AXES AND COLORBAR COLOR %%%%%%%%%%%%%%%%
	set(allAxes,{'Color'},oldc);
	if ~isempty(allColorbar)
		set(allColorbar,{'Color'},oldcc);
	end
	% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	


	combine_eps(tfile2,tfile1,tfile3);

	%Delete temporary files
	delete(tfile2);
	delete(tfile1);
end

% RESTORE FIGURE COLOR %%%%%%%%%%%%%%%%%%%%%%%%%%%
set(fig_hand,'Color',olfc);
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


fix_lines(tfile3);

if embedfonts
	% Construct the command string for ghostscript. This assumes that the
	% ghostscript binary is on your path - you can also give the complete path,
	% e.g. cmd = '"C:\Program Files\gs\gs8.63\bin\gswin32c.exe"';
	cmd = 'gs';
	switch arch
		case 'PCW'
			cmd = [cmd 'win32c.exe'];
			cmd = [cmd ' -q -dEmbedAllFonts -dNOPAUSE -dBATCH -dEPSCrop -sDEVICE=pdfwrite -dPDFSETTINGS=/prepress -sOutputFile="' tfile4 '" -f "' tfile3 '"'];
		case 'GLN'
			cmd = [cmd 'figprinter.sh "' tfile4 '" "' tfile3 '"'];
		case 'MAC'
			cmd = [cmd ' -q -dEmbedAllFonts -dNOPAUSE -dBATCH -dEPSCrop -sDEVICE=pdfwrite -dPDFSETTINGS=/prepress -sOutputFile="' tfile4 '" -f "' tfile3 '"'];
		otherwise
			error('Wrong architecture type');
	end

	% Convert to pdf, embedding fonts and compressing images
	result = system(cmd);

	%Delete temporary files
	delete(tfile3);

	% Exit now if unsuccessful in creating the pdf
	if result
		return
	end

	% Construct the command string for pdftops. This assumes that the
	% pdftops binary is on your path - you can also give the complete path,
	% e.g. cmd = '"C:\Program Files\xpdf\pdftops.exe"';
	cmd = ['pdftops -q -paper match -eps -level2 "' tfile4 '" "' filename '"'];
	oldenv=getenv('LD_LIBRARY_PATH');
	setenv('LD_LIBRARY_PATH','');

	% Convert the pdf back to eps
	system(cmd);
	setenv('LD_LIBRARY_PATH',oldenv);
	%Delete temporary files
	delete(tfile4);
else
	switch arch
		case 'PCW'
			system(['move ' tfile3  ' ' filename ]);
		case 'GLN'
			system(['mv ' tfile3  ' "' filename '"']);
		case 'MAC'
			system(['mv ' tfile3  ' "' filename '"']);
		otherwise
			error('Wrong architecture type');
	end

end

% Fix the DSC error created by pdftops
fixdscerror(filename);

%Trim the EPS bounding box to fit the figure contents thightly.
trim2epsbbox(filename);

return
end


function fix_lines(fname)
% Improve the style of lines used and set grid lines to an entirely new
% style using dots, not dashes

% Read in the file
fh = fopen(fname, 'rt');
fstrm = char(fread(fh, '*uint8')');
fclose(fh);

% Make sure all line width commands come before the line style definitions,
% so that dash lengths can be based on the correct widths
% Find all line style sections
ind = [regexp(fstrm, '[\n\r]SO[\n\r]'),... % This needs to be here even though it doesn't have dots/dashes!
       regexp(fstrm, '[\n\r]DO[\n\r]'),...
       regexp(fstrm, '[\n\r]DA[\n\r]'),...
       regexp(fstrm, '[\n\r]DD[\n\r]')];
ind = sort(ind);
% Find line width commands
[ind2, ind3] = regexp(fstrm, '[\n\r]\d* w[\n\r]', 'start', 'end');
% Go through each line style section and swap with any line width commands
% near by
b = 1;
m = numel(ind);
n = numel(ind2);
for a = 1:m
    % Go forwards width commands until we pass the current line style
    while b <= n && ind2(b) < ind(a)
        b = b + 1;
    end
    if b > n
        % No more width commands
        break;
    end
    % Check we haven't gone past another line style (including SO!)
    if a < m && ind2(b) > ind(a+1)
        continue;
    end
    % Are the commands close enough to be confident we can swap them?
    if (ind2(b) - ind(a)) > 8
        continue;
    end
    % Move the line style command below the line width command
    fstrm(ind(a)+1:ind3(b)) = [fstrm(ind(a)+4:ind3(b)) fstrm(ind(a)+1:ind(a)+3)];
    b = b + 1;
end

% Find any grid line definitions and change to GR format
% Find the DO sections again as they may have moved
ind = int32(regexp(fstrm, '[\n\r]DO[\n\r]'));
if ~isempty(ind)
    % Find all occurrences of what are believed to be axes and grid lines
    ind2 = int32(regexp(fstrm, '[\n\r] *\d* *\d* *mt *\d* *\d* *L[\n\r]'));
    if ~isempty(ind2)
        % Now see which DO sections come just before axes and grid lines
        ind2 = repmat(ind2', [1 numel(ind)]) - repmat(ind, [numel(ind2) 1]);
        ind2 = any(ind2 > 0 & ind2 < 12); % 12 chars seems about right
        ind = ind(ind2);
        % Change any regions we believe to be grid lines to GR
        fstrm(ind+1) = 'G';
        fstrm(ind+2) = 'R';
    end
end

% Isolate line style definition section
first_sec = strfind(fstrm, '% line types:');
[second_sec, remaining] = strtok(fstrm(first_sec+1:end), '/');
[~, remaining] = strtok(remaining, '%');

% Define the new styles, including the new GR format
% Dot and dash lengths have two parts: a constant amount plus a line width
% variable amount. The constant amount comes after dpi2point, and the
% variable amount comes after currentlinewidth. If you want to change
% dot/dash lengths for a one particular line style only, edit the numbers
% in the /DO (dotted lines), /DA (dashed lines), /DD (dot dash lines) and
% /GR (grid lines) lines for the style you want to change.
new_style = {'/dom { dpi2point 1 currentlinewidth 0.08 mul add mul mul } bdef',... % Dot length macro based on line width
             '/dam { dpi2point 2 currentlinewidth 0.04 mul add mul mul } bdef',... % Dash length macro based on line width
             '/SO { [] 0 setdash 0 setlinecap } bdef',... % Solid lines
             '/DO { [1 dom 1.2 dom] 0 setdash 0 setlinecap } bdef',... % Dotted lines
             '/DA { [4 dam 1.5 dam] 0 setdash 0 setlinecap } bdef',... % Dashed lines
             '/DD { [1 dom 1.2 dom 4 dam 1.2 dom] 0 setdash 0 setlinecap } bdef',... % Dot dash lines
             '/GR { [0 dpi2point mul 4 dpi2point mul] 0 setdash 1 setlinecap } bdef'}; % Grid lines - dot spacing remains constant
new_style = sprintf('%s\r', new_style{:});

% Save the file with the section replaced
fh = fopen(fname, 'wt');
fprintf(fh, '%s%s%s%s', fstrm(1:first_sec), second_sec, new_style, remaining);
fclose(fh);
return
end

function combine_eps( eps1 , eps2 , writefile )
% EPSCOMBINE  v0.2  2009/22/06  Will Robertson
% First EPS file analysis
% Find the location in the first EPS file that is just before the
% beginning of the first object. Save the line number for later.

fid = fopen(eps1);
text1 = textscan(fid,'%s','delimiter','\n');
fclose(fid);

for line = 1:length(text1{:})
  tmp = [char(text1{1}(line)),'              '];
  if isequal(tmp(1:14),'%%EndPageSetup')
    inserthere = line;
    break
  end
end

% Second EPS file analysis
% Find where the object is defined in the second EPS file. Save
% the line numbers where it begins and ends. Assume that the
% commenting delimiters occur only once in the file...

fid = fopen(eps2);
text2 = textscan(fid,'%s','delimiter','\n');
fclose(fid);

for line = 1:length(text2{:})
  tmp = [char(text2{1}(line)),'             '];
  if isequal(tmp(1:13),'%%BeginObject')
    beginobject = line;
    break
  end
end

for line = beginobject:length(text2{:})
  tmp = [char(text2{1}(line)),'             '];
  if isequal(tmp(1:11),'%%EndObject')
    endobject = line;
    break
  end
end

% Creation of the third EPS file
% Create a new file by slotting in the object data from the second file
% into the location found in the first file. Save this to the
% output file line by line.
%
% Note the manual 'gr' insertion is required to unrotate the coordinate
% system due to a small bug in Matlab's EPS output driver.

newfile = [text1{1}(1:inserthere);...
           {''};...
           text2{1}(beginobject:endobject);...
           {'gr'};...
           {''};...
           text1{1}(inserthere+1:end)];

writefid = fopen(writefile,'wt');
for line = 1:length(newfile)
  fprintf(writefid,'%s\n',char(newfile{line}));
end
fclose(writefid);

return
end

function trim2epsbbox(infile)
% With code from "EPS UTILITY TOOLBOX"
% by Takeshi Ikuma
% Available (as of 2014): 
% http://www.mathworks.nl/matlabcentral/fileexchange/35429-eps-utility-toolbox
% Copyright 2012 Takeshi Ikuma

	outfile = infile;
	%GET EPS DATA
	wmfdata = [];
	tifdata = [];

	%Open file for reading
	fid = fopen(infile ,'rb');
	if fid<0
	   error('%s cannot be opened.',infile);
	end
	try
		data = fread(fid,30,'uint8');
		if all(data(1:2)==[37;33]) % no preview embedded
		  frewind(fid);
		  imgdata = fread(fid,'uint8=>char').'; % make sure nothing strange happens
		else
		  if any(data(1:4)~=[197;208;211;198])
			 error('%s is not a valid EPS file',infile);
		  end
		  header = getheader(data);
		  fseek(fid,header.pspos,'bof');
		  imgdata = fread(fid,header.pslen,'uint8=>char').';
		  if header.wmflen~=0
			 fseek(fid,header.wmfpos,'bof');
			 wmfdata = fread(fid,header.wmflen,'uint8');
		  end
		  if header.tiflen~=0
			 fseek(fid,header.tifpos,'bof');
			 tifdata = fread(fid,header.tiflen,'uint8');
		  end
		end
	catch ME
		msg = ferror(fid);
		fclose(fid);
		if isempty(msg)
			rethrow(ME)
		else
			error(msg);
		end
	end
	%Close file
	fclose(fid);
	
	%GET GHOSTSCRIPT TIGHT BOUNDING BOX
	% Construct the command string for ghostscript. This assumes that the
	% ghostscript binary is on your path - you can also give the complete path,
	% e.g. cmd = '"C:\Program Files\gs\gs8.63\bin\gswin32c.exe"';
	cmd = 'gs';
	if ispc
		cmd = [cmd 'win32c.exe'];
		cmd = [cmd ' -dSAFER -dNOPAUSE -dBATCH -sDEVICE=bbox ' infile];
	else
		cmd = [cmd 'epsgetbbox.sh ' '"' infile '"'];
	end

	[~,epshdata] = system(cmd);
	% get bounding box line
	bboxstr = regexp(epshdata,'%%BoundingBox:\s*(-?\d+\s+-?\d+\s+-?\d+\s+-?\d+)\s+','tokens','once');
	bbox = str2num(bboxstr{1}); %#ok
	
	% set bounding box line in imgdata
	bboxstr = sprintf('%%%%BoundingBox: %d %d %d %d\n',bbox(1),bbox(2),bbox(3),bbox(4));
	imgdata = regexprep(imgdata,'%%BoundingBox:\s*(-?\d+\s+-?\d+\s+-?\d+\s+-?\d+)\s+',bboxstr,'once');

	%SET THE NEW BOUNDING BOX IN EPS FILE
	
	%Open file for writing
	fid = fopen(outfile,'wb');
	if fid<0
		error('%s cannot be opened.',outfile);
	end

	Nps = numel(imgdata);
	Nwmf = numel(wmfdata);
	Ntif = numel(tifdata);
	HasBinary = Ntif>0 || Nwmf>0;
	try
		if HasBinary % binary data exists
			offset = 30;
			data = zeros(offset,1);
			data(1:4) = [197;208;211;198];
			data(5:8) = [offset;0;0;0]; % immediately follows the header
			data(9:12) = typecast(cast(Nps,'uint32'),'uint8');
			if ~isempty(Nwmf)
				offset = offset + Nps;
				data(13:16) = typecast(cast(offset,'uint32'),'uint8');
				data(17:20) = typecast(cast(Nwmf,'uint32'),'uint8');
			end
			if ~isempty(Ntif)
				offset = offset + Nwmf;
				data(21:24) = typecast(cast(offset,'uint32'),'uint8');
				data(25:28) = typecast(cast(Ntif,'uint32'),'uint8');
			end
			data(29:30) = 255; % no checksum
			% write header
			fwrite(fid,data,'uint8');
		end
		%write postscript data
		fwrite(fid,uint8(imgdata),'uint8');
		if Nwmf>0
			fwrite(fid,wmfdata,'uint8');
		end
   
		% write TIFF data
		if Ntif>0
			fwrite(fid,tifdata,'uint8');
		end
	catch 
		msg = ferror(fid);
		fclose(fid);
		error(msg);
	end
	%Close file
	fclose(fid);
end

function fixdscerror(infile)
	fid = fopen(infile, 'r+');
	if fid < 0
		error('%s cannot be opened.',infile);
	end
	
	try
		fgetl(fid); % Get the first line
		str = fgetl(fid); % Get the second line
		if strcmp(str(1:min(13, end)), '% Produced by')
			fseek(fid, -numel(str)-1, 'cof');
			fwrite(fid, '%'); % Turn ' ' into '%'
		end
	catch ME
		msg = ferror(fid);
		fclose(fid);
		if isempty(msg)
			rethrow(ME)
		else
			error(msg);
		end
	end
	%Close file
	fclose(fid);
end

function params=parseparams(params,pv_pairs)
% parseparams: parses sets of property value pairs, allows defaults
% usage: params=parseparams(default_params,pv_pairs)
%
% arguments: (input)
%  default_params - structure, with one field for every potential
%             property/value pair. Each field will contain the default
%             value for that property. If no default is supplied for a
%             given property, then that field must be empty.
%
%  pv_array - cell array of property/value pairs.
%             Case is ignored when comparing properties to the list
%             of field names. Also, any unambiguous shortening of a
%             field/property name is allowed.
%
% arguments: (output)
%  params   - parameter struct that reflects any updated property/value
%             pairs in the pv_array.
%
% Example usage:
% First, set default values for the parameters. Assume we
% have four parameters that we wish to use optionally in
% the function examplefun.
%
%  - 'viscosity', which will have a default value of 1
%  - 'volume', which will default to 1
%  - 'pie' - which will have default value 3.141592653589793
%  - 'description' - a text field, left empty by default
%
% The first argument to examplefun is one which will always be
% supplied.
%
%   function examplefun(dummyarg1,varargin)
%   params.Viscosity = 1;
%   params.Volume = 1;
%   params.Pie = 3.141592653589793
%
%   params.Description = '';
%   params=parse_pv_pairs(params,varargin);
%   params
%
% Use examplefun, overriding the defaults for 'pie', 'viscosity'
% and 'description'. The 'volume' parameter is left at its default.
%
%   examplefun(rand(10),'vis',10,'pie',3,'Description','Hello world')
%
% params = 
%     Viscosity: 10
%        Volume: 1
%           Pie: 3
%   Description: 'Hello world'
%
% Note that capitalization was ignored, and the property 'viscosity'
% was truncated as supplied. Also note that the order the pairs were
% supplied was arbitrary.

	npv = length(pv_pairs);
	n = npv/2;

	if n~=floor(n)
	  error 'Property/value pairs must come in PAIRS.'
	end
	if n<=0
	  % just return the defaults
	  return
	end

	if ~isstruct(params)
	  error 'No structure for defaults was supplied'
	end

	% there was at least one pv pair. process any supplied
	propnames = fieldnames(params);
	lpropnames = lower(propnames);
	for i=1:n
	  p_i = lower(pv_pairs{2*i-1});
	  v_i = pv_pairs{2*i};

	  %ind = strmatch(p_i,lpropnames,'exact');
	  ind = find(strcmp(lpropnames,p_i));
	  if isempty(ind)
		ind = find(strncmp(p_i,lpropnames,length(p_i)));
		if isempty(ind)
		  error(['No matching property found for: ',pv_pairs{2*i-1}])
		elseif length(ind)>1
		  error(['Ambiguous property name: ',pv_pairs{2*i-1}])
		end
	  end
	  p_i = propnames{ind};

	  % override the corresponding default in params
		  %params = setfield(params,p_i,v_i);
		  params.(p_i)=v_i;
	end
end

