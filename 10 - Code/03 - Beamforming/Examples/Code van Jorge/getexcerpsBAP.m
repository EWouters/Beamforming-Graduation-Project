function varargout = getexcerpsBAP(flag,Ninterf,fs,varargin)
% GETEXCERPS Function to get the audio files needed for the simulation of
%the beamformer.
% Author: dr. Jorge Martinez (J.A.MartinezCastaneda@TuDelft.nl).
%
% flag - flag to indicate the type of info to load
% Ninterf - number of interfering sources
% fs - samplerate in Hz
% case flag = 'sim'
%  varargin{1:9}
%   {1} sim_t - ?
%   {2} opsc - ?
%   {3} opic - ?
%   {4} wngf - ?
%   {5} sigman - ?
%   {6} wavedir - directory with wav files
%   {7} Maxfiles - maximum number of files
%   {8} ? flag to use varargin{6}
%   {9} ? flag to use varargin{7}
%  varargout{1}= source;
%  varargout{2}= interferers;
% case flag = {'anechoic','room'}
%  varargin{1:5}
%   {1} sim_t - ?
%   {2} dataname - ?
%   {3} datadir - directory with data files
%   {4} ?
%   {5} ?
%  varargout{1} = xinput
% case flag = 'retrieve'
%  varargin{1:6}
%   {1} sim_t - ?
%   {2} opsc - ?
%   {3} names - file names
%   {4} wavedir - directory with wav files
%   {5} Maxfiles - maximum number of files
%   {6} ?
%  varargout{1}= sources;

switch flag
	case 'sim'
   
		if nargin < 8
			display('At least 8 input arguments are needed.')
			return
		end

		if nargout ~=2
			display('Two output arguments are required.')
			return;
		end


		sim_t = varargin{1};
		opsc = varargin{2};
		opic = varargin{3};
		wgnf = varargin{4};
		
		if nargin > 8
			wavedir = varargin{6};
		else
			wavedir = [pwd '\wavefiles'];
		end
		
		if nargin > 9 
			Maxfiles = varargin{7};
		else
			Maxfiles = 48;
		end

		sim_l=floor(fs.*sim_t);

		interferers = zeros(sim_l,Ninterf);

		if (Ninterf +1 <= Maxfiles)
			nvect = randsample(Maxfiles,Ninterf+1);
		else
			display(['Warning: the number of available sound files is ' num2str(Maxfiles) '. Some sources will be repeated.'] )
			nvect = randsample(Maxfiles,Ninterf+1,true);
		end


		signal_filename1 = [wavedir '\' num2str(nvect(1)) '.wav'];
		[source, fse] = audioread(signal_filename1);       

		if fse ~= fs
			source = resample(source,fs,fse);    
		end

		source = [source; zeros( max(0,sim_l-size(source,1)), 1) ];
		source = source(1:sim_l);
		source = opsc.*source./max(abs(source));


		if wgnf
			sigman=varargin{5};
			interferers =  randn(sim_l,Ninterf).*sigman;
		else
			for nfile = 1:Ninterf; 
				signal_file=[wavedir '\' num2str(nvect(nfile+1)) '.wav'];
				[signal1, fse]= audioread(signal_file);

				if fse ~= fs
					signal1 = resample(signal1,fs,fse);    
				end

				signal1 = [signal1; zeros( max(0,sim_l-size(signal1,1)), 1) ]; %#ok<AGROW>
				interferers(:,nfile)=opic.*signal1(1:sim_l)./max(abs(signal1(1:sim_l)));
			end
		end

		varargout{1}= source;
		varargout{2}= interferers;

	case {'anechoic','room'}
		
    
		if nargin < 5
			display('At least input 5 arguments are needed.')
			exit
		end

		if nargout ~=1
			display('One output argument is required.')
			return;
		end
		sim_t = varargin{1};
		dataname=varargin{2};
		if nargin > 5
			datadir = varargin{3};
		else
			datadir = [pwd '\Recordings'];
		end
		
		
		load([ datadir '/' dataname]);
		
		if data.fs ~= fs
					xinput = resample(data.x,fs,data.fs);    
		else
			xinput =data(datnum).x;
		end
		
		sim_l=floor(fs.*sim_t);
		
		xinput = [xinput; zeros( max(0,sim_l-size(xinput,1)), size(xinput,2))];
		xinput= xinput(1:sim_l,:);
		
			
		varargout{1} = xinput;
		
	case 'retrieve'
   
		if nargin < 6
			display('At least 6 input arguments are needed.')
			return
		end

		if nargout > 1
			display('One output argument is required.')
			return;
		end


		sim_t = varargin{1};
		opsc = varargin{2};
% 		names = varargin{3};
        names = strread(num2str(1:Ninterf),'%s'); % Editted 

		if nargin > 6
			wavedir = varargin{4};
		else
			wavedir = [pwd '\wavefiles'];
		end
		
		if nargin > 7 
			Maxfiles = varargin{5};
		else
			Maxfiles = 48;
		end
		
		
		if numel(names) ~=Ninterf
			display('Error: the number of given filenames does not agree with the second input argument');
			return;
		end

		if (Ninterf > Maxfiles)
			display(['Error: the number of available sound files is ' num2str(Maxfiles) ])
			return;
		end

		sim_l=floor(fs.*sim_t);

		sources = zeros(sim_l,Ninterf);

		for nfile = 1:Ninterf; 
			signal_file=[wavedir '/' names{nfile} '.wav'];
			
			if strcmp('0',names{nfile})
				signal1 =randn(sim_l,1);
				fse=fs;
			else
				[signal1, fse]= audioread(signal_file);
			end

			if fse ~= fs
				signal1 = resample(signal1,fs,fse);    
			end

			signal1 = [signal1; zeros( max(0,sim_l-size(signal1,1)), 1) ]; %#ok<AGROW>
			sources(:,nfile)=opsc.*signal1(1:sim_l)./max(abs(signal1(1:sim_l)));
		end


		varargout{1}= sources;
	
	otherwise
		display('Error: first argument is not a valid option')
end
return