% TD and FD operation plot
% first, load simulatieresultaten synchronisatie 2015-06-12.mat
    % orientation plot script
RATIO=1.3;
height = 5;     % Width in inches %based on a4 paper!
width = height*RATIO;    % Height in inches
alw = 0.75;    % AxesLineWidth
lw = 1.5;      % LineWidth
msz = 8;       % MarkerSize
fsz = 18;       % FontSize
set(0,'defaultLineLineWidth',lw);   % set the default line width to lw
set(0,'defaultLineMarkerSize',msz); % set the default line marker size to msz
set(0,'defaultLineLineWidth',lw);   % set the default line width to lw
set(0,'defaultLineMarkerSize',msz); % set the default line marker size to msz
set(0,'defaultAxesFontSize',fsz);       % set the default font size

% Set the default Size for display
defpos = get(0,'defaultFigurePosition');
set(0,'defaultFigurePosition', [defpos(1) defpos(2) width*100, height*100]);


close all
input_sig = delayed_signals{5,10};
input_sig = awgn(input_sig, -20);

%% TD algorithm
[res, ind] = xcorr(input_sig,pulse);
[maxi, max_i] = max(abs(res));
figure; 
hold on;
plot(ind/FS,res/max(res));
plot(ind(max_i)/FS,maxi/max(res),'rx', 'MarkerSize',20);
xlim([-4e4/FS, 4e4/FS]);
ylim([-0.3 1.05]);
xlabel('Lag [s]');
ylabel('Normalized cross corr.');
title('Time-domain algorithm');
legend({'Norm. xcorr', 'Detected max.'}, 'Location', 'West');
% save
% print to file
set(gcf,'InvertHardcopy','on');
set(gcf,'PaperUnits', 'inches');
papersize = get(gcf, 'PaperSize');
left = (papersize(1)- width)/2;
bottom = (papersize(2)- height)/2;
myfiguresize = [left, bottom, width, height];
set(gcf,'PaperPosition', myfiguresize);
% Save the file as PNG
print('td_operation','-dpng','-r300');


%% FD algorithm
L=2^(nextpow2(length(input_sig)+length(pulse)-1));
inputFD=fft(input_sig,L);
refFD=fft(pulse,L);
corrFD = refFD.*conj(inputFD);
corrFD = corrFD(1:(L/2+1));
corrected_phase = unwrap(angle(corrFD));
% xvals = 1:round(length(corrected_phase)*3/4);
xvals = (1:length(corrected_phase))*24/length(corrected_phase);
% xvals = xvals/
%         calculate the slope
dataFit = polyfit(xvals(1:round(length(xvals)*3/4))',corrected_phase(1:round(length(xvals)*3/4)),1);
figure
hold on;
plot(xvals, corrected_phase/1e3);
plot(xvals, (dataFit(1)*xvals+dataFit(2))/1e3, '-');
xlabel('Frequency [kHz]');
ylabel('Phase [krad], unwr.');
title('Frequency-domain algorithm');
legend({'Phase xcorr', 'Linear fit'}, 'location', 'southeast')
% save
% print to file
set(gcf,'InvertHardcopy','on');
set(gcf,'PaperUnits', 'inches');
papersize = get(gcf, 'PaperSize');
left = (papersize(1)- width)/2;
bottom = (papersize(2)- height)/2;
myfiguresize = [left, bottom, width, height];
set(gcf,'PaperPosition', myfiguresize);
% Save the file as PNG
print('fd_operation','-dpng','-r300');
