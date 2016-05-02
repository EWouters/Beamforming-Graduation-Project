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

% HIERVOOR zijn de meetdata nodig van de orientatie metingen!
close all;
LAST_ORIENT = 1750;
TIME = (1:LAST_ORIENT)/60;
YLIM_AZ = [-60 60];
YLIM_PI = [-0.5 1.5];
YLIM_RO = [-1.5 -0.5];

%% LOCATIE 1
figure
az_1 = rad2deg([m1{2,1}(1:LAST_ORIENT,1), m2{2,3}(1:LAST_ORIENT,1), m3{2,2}(1:LAST_ORIENT,1)]);
plot(TIME, az_1);
legend({'Phone 1', 'Phone 2', 'Phone 3'}, 'location', 'southeast');
title('Azimuth measurements location 1');
xlim([0 ceil(TIME(end))]);
ylim(YLIM_AZ);
xlabel('Time [minutes]');
ylabel('Azimuth angle [degrees]');
% print to file
set(gcf,'InvertHardcopy','on');
set(gcf,'PaperUnits', 'inches');
papersize = get(gcf, 'PaperSize');
left = (papersize(1)- width)/2;
bottom = (papersize(2)- height)/2;
myfiguresize = [left, bottom, width, height];
set(gcf,'PaperPosition', myfiguresize);
% Save the file as PNG
print('az_loc1','-dpng','-r300');

%%
figure
pi_1 = rad2deg([m1{2,1}(1:LAST_ORIENT,2), m2{2,3}(1:LAST_ORIENT,2), m3{2,2}(1:LAST_ORIENT,2)]);
plot(TIME, pi_1);
legend({'Phone 1', 'Phone 2', 'Phone 3'}, 'location', 'southeast');
title('Pitch measurements location 1');
xlim([0 ceil(TIME(end))]);
ylim(YLIM_PI);
xlabel('Time [minutes]');
ylabel('Pitch angle [degrees]');
% print to file
set(gcf,'InvertHardcopy','on');
set(gcf,'PaperUnits', 'inches');
papersize = get(gcf, 'PaperSize');
left = (papersize(1)- width)/2;
bottom = (papersize(2)- height)/2;
myfiguresize = [left, bottom, width, height];
set(gcf,'PaperPosition', myfiguresize);
% Save the file as PNG
print('pi_loc1','-dpng','-r300');

figure
ro_1 = rad2deg([m1{2,1}(1:LAST_ORIENT,3), m2{2,3}(1:LAST_ORIENT,3), m3{2,2}(1:LAST_ORIENT,3)]);
plot(TIME, ro_1);
legend({'Phone 1', 'Phone 2', 'Phone 3'}, 'location', 'southeast');
title('Roll measurements location 1');
xlim([0 ceil(TIME(end))]);
ylim(YLIM_RO);
xlabel('Time [minutes]');
ylabel('Roll angle [degrees]');
% print to file
set(gcf,'InvertHardcopy','on');
set(gcf,'PaperUnits', 'inches');
papersize = get(gcf, 'PaperSize');
left = (papersize(1)- width)/2;
bottom = (papersize(2)- height)/2;
myfiguresize = [left, bottom, width, height];
set(gcf,'PaperPosition', myfiguresize);
% Save the file as PNG
print('ro_loc1','-dpng','-r300');

%% LOCATIE 2
figure
az_2 = rad2deg([m2{2,1}(1:LAST_ORIENT,1), m1{2,2}(1:LAST_ORIENT,1), m3{2,3}(1:LAST_ORIENT,1)]);
plot(TIME, az_2);
legend({'Phone 1', 'Phone 2', 'Phone 3'}, 'location', 'southeast');
title('Azimuth measurements location 2');
xlim([0 ceil(TIME(end))]);
ylim(YLIM_AZ);
xlabel('Time [minutes]');
ylabel('Azimuth angle [degrees]');
% print to file
set(gcf,'InvertHardcopy','on');
set(gcf,'PaperUnits', 'inches');
papersize = get(gcf, 'PaperSize');
left = (papersize(1)- width)/2;
bottom = (papersize(2)- height)/2;
myfiguresize = [left, bottom, width, height];
set(gcf,'PaperPosition', myfiguresize);
% Save the file as PNG
print('az_loc2','-dpng','-r300');

figure
pi_2 = rad2deg([m2{2,1}(1:LAST_ORIENT,2), m1{2,2}(1:LAST_ORIENT,2), m3{2,3}(1:LAST_ORIENT,2)]);
plot(TIME, pi_2);
legend({'Phone 1', 'Phone 2', 'Phone 3'}, 'location', 'southeast');
title('Pitch measurements location 2');
xlim([0 ceil(TIME(end))]);
ylim(YLIM_PI);
xlabel('Time [minutes]');
ylabel('Pitch angle [degrees]');
% print to file
set(gcf,'InvertHardcopy','on');
set(gcf,'PaperUnits', 'inches');
papersize = get(gcf, 'PaperSize');
left = (papersize(1)- width)/2;
bottom = (papersize(2)- height)/2;
myfiguresize = [left, bottom, width, height];
set(gcf,'PaperPosition', myfiguresize);
% Save the file as PNG
print('pi_loc2','-dpng','-r300');

figure
ro_2 = rad2deg([m2{2,1}(1:LAST_ORIENT,3), m1{2,2}(1:LAST_ORIENT,3), m3{2,3}(1:LAST_ORIENT,3)]);
plot(TIME, ro_2);
legend({'Phone 1', 'Phone 2', 'Phone 3'}, 'location', 'southeast');
title('Roll measurements location 2');
xlim([0 ceil(TIME(end))]);
ylim(YLIM_RO);
xlabel('Time [minutes]');
ylabel('Roll angle [degrees]');
% print to file
set(gcf,'InvertHardcopy','on');
set(gcf,'PaperUnits', 'inches');
papersize = get(gcf, 'PaperSize');
left = (papersize(1)- width)/2;
bottom = (papersize(2)- height)/2;
myfiguresize = [left, bottom, width, height];
set(gcf,'PaperPosition', myfiguresize);
% Save the file as PNG
print('ro_loc2','-dpng','-r300');
%% LOCATIE 3
figure
az_3 = rad2deg([m3{2,3}(1:LAST_ORIENT,1), m2{2,2}(1:LAST_ORIENT,1), m1{2,3}(1:LAST_ORIENT,1)]);
plot(TIME,az_3);
legend({'Phone 1', 'Phone 2', 'Phone 3'}, 'location', 'southeast');
title('Azimuth measurements location 3');
xlim([0 ceil(TIME(end))]);
ylim(YLIM_AZ);
xlabel('Time [minutes]');
ylabel('Azimuth angle [degrees]');
% print to file
set(gcf,'InvertHardcopy','on');
set(gcf,'PaperUnits', 'inches');
papersize = get(gcf, 'PaperSize');
left = (papersize(1)- width)/2;
bottom = (papersize(2)- height)/2;
myfiguresize = [left, bottom, width, height];
set(gcf,'PaperPosition', myfiguresize);
% Save the file as PNG
print('az_loc3','-dpng','-r300');

figure
pi_3 = rad2deg([m3{2,3}(1:LAST_ORIENT,2), m2{2,2}(1:LAST_ORIENT,2), m1{2,3}(1:LAST_ORIENT,2)]);
plot(TIME,pi_3);
legend({'Phone 1', 'Phone 2', 'Phone 3'}, 'location', 'southeast');
title('Pitch measurements location 3');
xlim([0 ceil(TIME(end))]);
ylim(YLIM_PI);
xlabel('Time [minutes]');
ylabel('Pitch angle [degrees]');
% print to file
set(gcf,'InvertHardcopy','on');
set(gcf,'PaperUnits', 'inches');
papersize = get(gcf, 'PaperSize');
left = (papersize(1)- width)/2;
bottom = (papersize(2)- height)/2;
myfiguresize = [left, bottom, width, height];
set(gcf,'PaperPosition', myfiguresize);
% Save the file as PNG
print('pi_loc3','-dpng','-r300');

figure
ro_3 = rad2deg([m3{2,3}(1:LAST_ORIENT,3), m2{2,2}(1:LAST_ORIENT,3), m1{2,3}(1:LAST_ORIENT,3)]);
plot(TIME,ro_3);
legend({'Phone 1', 'Phone 2', 'Phone 3'}, 'location', 'southeast');
title('Roll measurements location 3');
xlim([0 ceil(TIME(end))]);
ylim(YLIM_RO);
xlabel('Time [minutes]');
ylabel('Roll angle [degrees]');
% print to file
set(gcf,'InvertHardcopy','on');
set(gcf,'PaperUnits', 'inches');
papersize = get(gcf, 'PaperSize');
left = (papersize(1)- width)/2;
bottom = (papersize(2)- height)/2;
myfiguresize = [left, bottom, width, height];
set(gcf,'PaperPosition', myfiguresize);
% Save the file as PNG
print('ro_loc3','-dpng','-r300');
