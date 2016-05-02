 %  Read in chunk of data and filter
pfa = 1e-4;  %  Probably of false positive
tscl = -log(pfa);  %  Scale to convert energy estimate to threshold
bseg = 1;  %  Start segment index
eseg = bseg+nwlen-1;  % End segment index
ninc = (nwlen)/2;
cnt = 0;
ff = .95;  %  forgetting factor for noise power estimate
b = 1;  %  Set high so it will start off not detecting
while eseg<= length(a)
    %  Get energy in segment
 gg = std(a(bseg:eseg))^2;
 %  Compare to treshold based on noise power history
 if gg > tscl*b;
     cnt=cnt+1;  % increment detection counter
     det(cnt) = bseg;  %  If detected, save position don't update noise power   
 else
    b = (ff*b + gg)/(1-ff);  %  Updated noise energy
 end
 %  Go to next segment
 bseg = ninc + bseg;
 eseg = bseg+nwlen-1;
end
 
    
