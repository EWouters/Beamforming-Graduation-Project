% orientation plot script
height = 8.27;     % Width in inches %based on a4 paper!
width = 11.7;    % Height in inches
alw = 0.75;    % AxesLineWidth
lw = 1.5;      % LineWidth
msz = 8;       % MarkerSize
fsz = 14;      % FontSize
set(0,'defaultLineLineWidth',lw);   % set the default line width to lw
set(0,'defaultLineMarkerSize',msz); % set the default line marker size to msz
set(0,'defaultLineLineWidth',lw);   % set the default line width to lw
set(0,'defaultLineMarkerSize',msz); % set the default line marker size to msz
set(0,'defaultAxesFontSize',fsz);       % set the default font size

% Set the default Size for display
defpos = get(0,'defaultFigurePosition');
set(0,'defaultFigurePosition', [defpos(1) defpos(2) width*100, height*100]);

% HIERVOOR zijn de meetdata nodig van de orientatie metingen!

LAST_ORIENT = 1750;
TIME = (1:LAST_ORIENT)/60;
YLIM_AZ = [-60 60];
YLIM_PI = [-0.5 1.5];
YLIM_RO = [-1.5 -0.5];

%% LOCATIE 1
subplot(3,3,1)
az_1 = rad2deg([m1{2,1}(1:LAST_ORIENT,1), m2{2,3}(1:LAST_ORIENT,1), m3{2,2}(1:LAST_ORIENT,1)]);
plot(TIME, az_1);
legend({'Phone 1', 'Phone 2', 'Phone 3'}, 'location', 'southeast');
title('Azimuth location 1');
xlim([0 ceil(TIME(end))]);
ylim(YLIM_AZ);
xlabel('Time [minutes]');
ylabel('Azimuth [degrees]');

subplot(3,3,4)
pi_1 = rad2deg([m1{2,1}(1:LAST_ORIENT,2), m2{2,3}(1:LAST_ORIENT,2), m3{2,2}(1:LAST_ORIENT,2)]);
plot(TIME, pi_1);
% legend({'Phone 1', 'Phone 2', 'Phone 3'}, 'location', 'southeast');
title('Pitch location 1');
xlim([0 ceil(TIME(end))]);
ylim(YLIM_PI);
xlabel('Time [minutes]');
ylabel('Pitch [degrees]');

subplot(3,3,7)
ro_1 = rad2deg([m1{2,1}(1:LAST_ORIENT,3), m2{2,3}(1:LAST_ORIENT,3), m3{2,2}(1:LAST_ORIENT,3)]);
plot(TIME, ro_1);
% legend({'Phone 1', 'Phone 2', 'Phone 3'}, 'location', 'southeast');
title('Roll location 1');
xlim([0 ceil(TIME(end))]);
ylim(YLIM_RO);
xlabel('Time [minutes]');
ylabel('Roll [degrees]');

%% LOCATIE 2
subplot(3,3,2)
az_2 = rad2deg([m2{2,1}(1:LAST_ORIENT,1), m1{2,2}(1:LAST_ORIENT,1), m3{2,3}(1:LAST_ORIENT,1)]);
plot(TIME, az_2);
% legend({'Phone 1', 'Phone 2', 'Phone 3'}, 'location', 'southeast');
title('Azimuth location 2');
xlim([0 ceil(TIME(end))]);
ylim(YLIM_AZ);
xlabel('Time [minutes]');
set(gca, 'XTick', YLIM_AZ(1):10:YLIM_AZ(2));
% ylabel('Azimuth angle [degrees]');

subplot(3,3,5)
pi_2 = rad2deg([m2{2,1}(1:LAST_ORIENT,2), m1{2,2}(1:LAST_ORIENT,2), m3{2,3}(1:LAST_ORIENT,2)]);
plot(TIME, pi_2);
% legend({'Phone 1', 'Phone 2', 'Phone 3'}, 'location', 'southeast');
title('Pitch location 2');
xlim([0 ceil(TIME(end))]);
ylim(YLIM_PI);
xlabel('Time [minutes]');
% ylabel('Pitch angle [degrees]');

subplot(3,3,8)
ro_2 = rad2deg([m2{2,1}(1:LAST_ORIENT,3), m1{2,2}(1:LAST_ORIENT,3), m3{2,3}(1:LAST_ORIENT,3)]);
plot(TIME, ro_2);
% legend({'Phone 1', 'Phone 2', 'Phone 3'}, 'location', 'southeast');
title('Roll location 2');
xlim([0 ceil(TIME(end))]);
ylim(YLIM_RO);
xlabel('Time [minutes]');
% ylabel('Roll angle [degrees]');

%% LOCATIE 3
subplot(3,3,3)
az_3 = rad2deg([m3{2,3}(1:LAST_ORIENT,1), m2{2,2}(1:LAST_ORIENT,1), m1{2,3}(1:LAST_ORIENT,1)]);
plot(TIME,az_3);
% legend({'Phone 1', 'Phone 2', 'Phone 3'}, 'location', 'southeast');
title('Azimuth location 3');
xlim([0 ceil(TIME(end))]);
ylim(YLIM_AZ);
xlabel('Time [minutes]');
% ylabel('Azimuth angle [degrees]');

subplot(3,3,6)
pi_3 = rad2deg([m3{2,3}(1:LAST_ORIENT,2), m2{2,2}(1:LAST_ORIENT,2), m1{2,3}(1:LAST_ORIENT,2)]);
plot(TIME,pi_3);
% legend({'Phone 1', 'Phone 2', 'Phone 3'}, 'location', 'southeast');
title('Pitch location 3');
xlim([0 ceil(TIME(end))]);
ylim(YLIM_PI);
xlabel('Time [minutes]');
% ylabel('Pitch angle [degrees]');

subplot(3,3,9)
ro_3 = rad2deg([m3{2,3}(1:LAST_ORIENT,3), m2{2,2}(1:LAST_ORIENT,3), m1{2,3}(1:LAST_ORIENT,3)]);
plot(TIME,ro_3);
% legend({'Phone 1', 'Phone 2', 'Phone 3'}, 'location', 'southeast');
title('Roll location 3');
xlim([0 ceil(TIME(end))]);
ylim(YLIM_RO);
xlabel('Time [minutes]');
% ylabel('Roll angle [degrees]');

%% save to file
set(gcf,'InvertHardcopy','on');
set(gcf,'PaperUnits', 'inches');
papersize = get(gcf, 'PaperSize');
left = (papersize(1)- width)/2;
bottom = (papersize(2)- height)/2;
myfiguresize = [left, bottom, width, height];
set(gcf,'PaperPosition', myfiguresize);
% Save the file as PNG
print('improvedExample','-dpng','-r300');