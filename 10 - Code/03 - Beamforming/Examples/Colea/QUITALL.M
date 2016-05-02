function quitall

% Copyright (c) 1995 Philipos C. Loizou
%

global tf modChange

%if modChange==1
%  choice=dialog('Style','question','TextString','Do you want to save the changes',...
	%'Buttonstrings','YES|NO|Cancel','Name','SAVE');
	
	%choice
	%if strcmp(choice,'YES'), disp('yes'); end;
	
	
%end

if exist('tf')
 delete(tf);
end
close all
clear all

