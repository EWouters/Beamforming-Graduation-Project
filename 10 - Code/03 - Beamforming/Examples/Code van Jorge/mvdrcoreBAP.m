function [Xmvdr, varargout] = mvdrcoreBAP(L_b,Nmics,X,EP_ss,epsilon,D,varargin)
% This is used for realtime? 
% Inputs:
% L_b  - length of block?   default: 2048
% Nmics - number of microphones
% X - input signal
% EP_ss - ?? default: sparse(zeros(Nmics*(L_b+1),Nmics*(L_b+1)))
% epsilon - Regularization factor, default: regfactmvdr =10^-1;
% D - delays, default: repmat(a,L_b+1,1).*exp(-1i.*k*dn); a = 1./(4*pi.*dn); dn = distcalc(x_m,x_s);
% varargin - ??

    X = X(1:L_b+1,:).';
    MX = mat2cell(X,Nmics,ones(L_b+1,1));
    Xblk = sparse(blkdiag(MX{:}));

    D = D.';
    D = D(:);    
    
    if nargin > 6
        g = varargin{1};
        if g ~= 1
            G =  fft(g);
            G = G(1:L_b+1,1:Nmics).';
            G = G(:);
            D = D.*G;
        end
    end
    

    P_ss = EP_ss+epsilon;
    P_ss_D = P_ss\D;
    
    MPssD=mat2cell(reshape(P_ss_D,Nmics,L_b+1),Nmics,ones(L_b+1,1));
    PssDblk = sparse(blkdiag(MPssD{:}));
    DPssD = D'*PssDblk;
    DPssD = repmat(DPssD,Nmics,1);
    DPssD=DPssD(:);

    W = P_ss_D./DPssD;
    varargout{1} = W;
    if nargout >1
        Xmvdr = W'*Xblk;
        Xmvdr = [Xmvdr.' ; zeros(L_b-1,1)];
        varargout{2} = Xmvdr;
    end
        
end
