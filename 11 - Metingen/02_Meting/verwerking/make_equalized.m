function output = make_equalized(input,w,begin,eind)

    dB_or=db(abs(input));
    dB_new=dB_or(1:round(end/2),:);
    dB_new=dB_new+w*ones(1,41)-mean(w);
    dB_new=dB_new+30.198435620833777;
    
    dB_new=[dB_new; flipud(dB_new)];
    
    factor=db2mag(dB_new)./db2mag(dB_or);
    
    output=factor.*input;
    %output_nullen=zeros(size(output));
    %output_nullen(begin:eind,:)=output(begin:eind,:);
    
    output=ifft(output,'symmetric');
    output=output(1:1800,:);
end