% SRO_plot_script
% neemt aan dat de waarden uit processed_result.mat zijn geimporteerd
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
half_min_resolutie = 0.1/3*48/15;

%% 5 minute window
figure
hold on; grid on;
plot((sro_5_minuut{1}(:,2)-15e3)*48/15);
plot((sro_5_minuut{2}(:,2)-15e3)*48/15);
plot((sro_5_minuut{3}(:,2)-15e3)*48/15);
% ylim([0.08 0.2]);
xlim([0 12]);
xlabel('Window index');
ylabel('SRO [Hz]');
legend({'Phone 1', 'Phone 2', 'Phone 3'}, 'location', 'east')
resolutie=half_min_resolutie/10;
set(gca,'ytick',resolutie*[-10000:10000]) 
title('SRO for 5 minute FFT length')
% save
set(gcf,'InvertHardcopy','on');
set(gcf,'PaperUnits', 'inches');
papersize = get(gcf, 'PaperSize');
left = (papersize(1)- width)/2;
bottom = (papersize(2)- height)/2;
myfiguresize = [left, bottom, width, height];
set(gcf,'PaperPosition', myfiguresize);
% Save the file as PNG
print('sro-5min','-dpng','-r300');

%% 4 minute window
figure
hold on; grid on;
plot((sro_4_minuut{1}(:,2)-15e3)*48/15);
plot((sro_4_minuut{2}(:,2)-15e3)*48/15);
plot((sro_4_minuut{3}(:,2)-15e3)*48/15);
% ylim([5 12]);
xlim([0 15]);
xlabel('Window index');
ylabel('SRO [Hz]');
legend({'Phone 1', 'Phone 2', 'Phone 3'}, 'location', 'east')
resolutie = half_min_resolutie/8;
set(gca,'ytick',resolutie*[-10000:10000])
set(gca,'xtick',0:5:30)
title('SRO for 4 minute FFT length')
% save
set(gcf,'InvertHardcopy','on');
set(gcf,'PaperUnits', 'inches');
papersize = get(gcf, 'PaperSize');
left = (papersize(1)- width)/2;
bottom = (papersize(2)- height)/2;
myfiguresize = [left, bottom, width, height];
set(gcf,'PaperPosition', myfiguresize);
% Save the file as PNG
print('sro-4min','-dpng','-r300');

%% 3 minute window
figure
hold on; grid on;
plot((sro_3_minuut{1}(:,2)-15e3)*48/15);
plot((sro_3_minuut{2}(:,2)-15e3)*48/15);
plot((sro_3_minuut{3}(:,2)-15e3)*48/15);
% ylim([5 12]);
xlim([0 20]);
xlabel('Window index');
ylabel('SRO [Hz]');
legend({'Phone 1', 'Phone 2', 'Phone 3'}, 'location', 'east')
resolutie = half_min_resolutie/6;
set(gca,'ytick',resolutie*[-10000:10000])
set(gca,'xtick',0:5:30)
title('SRO for 3 minute FFT length')
% save
set(gcf,'InvertHardcopy','on');
set(gcf,'PaperUnits', 'inches');
papersize = get(gcf, 'PaperSize');
left = (papersize(1)- width)/2;
bottom = (papersize(2)- height)/2;
myfiguresize = [left, bottom, width, height];
set(gcf,'PaperPosition', myfiguresize);
% Save the file as PNG
print('sro-3min','-dpng','-r300');

%% 2 minute window
figure
hold on; grid on;
plot((sro_2_minuut{1}(:,2)-15e3)*48/15);
plot((sro_2_minuut{2}(:,2)-15e3)*48/15);
plot((sro_2_minuut{3}(:,2)-15e3)*48/15);
% ylim([5 12]);
xlim([0 30]);
xlabel('Window index');
ylabel('SRO [Hz]');
legend({'Phone 1', 'Phone 2', 'Phone 3'}, 'location', 'east')
resolutie = half_min_resolutie/4;
set(gca,'ytick',resolutie*[-10000:10000])
set(gca,'xtick',0:5:30)
title('SRO for 2 minute FFT length')
% save
set(gcf,'InvertHardcopy','on');
set(gcf,'PaperUnits', 'inches');
papersize = get(gcf, 'PaperSize');
left = (papersize(1)- width)/2;
bottom = (papersize(2)- height)/2;
myfiguresize = [left, bottom, width, height];
set(gcf,'PaperPosition', myfiguresize);
% Save the file as PNG
print('sro-2min','-dpng','-r300');

%% 1 minute window
figure
hold on; grid on;
plot((sro_1_minuut{1}(:,2)-15e3)*48/15);
plot((sro_1_minuut{2}(:,2)-15e3)*48/15);
plot((sro_1_minuut{3}(:,2)-15e3)*48/15);
% ylim([5 12]);
xlim([0 60]);
xlabel('Window index');
ylabel('SRO [Hz]');
legend({'Phone 1', 'Phone 2', 'Phone 3'}, 'location', 'southeast')
resolutie = half_min_resolutie/2;
set(gca,'ytick',resolutie*[-10000:10000])
set(gca,'xtick',0:10:60)
title('SRO for 1 minute FFT length')
% save
set(gcf,'InvertHardcopy','on');
set(gcf,'PaperUnits', 'inches');
papersize = get(gcf, 'PaperSize');
left = (papersize(1)- width)/2;
bottom = (papersize(2)- height)/2;
myfiguresize = [left, bottom, width, height];
set(gcf,'PaperPosition', myfiguresize);
% Save the file as PNG
print('sro-1min','-dpng','-r300');

%% half minute window
figure
hold on; grid on;
plot((sro_halve_minuut{1}(:,2)-15e3)*48/15);
plot((sro_halve_minuut{2}(:,2)-15e3)*48/15);
plot((sro_halve_minuut{3}(:,2)-15e3)*48/15);
% ylim([0.09 1]);
xlim([0 120])
xlabel('Window index');
ylabel('SRO [Hz]');
legend({'Phone 1', 'Phone 2', 'Phone 3'}, 'location', 'southeast');
resolutie = half_min_resolutie;
set(gca,'ytick',resolutie*[-10000:10000])
set(gca,'xtick',0:20:120)
title('SRO for 30 second FFT length')
% save
set(gcf,'InvertHardcopy','on');
set(gcf,'PaperUnits', 'inches');
papersize = get(gcf, 'PaperSize');
left = (papersize(1)- width)/2;
bottom = (papersize(2)- height)/2;
myfiguresize = [left, bottom, width, height];
set(gcf,'PaperPosition', myfiguresize);
% Save the file as PNG
print('sro-30sec','-dpng','-r300');