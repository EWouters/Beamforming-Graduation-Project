RATIO=1.3;
height = 5;     % Width in inches %based on a4 paper!
width = height*RATIO;    % Height in inches
alw = 0.75;    % AxesLineWidth
lw = 1.5;      % LineWidth
msz = 8;       % MarkerSize
fsz = 14;       % FontSize
set(0,'defaultLineLineWidth',lw);   % set the default line width to lw
set(0,'defaultLineMarkerSize',msz); % set the default line marker size to msz
set(0,'defaultLineLineWidth',lw);   % set the default line width to lw
set(0,'defaultLineMarkerSize',msz); % set the default line marker size to msz
set(0,'defaultAxesFontSize',fsz);       % set the default font size

% Set the default Size for display
defpos = get(0,'defaultFigurePosition');
set(0,'defaultFigurePosition', [defpos(1) defpos(2) width*100, height*100]);
close all;

%%
% load result.mat
number_of_minutes = 0.5;
freq_res = 1/(number_of_minutes*60);
time = 48e3*60*number_of_minutes;
trnsfrm = abs(fft(result(1:time,1)));
trnsfrm2 = abs(fft(result(1:time,2)));
trnsfrm3 = abs(fft(result(1:time,3)));
trnsfrm = trnsfrm(1:round(length(trnsfrm)/2));
trnsfrm2 = trnsfrm2(1:round(length(trnsfrm2)/2));
trnsfrm3 = trnsfrm3(1:round(length(trnsfrm3)/2));

figure
hold on; grid on;
norm_fact = max(max([trnsfrm trnsfrm2 trnsfrm3]));
plot(((freq_res:freq_res:24e3)-15000)*48/15,trnsfrm/norm_fact, '--');
plot(((freq_res:freq_res:24e3)-15000)*48/15,trnsfrm2/norm_fact);
plot(((freq_res:freq_res:24e3)-15000)*48/15,trnsfrm3/norm_fact);
% ylim([0.08 0.2]);
xlim([0 0.75]);
xlabel('Sampling rate offset [Hz]');
ylabel('Normalized amplitude');
legend({'Phone 1', 'Phone 2', 'Phone 3'}, 'location', 'northeast')
%set(gca,'ytick',resolutie*[-10000:10000]) 
title('SRO for one 30 second window');
% print to file
set(gcf,'InvertHardcopy','on');
set(gcf,'PaperUnits', 'inches');
papersize = get(gcf, 'PaperSize');
left = (papersize(1)- width)/2;
bottom = (papersize(2)- height)/2;
myfiguresize = [left, bottom, width, height];
set(gcf,'PaperPosition', myfiguresize);
% Save the file as PNG
print('sro_peak_detection_0.5','-dpng','-r300');

