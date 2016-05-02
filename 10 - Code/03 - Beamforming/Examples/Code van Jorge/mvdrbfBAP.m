function ymvdr = mvdrbfBAP(fs,c,L_b,L_be,x_m,x_s,xinput,epsil,delta_s,rtflag)
% Author: dr. Jorge Martinez (J.A.MartinezCastaneda@TuDelft.nl).
%
% Inputs:
% fs - sample rate in Hz
% c  - speed of sound
% L_b  - length of block?   default: 2048
% L_be - ???                default: 2^nextpow2(floor(fs.*0.016));
% x_m - Microphone positions [x y z;]
% x_s - focal_point? of beamformer [x y z;]. Can this be a vector?
% xinput - getexcerpsBAP(sourcein,Nmics,fs,sim_time,recdata,datadir);
% epsil - Regularization factor, default: regfactmvdr =10^-1; om inversie
% makkelijker te maken (ill conditioned) en white noise gain filter.
% Normale kamer: 10e-1 en 10e-3
% Simulatie:   10e-10 tot 10e-9
% delta_s - ???         default: delta_s = 0.90;
% rtflag - real time flag

if logical(mod(L_b/L_be,1))
    error('Beamforming:mvdrbf','The block size for power estimation must be an integer multiple of the block size for the beamforming process');
end


Nmics = size(x_m,1);
dn = distcalc(x_m,x_s);
omega=(0:L_b).'.*pi.*fs./L_b;
k = omega./c;

a = 1./(4*pi.*dn);
D = repmat(a,L_b+1,1).*exp(-1i.*k*dn);

sim_l = size(xinput,1);

epsilon = speye(Nmics*(L_b+1)).*epsil;
mLb = L_b/L_be;

win = sqrt(hanning(2*L_b));
win = repmat(win,1,Nmics);


ymvdr = zeros(sim_l,1);

sim_lb=ceil(sim_l/L_b)-1;

EP_ss = sparse(Nmics*(L_b+1),Nmics*(L_b+1));

if ~rtflag
    %wait_h = waitbar(0,'Calculating PSD','Position',[138.4 345.6 308 60],'Name','Please wait');
    for te = 1:sim_lb-1
        auxte = ((1:2*L_b) + (te-1)*L_b ).';
        X_s = fft(xinput(auxte,1:Nmics).*win);
        
        EP_ss= pwest(L_b,Nmics,X_s,EP_ss,delta_s,te == 1);
        %waitbar(te/sim_lb,wait_h);
    end
    %close(wait_h);
    [~, W]= mvdrcoreBAP(L_b,Nmics,X_s,EP_ss,epsilon,D);
end



%wait_h = waitbar(0,'Applying the beamformer','Position',[138.4 345.6 308 60],'Name','Please wait');
for t = 1:sim_lb-1
    auxt=((1:2*L_b)+(t-1)*L_b).';
    X = fft(xinput(auxt,1:Nmics).*win);
    
    if rtflag
        for te = 1:mLb-1
            if 2*L_b + (t-1)*L_b + (te+1)*L_be < sim_l;
                auxte = ((1:2*L_b) + (t-1)*L_b + (te-1)*L_be).';
                X_s = fft(xinput(auxte,1:Nmics).*win);

                EP_ss = pwest(L_b,Nmics,X_s,EP_ss,delta_s,te+t == 2);
            end
        end
        Xmvdr = mvdrcore(L_b,Nmics,X,EP_ss,epsilon,D);
    else
        X = X(1:L_b+1,:).';
        MX = mat2cell(X,Nmics,ones(L_b+1,1));
        Xblk = sparse(blkdiag(MX{:}));
        Xmvdr = W'*Xblk;
        Xmvdr = [Xmvdr.' ; zeros(L_b-1,1)];
    end
    
    ovl= ifft(Xmvdr,'symmetric');
    ymvdr(auxt) = ymvdr(auxt) + ovl.*win(:,1);
    
  
    %waitbar(t/sim_lb,wait_h);
end
ymvdr = ymvdr./max(abs(ymvdr));

%close(wait_h);

return