% Beamformer demo m function.
% Author: dr. Jorge Martinez (J.A.MartinezCastaneda@TuDelft.nl)

clearvars -except mos* snr_* stoi* results;
%%%%%%%%%%%%%%%%%%% USER PARAMETERS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% SCENARIO
Nmics=8;                                    %Microphones
Ninterf = 3;                                %Interferers

sound_vel = 342;                            %Sound speed
fs = 48000;                                 %Sampling frequency
fseval=16000;


L_b=2048;        % positive half of fft spectrum, block length         

room_dim = [6.85 3.95 3.2];                       %Room dimensions [l w h]??
%room_dim = [8.5 6.5 3];                       %Room dimensions
%offset = room_dim./2 - [1.1 1.12 0.7];
offset = [3.07 1.01 0.73];

alphas = [0.54 -0.56 0.58 -0.53 -0.55 0.57];  %Reflection factors
hsiz = 0.064;                               

% FLAGS
simulated = true;                           %Simulation or real-data?
reverb = false;                             % Should reverberation be simulated?
sourcein = 'room';
sim_time = 6.7;	
sim_l=floor(fs.*sim_time);

% SIMULATED SCENARIO PARAMETERS (IF SIMULATION IS TRUE)

dBFs = -8;                                  %Excerpts dBFs
opsc = 10^(dBFs/20);

SNR  = 60;                                  %iid noise SNR in dB.


iSNR  = 0;                                  %interferer SNR in dB
opic = 10^((dBFs-iSNR)/20);
interf_variance=opic^2;                 % 3-sigma variance (if WGN)



rirplotflag = true;                         % Should the simulated RIR be plotted?
poserrflag = false;                         % Should position errors be simulated?            
micposerrflag = false;                      % Should microphone position errors be simulated?            
micerrrad =0.05;
micposerrvar = micerrrad^2/9;
% REAL-DATA SCENARIO PARAMETERS (IF SIMULATION IS FALSE)

if strcmp('anechoic',sourcein)
	sourcesconf=1;	
elseif 	strcmp('room',sourcein)
	sourcesconf=2;	
end

micconf=1;
switch sourcesconf

	case 1
	
	sources_pos = [ ...
			 1.04, 2.19, 0.175  ; ...
			 3.49,-1.37, 0.135  ; ...
			-1.70,-0.40, 0.615  ; ...
	%		 4.43, 3.48, 0.375  ; ...
			-0.10, 1.01, 0.30   ; ...
			];

	case 2
	sources_pos = [ ...
	 1.04, 1.99, 0.10  ; ...
	 3.27,-0.89, 0.10  ; ...
	-1.73,-0.35, 0.60  ; ...
	-0.11, 1.00, 0.31   ; ...
	];

end
	


switch micconf
	case 1
		mics_pos = [ ...
			 0.05, 0.35, 0.00 ; ...
			 0.55, 0.65, 0.00 ; ...
			 0.60, 0.25, 0.00 ; ...
			 0.40, 0.40, 0.00 ; ...
			 0.20, 0.15, 0.00 ; ...
			 0.95, 0.75, 0.00 ; ...
			 0.85, 0.45, 0.00 ; ...
			 0.75, 0.10, 0.00 ...
			];
	case 2
		mics_pos = [ ...
			 0.20, 0.70, 0.00 ; ...
			 0.45, 0.45, 0.00 ; ...
			 0.50, 0.35, 0.00 ; ...
			 0.25, 0.40, 0.00 ; ...
			 0.15, 0.25, 0.00 ; ...
			 0.75, 0.55, 0.00 ; ...
			 0.90, 0.15, 0.00 ; ...
			 0.70, 0.05, 0.00 ...
			];
	case 3
		mics_pos = [ ...
			 0.35, 0.20, 0.00 ; ...
			 0.65, 0.50, 0.00 ; ...
			 0.80, 0.60, 0.00 ; ...
			 0.10, 0.80, 0.00 ; ...
			 1.00, 0.80, 0.00 ; ...			 
			 0.00, 0.00, 0.00 ; ...
			 0.90, 0.10, 0.00 ; ...
			 0.50, 0.35, 0.00 ...
			];
	case 4
		mics_pos = [ ...
			 0.20, 0.10, 0.00 ; ...
			 0.65, 0.60, 0.00 ; ...
			 0.05, 0.15, 0.00 ; ...
			 0.90, 0.45, 0.00 ; ...
			 0.70, 0.80, 0.00 ; ...			 
			 0.80, 0.30, 0.00 ; ...
			 0.10, 0.40, 0.00 ; ...
			 0.45, 0.30, 0.00 ...
			];
		
end

dims = reverb.*ones(1,3); 


% MVDR BEAMFORMER PARAMETERS

regfactmvdr =10^-1;                              %Regularization factor.
rtflag = false;                              %Real-time flag.
L_be = 2^nextpow2(floor(fs.*0.016));
delta_s = 0.90;

%Specsfile
	
if strcmp('anechoic',sourcein)
	recdata = 'recdata_anechoic.mat';
elseif 	strcmp('room',sourcein)
	recdata = 'recdata_room.mat';
end
specsfile='specs_experiments.mat';
specsdir= [pwd filesep 'Recordings'];
datadir = [ pwd filesep 'Recordings'];
load([specsdir filesep specsfile]);


refs={1;2:Ninterf+1};
targid = num2str(specs(1).id);
excpid = cellfun(@num2str,{specs(1:Ninterf+1).id},'UniformOutput',false);
source_pos = sources_pos(refs{1},:);
interf_pos = sources_pos(refs{2},:);




% PLOTS
alphavis= 0.05;                             % Transparency for the spatial windows.



% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



if simulated                                % Code to execute if the scenario is to be simulated
		
    
    assignin('base', 'Ninterf', Ninterf);
    assignin('base', 'fs', fs);
    assignin('base', 'sim_time', sim_time);
    assignin('base', 'opsc', opsc);
    
	excerpts = getexcerpsBAP('retrieve',Ninterf+1,fs,sim_time,opsc,excpid);
  
    
	source = excerpts(:,refs{1});
	interf = excerpts(:,refs{2});
    
	swinsigma2 = 0; % Editted
    iwinsigma2 = 0; % Editted
    
	poserrs = poserrflag.*sqrt(swinsigma2)/2.*randn(1,3);
	poserri = poserrflag.*sqrt(iwinsigma2)/2.*randn(Ninterf,3);
	
	merrthet=pi*rand(Nmics,1);
	merrphi=2*pi*rand(Nmics,1);
	
	merrrho=micerrrad;
	
	merrx = merrrho.*sin(merrthet).*cos(merrphi);
	merry = merrrho.*sin(merrthet).*sin(merrphi);
	merrz = merrrho.*cos(merrthet);
	
	micposerr = micposerrflag.*[merrx, merry, merrz];
    
%     %%%%
%     source_pos = sources_pos;
%     interf_pos = sources_pos;
%     %%%%%
    
	focal_point = source_pos;   %old line: focal_point = source_pos;
    focal_interf = interf_pos;
	
	Nsource= size(source_pos,1);   
    Ninterf= size(interf_pos,1);
	
    mics_pos=mics_pos+repmat(offset,[Nmics,1]);
	realmics_pos=mics_pos;
    source_pos = source_pos+repmat(offset,[Nsource,1]);
    interf_pos=interf_pos+repmat(offset,[Ninterf,1]);
    focal_point=focal_point+repmat(offset,[Nsource,1]);
    focal_interf = focal_interf +repmat(offset,[Ninterf,1]);
	
    focal_point = focal_point + poserrs; 
    focal_interf = focal_interf + poserri;
    mics_pos = realmics_pos+micposerr;
	
    [source_reb, interf_reb, h] = simulatescenarioBAP(Nmics,Ninterf,sound_vel,fs,sim_l,realmics_pos,[source_pos ; interf_pos],room_dim,alphas,L_b,dims,hsiz,source,interf,rirplotflag);
    
	addnoise=randn(sim_l,Nmics);
	addnoise=opsc.*addnoise./repmat(max(abs(addnoise)),[sim_l 1])./10^(SNR./20);
	sigman2=mean(var(addnoise));
	xinput = source_reb + interf_reb + addnoise;
 else                                        % Code to execute if using real-data.
    
	xinput=getexcerpsBAP(sourcein,Nmics,fs,sim_time,recdata,datadir);
    
    
    focal_point = source_pos;
    focal_interf = interf_pos;
    
	Nsource= size(source_pos,1);   
    Ninterf= size(interf_pos,1);
    
    mics_pos=mics_pos+repmat(offset,[Nmics,1]);
	realmics_pos=mics_pos;
    source_pos = source_pos+repmat(offset,[Nsource,1]);
    interf_pos=interf_pos+repmat(offset,[Ninterf,1]);
    focal_point=focal_point+repmat(offset,[Nsource,1]);
    focal_interf = focal_interf +repmat(offset,[Ninterf,1]);

	poserrs = poserrflag.*sqrt(swinsigma2).*randn(1,3);
	poserri = poserrflag.*sqrt(iwinsigma2).*randn(Ninterf,3);
	
	merrthet=pi*rand(Nmics,1);
	merrphi=2*pi*rand(Nmics,1);
	
	merrrho=micerrrad;
	
	merrx = merrrho.*sin(merrthet).*cos(merrphi);
	merry = merrrho.*sin(merrthet).*sin(merrphi);
	merrz = merrrho.*cos(merrthet);
	
	micposerr = micposerrflag.*[merrx, merry, merrz];
    
    focal_point = focal_point + poserrs; 
    focal_interf = focal_interf + poserri;
    mics_pos = realmics_pos+micposerr;

end


swinrad = 0; % Editted
iwinrad = 0; % Editted
vis_scenario(room_dim,mics_pos,realmics_pos,source_pos,interf_pos,focal_point,focal_interf,swinrad,iwinrad,alphavis);    %Function to plot and visualize the scenario

drawnow;
%%

ymvdrbf = mvdrbfBAP(fs,sound_vel,L_b,L_be,mics_pos,focal_point,xinput,regfactmvdr,delta_s,rtflag); % MVDR beamformer (filtering) function




ind=min(distcalc(mics_pos,focal_point)) == distcalc(mics_pos,focal_point);                                  %Finds the closest microphone to the source

references = getexcerpsBAP('retrieve',Ninterf+1,fs,sim_time,opsc,excpid);
yref = references(:,refs{1});

yclose = opsc*xinput(:,ind)/max(abs(xinput(:,ind)));
ymvdr  = opsc.*ymvdrbf./max(abs(ymvdrbf));


if fs ~= fseval
	yref = resample(yref,fseval,fs);
	yclose = resample(yclose,fseval,fs);
	ymvdr = resample(ymvdr,fseval,fs);

end


snropt = 'Vzp';
snrtf = 0.1;
sigalt = 1/4;
sigalm = 'g';

% stoi segmental snr and pesq
[~,~,rr,ss]=sigalign(yclose,yref,sigalt,sigalm);
figure(5);
clf;
plot((1:size(rr,1))./fseval,rr,'r',(1:size(ss,1))./fseval,ss,'b:')
grid on;
axis tight;
legend('Reference','Closest mic')
title('Aligned closest microphone signal')

[snr_syclose, snr_gyclose] = snrseg(ss,rr,fseval,snropt,snrtf);
stoi_yclose = stoi(rr,ss,fseval);
audiowrite([pwd '\tmp\rr.wav'],rr,fseval,'BitsPerSample',16);
audiowrite([pwd '\tmp\ss.wav'],ss,fseval,'BitsPerSample',16);
mos_yclose = pesq_itu(fseval,[pwd '\tmp\rr.wav'],[pwd '\tmp\ss.wav']);

[~,~,rr,ss]=sigalign(ymvdr,yref,sigalt,sigalm);
figure(7);
clf;
plot((1:size(rr,1))./fseval,rr,'r',(1:size(ss,1))./fseval,ss,'b:')
grid on;
axis tight;
legend('Reference','MVDR')
title('Aligned MVDR signal')

[snr_symvdr, snr_gymvdr] = snrseg(ss,rr,fseval,snropt,snrtf);
stoi_ymvdr = stoi(rr,ss,fseval);
audiowrite([pwd '\tmp\rr.wav'],rr,fseval,'BitsPerSample',16);
audiowrite([pwd '\tmp\ss.wav'],ss,fseval,'BitsPerSample',16);
mos_ymvdr = pesq_itu(fseval,[pwd '\tmp\rr.wav'],[pwd '\tmp\ss.wav']);


clearvars -except mos* snr_* stoi* yref yclose ymvdr fs fseval;


%soundview(yref,fseval) 

%soundview(yclose,fseval)

%soundview(ymvdr,fseval) 

