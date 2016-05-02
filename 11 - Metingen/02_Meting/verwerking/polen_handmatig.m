naam_telefoon='NX506';
methods=['MLS';'TSP'];
equalize=1;
jun=0;

phi_naam='000';

Fs=48e3;
y_as_min=125; %Hz
y_as_max=20e3; %Hz

for i=1:2
	method=methods(i,:);
    deze_vector=[naam_telefoon '_' method '_' phi_naam '_000'];
    opdracht=['deze=' deze_vector ''';'];
    eval(opdracht);

    if (strcmp(method,'MLS'))
        if jun==0
            a=AnalyseMLSSequence(double(deze')/2^15,0,10,15,'false',0);
        else
            a=AnalyseMLSSequence(deze,0,10,15,'false',0);
        end
        
        Hz=Fs/length(a);
        
    else
        if jun==0
            w=w_mei;
            a=AnalyseTSPSequence(double(deze')/2^15,0,10,15,0,'circ');
        else
            w=w_jun;
            a=AnalyseTSPSequence(deze,0,10,15,0,'circ');
        end
        c=a;
        a=fft(a);

        b_dB=db(abs(a));
        b_dB=b_dB(1:round(end/2));
        w_use=w;
        b_dB=b_dB+w_use-mean(w_use);
        b_dB=b_dB+30.198435620833777;
        
        % start make equalized
            dB_or=db(abs(a));
            dB_new=dB_or(1:round(end/2));
            dB_new=dB_new+w-mean(w);
            dB_new=dB_new+30.198435620833777;

            dB_new=[dB_new; flipud(dB_new)];

            factor=db2mag(dB_new)./db2mag(dB_or);
            output=factor.*a;
            output=ifft(output,'symmetric');
            b=output(1:1800);
            assignin('base',[naam_telefoon '_' phi_naam '_ir'],b);
            opdracht=['save ' naam_telefoon '_' phi_naam '_ir.mat ' naam_telefoon '_' phi_naam '_ir; clear ' naam_telefoon '_' phi_naam '_ir;'];
            eval(opdracht);
        % end make equalized
        
        %b_dB=b_dB(round(y_as_min/Hz):round(y_as_max/Hz),:);
%         assignin('base',[naam_telefoon '_' phi_naam '_irdB'],b_dB);
%         opdracht=['save ' naam_telefoon '_' phi_naam '_irdB.mat ' naam_telefoon '_' phi_naam '_irdB; plotje= ' naam_telefoon '_' phi_naam '_irdB;'];
%         eval(opdracht);
%         
%         x_as=linspace(125,20e3,round(y_as_max/Hz)-round(y_as_min/Hz)+1);
%         
%         plot(x_as,plotje(round(y_as_min/Hz):round(y_as_max/Hz)))
%         xlabel('Frequency [Hz]','FontSize',12);
%         ylabel ('Gain [dB]','FontSize',12);
%         title(['TSP ' naam_telefoon ' at Elevation of \phi=' phi_naam ' linear, equalized']);
    end

end