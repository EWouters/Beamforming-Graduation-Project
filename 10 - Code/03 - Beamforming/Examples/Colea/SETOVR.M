function setovr(type)

% Copyright (c) 1995 Philipos C. Loizou
%

global ovlpfilt S0 plt_type MAPLaw othUp LPC_ONLY chnlpUp lpcUp OVRL
global ovrUp oha ore opy opn lpcParam SHAN_WIN shW ope


if strcmp(type,'on')
  ovlpfilt=1;
elseif strcmp(type,'off')
  ovlpfilt=0;
elseif strcmp(type,'line')
  plt_type='line';
elseif strcmp(type,'picket')
  plt_type='picket';
elseif strcmp(type,'points')
 plt_type='points';
elseif strcmp(type,'bar')
 plt_type='bar';
elseif strcmp(type,'log') % -- choose the log mapping function
 MAPLaw='log';
elseif strcmp(type,'log_abs') % absolute log-scale
 MAPLaw='log20'; 		
elseif strcmp(type,'lin')
 MAPLaw='lin';
elseif strcmp(type,'other')
 setmap;
 return;
elseif strcmp(type,'othchoice')
 x=get(othUp,'Value');
 if x>1
   if     x==2, MAPLaw='pow2';
   elseif x==3, MAPLaw='pow3';
   elseif x==4, MAPLaw='pow4';
   elseif x==5, MAPLaw='pow5';
   end 
 else
  return;
 end;
elseif strcmp(type,'user')      % mapping law function was loaded from a file
  MAPLaw='userSelected';
elseif strcmp(type,'user_dyr')  % dynamic ranges were loaded from a file
  MAPLaw='userSelected_dyr';
elseif strcmp(type,'lpconly')
 LPC_ONLY=1; OVRL=1; set(ovrUp,'Value',0);
 set(chnlpUp,'Checked','Off');
 set(lpcUp,'Checked','on');
elseif strcmp(type,'lpc_chan')
 LPC_ONLY=0; OVRL=1;  set(ovrUp,'Value',0);
 set(chnlpUp,'Checked','on');
 set(lpcUp,'Checked','off');
elseif strcmp(type,'LPhamming')  % LPC analysis options, set window type
  lpcParam(1)=1; 
  set(oha,'Checked','on'); set(ore,'Checked','off');
elseif strcmp(type,'LPrect')
  lpcParam(1)=0; 
  set(oha,'Checked','off'); set(ore,'Checked','on');
elseif strcmp(type,'LPnoPre')
  lpcParam(2)=0;
  set(opn,'Checked','on'); set(opy,'Checked','off');
elseif strcmp(type,'LPyesPre')
  lpcParam(2)=1; 
  set(opn,'Checked','off'); set(opy,'Checked','on');
elseif strcmp(type,'LPenh')
  lpcParam(3)=lpcParam(3)*(-1);
  if lpcParam(3)>0, set(ope,'Checked','on'); else, set(ope,'Checked','off'); end;
elseif strcmp(type,'shanwin');
  if ~exist('SHAN_WIN'), SHAN_WIN=-1; end;
  SHAN_WIN=SHAN_WIN*(-1);
  if SHAN_WIN>0, set(shW,'Checked','on'); else, set(shW,'Checked','off'); end
end

pllpc(S0)

