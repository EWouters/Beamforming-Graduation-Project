load check_ir.mat

nieuwe_ir;
originele_ir;

aantal=length(originele_ir)-length(nieuwe_ir);

restore_ir=[nieuwe_ir;...
    zeros(aantal,1)];

plot([originele_ir restore_ir])
