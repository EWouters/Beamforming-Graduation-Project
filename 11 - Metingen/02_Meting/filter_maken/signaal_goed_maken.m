% load bestmic_jun_090.mat bestmic_jun_TSP_090_000_clean
% output=bestmic_jun_TSP_090_000_clean;

close all;

load tsp.mat

aantal_nullen=round((1.640-1.605)*1e4-(1.6430-1.6380)*1e4+16+30-5);
output_padded=[zeros(aantal_nullen,1); output];

l_i=length(input);
l_op=length(output_padded);
diff=l_op-l_i;

if diff<0
    diff=-(diff);
    output_padded=[output_padded; zeros(diff,1)];
elseif diff>0
    input=[input; zeros(diff,1)];
end

input_enkel=input;
output_enkel=output_padded;

%plot([input output_padded/max(abs(output_padded))])

load tsp_full.mat
output_padded=output(0.18e5-280:end);
%plot(input);hold on;plot(output(0.18e5-280:end)/max(abs(output)),'r');hold off;
%axis([1 0.4e5 -1 1])

l_i=length(input);
l_op=length(output_padded);
diff=l_op-l_i;

if diff<0
    diff=-(diff);
    output_padded=[output_padded; zeros(diff,1)];
elseif diff>0
    input=[input; zeros(diff,1)];
end

output=output_padded;
