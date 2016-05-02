%MVDR Beamforming function which can process
%an arbitrary signal over spectrum of 300-3400 or 150-6300 Hz
%SIGNAL LENGTH MUST BE DIVISIBLE BY 32.

%Sample inputs:
%load inputbuffer3_Shrt.mat and use inputbuffer3 as dirty
%Fs=22050 Hz
%L=1, uniform linear microphone array length
%num_bands=18, number of su-bands
%fg=.995, forgetting factor
%hifi=0 or 1; 0=>300-3400 Hz BPF, 1=>150-6300 Hz BPF

%OUTPUTS:
%output is the processed waveform, tm is the processing time

function[output tm]=MVDR_speech(dirty,Fs,L,num_bands,fg,hifi)

%NOTE:
%all lengths/space coordinates in meters, frequencies in Hz, time in sec

for misc_prelim=1:1
%MISC PRELIMINARY SETUP:
c=339;%approx. speed of sound at altitude of Columbus, OH

num_mics=size(dirty,1);
sig_len=size(dirty,2);
%half_num_bands=fix(num_bands/2);

fft_siz=1024;
shift_siz=32;
num_blocks=(sig_len)/(shift_siz)-1;
if mod(num_blocks,1)
    error('make sure a section of test signal fits integer num of blocks')
end

%conditioning constants for MVDR optimal weight equtation
epsi=1e-13;%small number to prevent division by zero
cndfctr=1.03;%diagonal of covariance matrix multiplied
%by this factor to avoid singularity
%resulting conditioning matrix by which to multiply covariance matrix
CND=(cndfctr-1)*diag(ones(1,num_mics))+ones(num_mics);


if Fs==44100
    fbin_btL=7+1;%bin nearest 300 Hz
    fbin_tpL=78+1;%bin ~3400 Hz
elseif Fs==22050
    if hifi
    fbin_btL=7+1;%~300 Hz
    fbin_tpL=294+1;%~6300 Hz
    else
    fbin_btL=14+1;%~300 Hz
    fbin_tpL=157+1;%~6500 Hz        
    end
elseif Fs==7350
    fbin_btL=42+1;%~300 Hz
    fbin_tpL=473+1;%~3400 Hz
else
    error('only Fs=7350, 22050, sand 44100 supported')
end
fbin_btR=fft_siz-(fbin_btL-1)+1;
f_bt=fbin_btL/fft_siz*Fs;%f~=300Hz
f_tp=fbin_tpL/fft_siz*Fs;%f~=3400Hz

j = sqrt(-1);
pi2=2*pi;
j2pi = j*pi2;
end


for steering_vect=1:1
%STEERING VECTOR SETUP:

%for each mic array: precalculate time delays from the desired source
%to each mic in the array.

%All mic arrays here have num_mics mics uniformly spaced along x axis,
%centered at origin; they vary only in length and thus the mic spacing).

%Desired Source is assumed to be at coordinates: (0,1)
%assume mics are unifromly spaced
miclocs=linspace(-L/2,L/2,num_mics);

xmicsrc=miclocs;
ymicsrc=ones(1,num_mics);

src_delays=sqrt(xmicsrc.^2+ymicsrc.^2)'/c;

wop_L=zeros(num_mics,num_bands);

band_siz=(fbin_tpL-fbin_btL+1)/num_bands;
if mod(band_siz,1)
    error('make sure subband size comes out to be an integer')
end

%populate array of steering vectors
fv=zeros(1,num_bands);
for f_ind=1:num_bands
    %find center freqs of sub-band to later plug into the steering vectors 
    %only need to compute the positive center freqs (left half of dft)
    fbin_L=((fbin_btL+(f_ind-1)*band_siz)+...
           (fbin_btL+(f_ind-1)*band_siz+band_siz-1))/2;
    fv(f_ind)=(fbin_L-1)/fft_siz*Fs;
end

vssL=exp((src_delays-min(src_delays))*-j2pi*fv);
end


for other_misc=1:1
%OTHER MISC SETUP:

%bandpass filter over the entire processing spectrum
F=...
[0 (f_bt+20)/(Fs/2) (f_bt+30)/(Fs/2) (f_tp-30)/(Fs/2) (f_tp-20)/(Fs/2) 1];
A=[0        0           1               1               0             0];
BPF=reprow( fft(...
            [firls(ceil(sig_len/40)+mod(ceil(sig_len/40),2),F,A)...
    zeros(1,sig_len-1)]), num_mics);
%fir2(sig_len,F,A) is length sig_len+1 by default

%zero pad vector for fast convolution 
outpad=zeros(num_mics,size(BPF,2)-sig_len);

%hamming window will be applied to one time block at a time before fft
ham=reprow(hamming(fft_siz,'periodic'),num_mics);

%vector for zero padding input on each end
dirtpad=zeros(num_mics,(fft_siz-shift_siz)/2);

output=zeros(1,sig_len);
end



for MVDR=1:1
%perform MVDR
tic

%noisy input, 'dirty' will have num_blocks*32 samples zero pad 'dirty' 
%on each end to help correctly reconstruct a matching time domain output
%for example:
%after this padding, the first 1024-sample block will have the first 32
%samples of 'dirty' precisely at its center - exactly as needed.
dirty2=[dirtpad dirty dirtpad];

%covariance matrix starts at zero before
%there is any memory of past covariance matricies
R_L=zeros(num_mics,num_mics,num_bands);


for block_num=1:num_blocks
    
    %blocks shifted by 32 samples
    timepos=(shift_siz*(block_num-1)+1); 
    dirty_block=dirty2(:,timepos:timepos+fft_siz-1).*ham;

    %convert interference block to frequency domain
    DIRTY_BLOCK=fft(dirty_block,[],2);

    PROCESSED=DIRTY_BLOCK(4,:);
   
    
    for f_ind=1:length(fv)

        %work with one subband at a time; 
        %define subband edges for pos. & neg. freq pairs:
        fbin_loL=fbin_btL+(f_ind-1)*band_siz;%left edge
        fbin_hiL=fbin_loL+band_siz-1;%right edge
        fbin_loR=fbin_btR-(f_ind-1)*band_siz;%-left edge
        fbin_hiR=fbin_loR-band_siz+1;%-right edge
        
        
        %current covariance data for pos. and neg. freqs
        S_L=DIRTY_BLOCK(:,fbin_loL:fbin_hiL);
        S_R=DIRTY_BLOCK(:,fbin_loR:-1:fbin_hiR);
        vsL=vssL(:,f_ind);
        
        %compute current covariance matrix
        %cov_new = cov_current + forgetting*cov_old
            R_L(:,:,f_ind)=R_L(:,:,f_ind)*fg+...
            +S_L*S_L'.*CND;
            
        %MVDR weights computed
        %if (mod(block_num,2) && f_ind<=half_num_bands)||...
        %   ((~mod(block_num,2)||block_num==1) && f_ind>half_num_bands)
        wop_L(:,f_ind)=...
            ( R_L(:,:,f_ind) )\vsL ./...
            (vsL'/ (R_L(:,:,f_ind) )*vsL+epsi);
        %end
        
                
        %weights are applied to both the pos. and neg. freq sub-bands
        %neg. freq weights are conj. of pos. freq weights
        WS_L=wop_L(:,f_ind)'*S_L;
        WS_R=wop_L(:,f_ind).'*S_R;

        PROCESSED([fbin_loL:fbin_hiL, fbin_loR:-1:fbin_hiR]) = [WS_L WS_R];

    end
        
        processed=real(ifft(PROCESSED));
        processed=processed(fft_siz/2-(shift_siz)/2+1:...
                             fft_siz/2+(shift_siz)/2);
        
        output(timepos:timepos+(shift_siz)-1)=processed;

end
tm=toc;

end


for final_results=1:1
%FINAL RESULTS:
%zero pad and perform fast convolution with band pass filter
output=real(ifft(fft([output outpad(1,:)]).*BPF(1,:)));
output=output(:,length(BPF)/2-sig_len/2+1:...
                        length(BPF)/2+sig_len/2);
%normalize output amplitude
output=output/max(abs(output))*.9;

end

end
%END OF FILE
%========================================================================