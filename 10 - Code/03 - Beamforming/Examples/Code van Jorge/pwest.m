function EP_ssu = pwest(L_b,Nmics,X_s,EP_ss,delta_s,first)

    X_s = X_s(1:L_b+1,:).';
    MX = mat2cell(X_s,Nmics,ones(L_b+1,1));
    Xblk = sparse(blkdiag(MX{:}));

    if first
        EP_ssu = Xblk*Xblk';
    else
        EP_ssu = EP_ss.*delta_s + ( Xblk*Xblk').*(1-delta_s);
    end
        
end
