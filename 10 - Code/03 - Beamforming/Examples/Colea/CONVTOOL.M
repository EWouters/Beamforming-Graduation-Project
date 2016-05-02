function convtool(type)

% Copyright (c) 1995 Philipos C. Loizou

global HDRSIZE Srate hdrHndl sfHndl filename cnvFig
global swpbHndl SWAPB dwnHnd n_Secs DWNS  nChannels upHnd
global S1 UPS hdrHnd sfHnd

if strcmp(type,'header')

  HDRSIZE=str2num(get(hdrHnd,'String'));

elseif strcmp(type,'sfreq')

  Srate=str2num(get(sfHnd,'String'));

elseif strcmp(type,'swap') % === swap bytes ===========

  SWAPB=get(swpbHndl,'Value');

elseif strcmp(type,'down') % ==== downsample ==========

  DWNS=get(dwnHnd,'Value');

elseif strcmp(type,'up') % ==== Upsample ==========

  UPS=get(upHnd,'Value');

elseif strcmp(type,'header2')

  HDRSIZE=str2num(get(hdrHndl,'String'));

elseif strcmp(type,'sfreq2')

  Srate=str2num(get(sfHndl,'String'));

elseif strcmp(type,'yes') % === convert file to .ils format ===
   
   HDRSIZE=str2num(get(hdrHnd,'String'));
   Srate=str2num(get(sfHnd,'String'));

  ind1=find(filename == '.');
  if isempty(ind1), name=[filename '.ils'];
  else, name=[filename(1:ind1) 'ils']; end  
  


  raw2ils(filename,HDRSIZE,Srate);
  filename=name;
  estr=['colea ' filename];
  delete(cnvFig);
  eval(estr);  

elseif strcmp(type,'no') % === abort ===
  close all;
  clear all;
  return;

elseif strcmp(type,'apply') %======== apply changes to file =====

  downsa=0;

  if SWAPB == 1 % swap bytes 
	out=swapbyte(filename,HDRSIZE);
        n_Secs=length(out)/Srate;
  else
	fp1=fopen(filename,'r');
	fseek(fp1,HDRSIZE,'bof');	
	out=fread(fp1,inf,'short');
	fclose(fp1);
	n_Secs=length(out)/Srate;
  end
  

  if DWNS>1
	nout=decimate(out,DWNS);	
	Srate=Srate/DWNS;
	DWNS=1; % reset
	downsa=1;
	set(sfHndl,'String',int2str(Srate));
	setchan(nChannels);
  else
	if UPS>1
		nout=interp(out,UPS);	
		Srate=Srate*UPS;
		UPS=1;% reset
		downsa=1;
		set(sfHndl,'String',int2str(Srate));
		setchan(nChannels);
	end
  end

 ind=find(filename == '.');
 ext = filename(ind+1:length(filename));
 newname=['mod1.' ext];
 if strcmp(newname,filename)
	newname=['mod2.' ext];
 end
 

 fpout=fopen(newname,'w');
 fp1=fopen(filename,'r');
 if downsa==1 
	nsamples=length(nout);	
	modhder(fp1,fpout,ext,nsamples,Srate);
	fwrite(fpout,nout,'short');
 else
   	hdr=fread(fp1,HDRSIZE,'char');
        fwrite(fpout,hdr,'char');
	fwrite(fpout,out,'short');
	fclose(fp1);
 end
 
 filename=newname;
 fclose(fpout); 
 zoomi('out');

end
