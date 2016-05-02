%FUNCTION which draws interference from a specified wave file
%and generates data which can be used by a higher level routine
%to create a specfied number random interference profiles

%INPUTS:

%filename:  path of interference containing wave file

%Fs:    desired sampling frequency (normally matches that of the wave file)

%num_perm:  number of 'perm-type' interferers which are active during all 
            %of a single interference profile   

%num_temp:  number of 'temp-type' interferers which are active for short 
            %sections of a signle interference profile
            
%rand_trials: number of interference profiles to generate

%sig_len: length of an interference profile in samples



%OUTPUTS:

%interf: cell array which contains vectors of individual interferers
        %each column holds interferers for a single interference profile
        %the cells of each column hold varying length vectors
        %of interference. 
        %the cells of the each column are organized so that
        %the cells holding num_perm interferers 
        %are followed by the cells holding num_temp interferers

%fft_fctr:  vector used by higher level routine 
            %to delay any perm-type interferer via freq. domain phase shift

%fft_fctrs:     holds vectors used by a higher level routine to delay
                %temp-type interferers via freq. domain phase shift
                %Organized in a way that is similar to interf, 
                %except there are no cells 
                %corresponding to perm-type interferers

%interflocs_cel:  holds spatial locations of interfence
                 %organized the same way as interf
                 %used by higher level routine to calculate time delays
                 %across microphones
                 
%k:     k>sig_len is extended sample-length of num-perm type interferers 
        %to accomodate for the longest possible time delay given the
        %spatial constraint (defined further)
        %Before all perm and temp-typ interferers are consolidated to one signal.
        %that signal should be preallocated to have length k.
        %As this consolidation is done by a higher level routine, k is
        %passed as output.
        %After the proper delays are applied to inteferers
        %by the higher level routine and the interferers are consolidated
        %to one signal (representing one profile), this signal should
        %be trimmed from length k to length sig_len.
       

function [interf,fft_fctrs,fft_fctr,interflocs_cel,strtpos,k,shift_smp]=...
       gener_interf_old(filename,Fs,num_perm,num_temp,rand_trials,sig_len)

%hold on
num_interf=num_perm+num_temp;

%reading interference wav file
data = audioread(filename)';
LENG=length(data);

%signal sample constraints
Lmin=round(1/48*sig_len);
Lmax=round(8/48*sig_len);
%e.g. for a 1024 sample signal, temp interferer length will be chosen 
%randomly to be between 20 and 170 samples


%signal amplitude constraints
%amplLo=.25;
%amplHi=2.5;
ampl=1;%^no longer used...

%space and physical constraints
c=339;
rmin=1.5;
rmax=15;
thetamin=-90;
thetamax=90;

%compute zero-padding for delay
distmax=rmax+.5;
maxsmplsdelay=ceil((distmax./c)*Fs);
maxsmplsdelay=maxsmplsdelay+mod(maxsmplsdelay,2);
pad=zeros(1,maxsmplsdelay);
shift_smp=round(maxsmplsdelay*.7);
k=sig_len+maxsmplsdelay;


%preparing additional auxilary variables
fft_fctr=-2i*pi*[0:k/2 -k/2+1:-1]/k*Fs;
%^vector for delaying temporary interferers in frequency

interf=cell(num_interf,rand_trials);
strtpos = zeros(num_temp,rand_trials);
fft_fctrs=cell(num_temp,rand_trials);
%^holds vectors for delaying temporary interferers frequency
interflocs_cel=cell(1,rand_trials);

%--NOTE:neither fft_fctr, nor fft_fctrs are used to delay
%the interference across microphones within this function
%they are only returned by the function so that a higher level
%routine can use them to delay the interference across an arbitrary 
%mic array




%populating interference array
for trial=1:rand_trials
    
    %random spatial locations
    interflocs = [rand(1,num_interf)*(rmax-rmin)+rmin;
            rand(1,num_interf)*(thetamax-thetamin)+thetamin];
    interflocs_cel{trial} = [interflocs(1,:).*sind(interflocs(2,:))
                             interflocs(1,:).*cosd(interflocs(2,:))];
    %Easier to generate interf in polar coords to have all interference be
    %at least 1.5 m away from mic array center and more sparse as the distance
    %increases. Then interference locations are converted to cartesian coords
    %sind x=r*sind(theta) as theta measured from y-axis
    
    for i=1:num_perm
    
        %ampl=(rand*(amplHi-amplLo)+amplLo);

        pos=randi(LENG-sig_len+1);
        chunk=data(pos:pos+sig_len-1);
        
        nonstat=ampl*chunk;
        rms_nonstat=sqrt(mean(nonstat.^2));
        white=0;%rms_nonstat/3*randn(1,sig_len);
        interf{i,trial}=[nonstat+white pad];
    end
    %lin='-:+o*.xsd^v><ph';
    %cel={};
    for i=i+1:i+num_temp
        
        leng=randi([Lmin,Lmax]);
        leng=leng+mod(leng,2);
        padded_leng=leng+maxsmplsdelay;
        %ampl=(rand*(amplHi-amplLo)+amplLo);
                
        pos=randi(LENG-leng+1);
        chunk=data(pos:pos+leng-1);
        
        nonstat=ampl*chunk;
        rms_nonstat=sqrt(mean(nonstat.^2));
        white=0;%rms_nonstat/3*randn(1,leng);
        interf{i,trial}=[nonstat+white pad];
        
        strtmin=round(maxsmplsdelay*2/3);
        strtmax=sig_len-leng+1;
        strt=randi([strtmin,strtmax]);
        strtpos(i-num_perm,trial)=strt;
        
        fft_fctrs{i-num_perm,trial}=...
         -2i*pi*[0:(padded_leng)/2,-(padded_leng)/2+1:-1]/(padded_leng)*Fs;
        
        %plot(strt:strt+leng-1+length(pad),interf{i,trial},...
        %'color',rand(1,3),'linestyle',lin(i-num_perm))
        
        
        %cel{end+1}=[num2str(i-num_perm) ' ' num2str(leng)];
    end
    %legend(cel);
end


end