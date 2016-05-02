function distool

% Copyright (c) 1995 Philipos C. Loizou

global NCmp AnCmp CmpFig W_comp N_comp CURS


if ~isempty(CmpFig), % check to see if it is a valid handle
   
    invalid=0;
    eval('findobj(CmpFig);','invalid=1;');
    if invalid==1, CmpFig=[]; end;
end

if isempty(W_comp)
	W_comp=10;
	N_comp=14;
	CURS=0;
end


pos = get(0, 'screensize');
xpos=pos(3)/3; 
ypos=pos(4)/3;
wi=356; %xpos+90
he=210; %ypos+10


if isempty(CmpFig) 
	CmpFig = figure('Units', 'pixels', 'Position', [xpos ypos wi he],...
	'Menubar','none','NumberTitle','off','Name',...
	'Comparison Tool');
else
	figure(CmpFig);
	return;
end



%---------------- Define the buttons-----------------------
dp=35; 
top=he-dp-10;
inc=30;
lft=dp;
wit=65;

uicontrol('Style','Text','String','Analysis (ms)','Position',[lft+12 top wit 27],'BackgroundColor',...
	 [0 0 0],'ForeGroundColor','r');

AnCmp=uicontrol('Style','edit','String',int2str(W_comp),'Position',[lft+12+wit top wit 20],...
	'Callback','comptool(''analysis'')','BackgroundColor',[1 1 1]);

uicontrol('Style','Text','String','Order, N','Position',[lft+12+2*wit top-10 wit 27],'BackgroundColor',...
	 [0 0 0],'ForeGroundColor','r');

NCmp=uicontrol('Style','edit','String',int2str(N_comp),'Position',[lft+12+3*wit top 30 20],...
	'Callback','comptool(''order'')','BackgroundColor',[1 1 1]);

top=top-inc;
uicontrol('Style','pushb','String','SNR','Position',[lft-10 top wit+15 20],...
	'Callback','comptool(''snr'')');
top=top-inc;
uicontrol('Style','pushb','String','I-Saito','Position',[lft-10 top wit+15 20],...
	'Callback','comptool(''IS'')');

top=top-inc;
uicontrol('Style','pushb','String','LR','Position',[lft-10 top wit+15 20],...
	'Callback','comptool(''LR'')');

top=top-inc;
uicontrol('Style','pushb','String','LLR','Position',[lft-10 top wit+15 20],...
	'Callback','comptool(''LLR'')');

top=top-inc;
uicontrol('Style','Text','String','Compare:','Position',[lft-10 top-8 wit 27],'BackgroundColor',...
	 [0 0 0],'ForeGroundColor','r');
uicontrol('Style','pushb','String','At cursor','Position',[lft-10+wit top wit+15 20],...
	'Callback','comptool(''cursor'')');
uicontrol('Style','pushb','String','Overall','Position',[lft-10+2*wit+20 top wit+15 20],...
	'Callback','comptool(''overall'')');
uicontrol('Style','pushb','String','Cancel','Position',[lft-10+3*wit+40 top wit+15 20],...
	'Callback','delete(gcf)');
% ----- start now a new column of buttons
lft = wit+15+lft-10+10;
top=he-dp-10;

top=top-inc;
uicontrol('Style','pushb','String','WLR','Position',[lft top wit+15 20],...
	'Callback','comptool(''WLR'')');
top=top-inc;
uicontrol('Style','pushb','String','WSM','Position',[lft top wit+15 20],...
	'Callback','comptool(''KLATT'')');
top=top-inc;
uicontrol('Style','pushb','String','Cepstrum','Position',[lft top wit+15 20],...
	'Callback','comptool(''cep'')');
top=top-inc;
uicontrol('Style','pushb','String','W-Cepstrum','Position',[lft top wit+15 20],...
	'Callback','comptool(''wcep'')');
