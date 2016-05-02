%Function for simulating MVDR performance with a virtual test signal
%Used for development for beamforming to human speech.
%This function calls on subroutine 'gener_interf_old'
%to draw chunks from a large wave file of crowd noise, 
%'Ohio_Stadium_noise24.wav'
%Path of this file can be changed as needed below where 'filename' is set.
%These chunks are used to form interference with of relatively
%short time durations throughout the signal
%Multiple interferers at a time simulated at random spatial locations.
%All interference is balanced to contain even energy levels across
%the processed spectrum (e.g. 300-3400 Hz)

%---INPUTS---:

%num_mics:   must be at least 2%Lv:    is a vector of the uniform linear array lengths tested

%rand_trials:    how many trials of interference to test. 
    %e.g. rand_trials=50: a clean test signal will be processed 50 times 
    %with a new randomly generated interfence profile added to it each time.

%num_bands_v:   a vector of multiple numbers of sub-bands to test

%Fs:    only use 22050 in this version

%update: 
%--NOTE:   as of March, 12 2012, update=0 has been not been tried
%        if update=0:
    %MVDR weights updated only for lower freq. sub-bands for one block
    %before weights are applied to all sub-bands in that block.
    %Then, MVDR weights updated only for higher sub-bands in the next block 
    %before weights are applied to all sub-bands in that block. 
    %This pattern is then repeated.
%       otherwise:
    %all MVDR weights are updated for all sub-bands in every block.
    
    
%sect_len:   the length of a clean signal. E.G. a short 1024-sample signal.
%shift_siz:     how many samples each 1024-sample FFT is shifted for every 
            %block of appying MVDR weights
%interf_rms:    each interference profile is adjusted to have this RMS
                %this allows testing different inteference strengths
                %the RMS of the clean signal is set to 1.
%fg_v:  a vector of different forgetting factors to test.
        %each factor >0, but <1.

        
        
%---OUTPUTS---:

%err_decr_percs:
    %time domain error score:
    %measures improvement in RMS of error in the time domain 
    %after processing. 'Error' means deviation from clean signal.
    %100=> perfect recovery of clean signal. 
    %0 or less=>MVDR made no improvement to error.

%ERR_DECR_PERCs:
    %Similar to time domain score but more complex.
    %measures improvements in RMS error in magnitude response
    %by transforming 1024-sample sections of processed and noisy signal
    %to freqeuncy and computing the average improvement in error
    %for the processed signal across DFT of the many 1024-sample sections.

%--NOTE: each of error score arrays above is 3 dimensional.
%Rows correspond to values from Lv, 
%columns to values from num_bands_v,
%pages to values from fg_v.


%{
function [err_decr_percs,ERR_DECR_PERCs]=...
         MVDR_test_feb22(num_mics,Lv,rand_trials,...
         num_bands_v,Fs,update,sect_len,shift_siz,interf_rms,fg_v)
%}
%close all

%
num_mics=8;
Lv=[1 .9];
rand_trials=50;
num_bands_v=[18 24 36];
Fs=22050;
sect_len=1024;
shift_siz=32;
interf_rms=.05;
fg_v=[.6 .97 .95 .93];
update=1;

rng('default')

%}
%%
%NOTE:
%all lengths/space coordinates in meters, frequencies in Hz, time in sec

for misc_prelim=1:1
%MISC PRELIMINARY SETUP:
%clc
rng('shuffle')
distort_flag=1; %whether to add slowly time-varying distrotion 
                %to clean signal

j = sqrt(-1);
pi2=2*pi;
j2pi = j*pi2;

c=339;%approx. speed of sound at altitude of Columbus, OH

%MVDR conditioning constants
epsi=1e-13;
cndfctr=1.03;
CND=ones(num_mics)+((cndfctr-1)*diag(ones(1,num_mics)));

%blocks and sections setup
fft_siz=1024;
sig_len=sect_len*rand_trials;%all rand interf. trials put in 1 long signal
num_blocks=(sig_len)/(shift_siz)-1;
if mod(num_blocks,1)
    error('make sure a section of test signal fits integer num of blocks')
end

%setup of frequency bins and frequencies in Hz

%Number of DFT bins which approx. represent the speech spectrum
%should be divible by 36 or 18 (to test with 18 or 36 sub-bands)

%Thus for each sampling frequency, particular bin numbers that satisfy
%above condition are chosen:
%if Fs==44100
%    fbin_btL=7+1;%bin~300 Hz
%    fbin_tpL=78+1;%~3400 Hz
if Fs==22050
    fbin_btL=14+1;%~300 Hz
    fbin_tpL=157+1;%~3400 Hz
%elseif Fs==7350
%    fbin_btL=42+1;%~300 Hz
%    fbin_tpL=473+1;%~3400 Hz
else
    error('only Fs=22050 supported')
end
BW=fbin_tpL-fbin_btL+1;

fbin_btR=fft_siz-(fbin_btL-1)+1;%bin for -300Hz chosen accordingly
fbin_tpR=fft_siz-fbin_tpL+1+1;
whole_spectr=[fbin_btL:fbin_tpL fbin_tpR:fbin_btR];

%compute actual frequency values which represent the bottom and the top bin
f_bt=fbin_btL/fft_siz*Fs;%~=300Hz
f_tp=fbin_tpL/fft_siz*Fs;%~=3400Hz

%for corresponding bin numbers for a sect_len-point fft used for measuring
%frequency domain error for each outpu
FBIN_btL=round(f_bt/Fs*sect_len+1);
FBIN_tpL=round(f_tp/Fs*sect_len+1);
FBIN_tpR=sig_len-FBIN_btL+2;
FBIN_btR=sig_len-FBIN_tpL+2;
WHOLE_SPECTR100=[100*(FBIN_btL-1)+1:100*(FBIN_tpL-1)+1 ...
              100*(FBIN_tpR-1)+1:100*(FBIN_btR-1)+1];

%
Fs2=Fs/2;
F=[0 (f_bt+20)/(Fs2) (f_bt+30)/(Fs2) (f_tp-30)/(Fs2) (f_tp-20)/(Fs2) 1];
A=[0        0           1               1               0             0];
BPF=reprow( fft([firls(sect_len,F,A) zeros(1,sect_len-1)]), num_mics);
%firls(sig_len,F,A) returns a length sig_len+1 filter unit pulse repsonse
sect_pad=zeros(num_mics,sect_len);
inpad_len=(fft_siz-shift_siz)/2;
inpad=zeros(num_mics,inpad_len);
ham_sect=hamming(sect_len,'periodic')';
end


for generate_interf=1:1
%GENERATE INTERFERENCE
num_perm=2;
num_temp=10;
num_interf=num_perm+num_temp;

filename=[...
      'D:\android-beamforming\10 - Code\04 - Geintegreerd\Beamformers\MVDR speech',...
          '\Ohio_Stadium_noise24.wav'];
[interf,fft_fctrs,fft_fctr,interflocs_cel,strtpos,k,shift_smp] =...
   gener_interf_old(filename,22050,num_perm,num_temp,rand_trials,sect_len);      

end


for interf_signals=1:1
%INTERFERENCE SIGNALS SETUP:

%for each mic array: precalculate time delays from the 
%interferers to each mic in the array.

%All mic arrays here have num_mics mics uniformly spaced along x axis,
%centered at origin; they vary only in length and thus the mic spacing).
input=zeros(num_mics,sig_len);
inputs=zeros(num_mics,sig_len+inpad_len*2,length(Lv));

    
for L_ind=1:length(Lv)
    L=Lv(L_ind);
    miclocs=linspace(-L/2,L/2,num_mics)';

for sect=1:rand_trials
    interflocs=interflocs_cel{sect};
    interf_delays=zeros(num_mics,num_interf,length(Lv),rand_trials);
    
    xmicinterf=zeros(num_mics,num_interf);
    for interf_ind=1:num_interf
        for mic_num=1:num_mics
            xmicinterf(mic_num,interf_ind)=...
            interflocs(1,interf_ind)-miclocs(mic_num);
            %calculate horiz dist from each source and interferer to
            %current mic in the current mic array
        end
    end

    ymicinterf=reprow(interflocs(2,:),num_mics);
    %y coords of mic locations are all 0 so y_interf_i-y_mic_n=y_interf_i

    interf_delays(:,:,L_ind,sect)=sqrt(xmicinterf.^2+ymicinterf.^2)/c;
    input_sect=zeros(num_mics,k);

    for interf_ind=1:num_perm
        INTERF0=fft( interf{interf_ind});
        %balance frequency spectrum for each interference source
        INTERF0=INTERF0.*...
                (9*mean(abs(INTERF0))+abs(INTERF0))/10  ./ abs(INTERF0);
       
        %normalize not to make some interference sources
        %disproportionately loud or quiet after the balancing
        INTERF0=INTERF0./max(abs(INTERF0));
      
        INTERF_MICS=reprow(INTERF0,num_mics);
        
        interf_mics=real(ifft(INTERF_MICS.*...
        exp(interf_delays(:,interf_ind,L_ind,sect)*...
         fft_fctr),[],2));
        
        input_sect=input_sect+interf_mics;
          
    end

    for interf_ind=interf_ind+1:num_temp
        el=length(interf{interf_ind});
        strt=strtpos(interf_ind-num_perm);
        
        INTERF0=fft( interf{interf_ind});
        
        %balance frequency spectrum for each interference source
        INTERF0=INTERF0.*...
                (9*mean(abs(INTERF0))+abs(INTERF0))/10  ./ abs(INTERF0);
        %normalize not to make some interference sources
        %disproportionately loud or quiet after the balancing
        INTERF0=INTERF0/max(abs(INTERF0));
        
        INTERF_MICS=reprow(INTERF0,num_mics);
        interf_mics=real(ifft(INTERF_MICS.*...
            exp(interf_delays(:,interf_ind,L_ind,sect)*...
             fft_fctrs{interf_ind-num_perm}),[],2));
        
        input_sect(:,strt:strt+el-1)=...
            input_sect(:,strt:strt+el-1)+interf_mics;
    end    
    
        input_sect=[input_sect(:,shift_smp:shift_smp+sect_len-1),sect_pad];
        input_sect=real(ifft(fft(input_sect,[],2).*BPF,[],2));
        input_sect=input_sect(:,size(input_sect,2)/2-sect_len/2+1:...
                        size(input_sect,2)/2+sect_len/2);
        input(:,sect_len*(sect-1)+1:sect_len*sect)=input_sect;
        
        
end
    %adjust interference RMS to value specified by input
    input=input*interf_rms/sqrt(mean(input(4,:).^2));
    inputs(:,:,L_ind)=[inpad input inpad];
  
end


end


for clean_signal=1:1
%GENERATING CLEAN SIGNAL

%the desired test signal will be added to the interference
%with appropriate delays. In every block, the desired signal will be
%generated to have a flat magnitude response from 300 to 3400 Hz
%to include a wide range of frequencies covering the speech spectrum.
%Some distortion will be added to flat magnitude signal to make 
%desired signal more variable over time - somewhat like speech.

%clean signal will be simulated as if recorded from a source
%at (0,1) into at a mic at (0,0) to compare to MVDR-processed noisy signal
src_delays=zeros(num_mics,length(Lv));
clean_refs=zeros(num_mics,2*inpad_len+sig_len,length(Lv));
clean_ref=zeros(num_mics,sig_len);

clean_bloc=fir2(fft_siz-1,F,A);
CLEAN_BLOC=1/sqrt(mean(clean_bloc.^2))*fft(clean_bloc);
CLEAN_NODELAY_MICS=reprow(CLEAN_BLOC,num_mics);
des_fft_fctr=-j2pi*[0:(fft_siz)/2 -(fft_siz)/2+1:-1] /fft_siz*Fs;

%generate small random distortion values for clean signal 

CLEAN_BLOCKs_rand_mag=abs(1+.1*randn(rand_trials,BW));

%if flag below not set, then random distortion is omitted
if ~distort_flag
   CLEAN_BLOCKs_rand_mag=1+0*CLEAN_BLOCKs_rand_mag;
end

CLEAN_BLOCKs_rand_mag=...
    [CLEAN_BLOCKs_rand_mag fliplr(CLEAN_BLOCKs_rand_mag)];

for L_ind=1:length(Lv)
    L=Lv(L_ind);

    miclocs=linspace(-L/2,L/2,num_mics)';
    xmicsrc=zeros(1,num_mics);

    for mic_num=1:num_mics
        xmicsrc(mic_num)=0-miclocs(mic_num);            
    end
    
    %y coords of mic locations are all 0 so y_interf_i-y_mic_n=y_interf_i
    ymicsrc=ones(1,num_mics);

    src_delays(:,L_ind)=sqrt(xmicsrc.^2+ymicsrc.^2)/c;
    
    CLEAN_DELAY_MICS=CLEAN_NODELAY_MICS.*...
                         exp(src_delays(:,L_ind)*des_fft_fctr);
    %use closest mic as reference

    distort=CLEAN_BLOCKs_rand_mag(1,:);
    for sect=1:rand_trials
        
        %add memory to distortion over time so it is less like 
        %white noise and more correlated like in a speech signal
        distort=(CLEAN_BLOCKs_rand_mag(sect,:)+9*distort)/10;
        distort_mics=reprow(distort,num_mics);
        CLEAN_DELAY_MICS(:,whole_spectr)=...
            CLEAN_DELAY_MICS(:,whole_spectr).*distort_mics;
        clean_ref_block=real(ifft(CLEAN_DELAY_MICS,[],2));
        
        timepos=(sect_len*(sect-1)+1); 
        clean_ref(:,timepos:timepos+(sect_len)-1)=clean_ref_block;
    end
    clean_refs(:,:,L_ind)=[inpad clean_ref inpad];
end

end


for steering_vector=1:1

vs_cel=cell(length(Lv),length(num_bands_v));
    
for num_bands_ind=1:length(num_bands_v)
    num_bands=num_bands_v(num_bands_ind);
    band_siz=(fbin_tpL-fbin_btL+1)/num_bands;
    if mod(band_siz,1)
        error(['make sure subband size',...
               num2str(num_bands_ind) 'comes out to be an integer'])
    end

    %STEERING VECTOR SETUP:
    fv=zeros(1,num_bands);
    for f_ind=1:num_bands
        fbin_L=((fbin_btL+(f_ind-1)*band_siz)*2+band_siz-1)/2;
        fv(f_ind)=(fbin_L-1)/fft_siz*Fs;
    end

    j2pif=j2pi*fv;

    %preallocate array of steering vectors
    vs_cel{L_ind,num_bands_ind}=zeros(num_mics,num_bands);
    
    for L_ind=1:length(Lv)
        vs_cel{L_ind,num_bands_ind}=...
        exp(  (src_delays(:,L_ind)-min(src_delays(:,L_ind)))  *-j2pif);
    end
    
end
    
end


for results_arrays=1:1
%OUTPUT (and auxiliary) ARRAYS PRELLACOTION
output=zeros(1,sig_len);

DIRT_ERR_RMS_blocks=zeros(num_blocks,1);
PROC_ERR_RMS_blocks=zeros(num_blocks,1);
CLEAN_blocks_ref=zeros(num_blocks,fft_siz*100);
err_decr_percs=zeros(length(Lv),length(num_bands_v),length(fg_v));
ERR_DECR_PERCs=err_decr_percs;




end

%%
%TEST ALL MIC ARRAYS with MVDR
for L_ind = 1:length(Lv)
    L_ind
    
    %look up properly delayed clean signal
    clean=clean_refs(:,:,L_ind);
    
    %various setup for time domain error scores
    clean_reff=clean(4,inpad_len+1:end-inpad_len);
    dirt_err=inputs(4, inpad_len+1:end-inpad_len, L_ind);
    dirt_err_rms=sqrt(mean(dirt_err.^2));
    
    %various setup for frequency magnitude error scores
    dirty_REF=inputs(4,:,L_ind)+clean(4,:);
    for block_num=1:num_blocks
        timepos=(shift_siz*(block_num-1)+1);
        
        CLEAN_block_ref=abs(fft(...
            clean(4,timepos:timepos+fft_siz-1).* ham_sect...
                           ,100*fft_siz));
        
       CLEAN_blocks_ref(block_num,:)=CLEAN_block_ref;

       DIRT_block_ref=abs(fft(...
         dirty_REF(timepos:timepos+fft_siz-1).* ham_sect...
                        ,100*fft_siz));
       DIRT_ERR_temp=...
           CLEAN_block_ref(WHOLE_SPECTR100)-...
           DIRT_block_ref(WHOLE_SPECTR100);
       
       DIRT_ERR_RMS_blocks(block_num)=sqrt(mean(DIRT_ERR_temp.^2));
    end
    
    %try different number of sub-bands  
    for num_bands_ind=1:length(num_bands_v)
    num_bands=num_bands_v(num_bands_ind);
    half_num_bands=fix(num_bands/2);
    band_siz=(fbin_tpL-fbin_btL+1)/num_bands;

        %try diffent forgetting factors
        for fg_ind=1:length(fg_v)
            fg=fg_v(fg_ind);
            R_L=zeros(num_mics,num_mics,num_bands);
            wop_L=zeros(num_mics,num_bands);
            
            %process signal with MVDR block by block
            for block_num=1:num_blocks

                %%
                timepos=(shift_siz*(block_num-1)+1); 

                dirty_block=inputs(:,timepos:timepos+fft_siz-1,L_ind);
                clean_block=clean(:,timepos:timepos+fft_siz-1);

                %convert interference block to frequency domain
                DIRTY_BLOCK=fft(dirty_block,[],2);
                CLEAN_BLOCK=fft(clean_block,[],2);
                
                %add interference to clean signal
                DIRTY_BLOCK=DIRTY_BLOCK+CLEAN_BLOCK;
                
                
                PROCESSED=DIRTY_BLOCK(4,:);

                %calculate and apply MVDR weights one sub-band at a time
                for f_ind=1:num_bands
                %%
                    %define subband edges for pos. & neg. freq pairs:
                    fbin_loL=fbin_btL+(f_ind-1)*band_siz;%left edge
                    fbin_hiL=fbin_loL+band_siz-1;%right edge
                    fbin_loR=fbin_btR-(f_ind-1)*band_siz;%-left edge
                    fbin_hiR=fbin_loR-band_siz+1;%-right edge

                    S_L=DIRTY_BLOCK(:,fbin_loL:fbin_hiL);
                    S_R=DIRTY_BLOCK(:,fbin_loR:-1:fbin_hiR);
                    vsL=vs_cel{L_ind,num_bands_ind}(:,f_ind);

                    %covariance matrix: cov=(cov_old*forget_factor)+cov_new
                    R_L(:,:,f_ind)=R_L(:,:,f_ind)*fg+...
                                   S_L*S_L'.*CND;

                    %If update is 0, new MVDR weights computed:
                    %for only half the sub-bands in one block, 
                    %other half in next block, and so on.
                    %Otherwise, new weights are computed for all bands in
                    %every block.
                    if (   (mod(block_num,2) && f_ind<=half_num_bands)||...
                            ( (~mod(block_num,2)||block_num==1)&&...
                                   f_ind>half_num_bands )              )...
                        ||update
                        
                        wop_L(:,f_ind)=...
                        (R_L(:,:,f_ind)\vsL) ./...
                        (vsL'/R_L(:,:,f_ind)*vsL+epsi);
                    end

                    %weights are applied to both the pos. and neg. freq
                    %subband
                    WS_L=wop_L(:,f_ind)'*S_L;
                    WS_R=wop_L(:,f_ind).'*S_R;

                    PROCESSED([fbin_loL:fbin_hiL,...
                               fbin_loR:-1:fbin_hiR]) = [WS_L WS_R];

                end
                %
                %to plot clean, noisy and processed blocks in frequency for
                %observation
                %remove '{' two lines above
                plot(abs(CLEAN_BLOCK(4,:)))
                title('clean')
%                 pause(1)
                plot(abs(DIRTY_BLOCK(4,:)))
                title('b4')
%                 pause(1)
                plot(abs(PROCESSED))
%                 pause(1)
                %}
                processed=real(ifft(PROCESSED));
                processed=processed(fft_siz/2-(shift_siz)/2+1:...
                                 fft_siz/2+(shift_siz)/2);
                output(timepos:timepos+(shift_siz)-1)=processed;

            end
            
            %calculate time domain error score:
            proc_err_rms=sqrt(mean((output-clean_reff).^2));
            err_decr_percs(L_ind,num_bands_ind,fg_ind)=...
            (dirt_err_rms-proc_err_rms)/dirt_err_rms*100;
            
            %calculate frequency magnitude error score:
            proc_REF=[inpad(1,:) output inpad(1,:)];
       
            for block_num=1:num_blocks
                timepos=(shift_siz*(block_num-1)+1);
               
                CLEAN_block_ref=CLEAN_blocks_ref(block_num,:);
                           
                PROC_block_ref=abs(fft(...
                    proc_REF(timepos:timepos+fft_siz-1).* ham_sect...
                             ,100*fft_siz));
                
                PROC_ERR_temp=...
                    CLEAN_block_ref(WHOLE_SPECTR100)-...
                    PROC_block_ref(WHOLE_SPECTR100);
                
                PROC_ERR_RMS_blocks(block_num)=...
                    sqrt(mean(PROC_ERR_temp.^2));
            end
            
            ERR_DECR_PERCs(L_ind,num_bands_ind,fg_ind)=...
            mean((DIRT_ERR_RMS_blocks-PROC_ERR_RMS_blocks)./...
            DIRT_ERR_RMS_blocks*100);

        end
    end
end

%END OF FILE
%========================================================================