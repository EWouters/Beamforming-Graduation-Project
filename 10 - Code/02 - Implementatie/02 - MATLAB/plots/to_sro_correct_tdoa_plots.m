width = 5;     % Width in inches
height = 5;    % Height in inches
alw = 0.75;    % AxesLineWidth
fsz = 14;      % Fontsize
lw = 1.5;      % LineWidth
msz = 8;       % MarkerSize
set(0,'defaultLineLineWidth',lw);   % set the default line width to lw
set(0,'defaultLineMarkerSize',msz); % set the default line marker size to msz
set(0,'defaultLineLineWidth',lw);   % set the default line width to lw
set(0,'defaultLineMarkerSize',msz); % set the default line marker size to msz
% Set the default Size for display
defpos = get(0,'defaultFigurePosition');
set(0,'defaultFigurePosition', [defpos(1) defpos(2) width*100, height*100]);

%%
close all;
x=linspace(0,2*pi);
hold on;
plot(x,sin(x));
plot(x,sin(1.1*x-0.3*pi));
legend({'Microphone 1', 'Microphone 2'}, 'location', 'west');
title('TO and SRO present');
xlabel('Time');
ylabel('Measured amplitude');
save
set(gcf,'InvertHardcopy','on');
set(gcf,'PaperUnits', 'inches');
papersize = get(gcf, 'PaperSize');
left = (papersize(1)- width)/2;
bottom = (papersize(2)- height)/2;
myfiguresize = [left, bottom, width, height];
set(gcf,'PaperPosition', myfiguresize);
% Save the file as PNG
print('to-and-sro','-dpng','-r300');

%%
figure
hold on
plot(x,sin(x));
plot(x,sin(1.1*x));
legend({'Microphone 1', 'Microphone 2'}, 'location', 'west');
title('TO eliminated');
xlabel('Time');
ylabel('Measured amplitude');
save
set(gcf,'InvertHardcopy','on');
set(gcf,'PaperUnits', 'inches');
papersize = get(gcf, 'PaperSize');
left = (papersize(1)- width)/2;
bottom = (papersize(2)- height)/2;
myfiguresize = [left, bottom, width, height];
set(gcf,'PaperPosition', myfiguresize);
% Save the file as PNG
print('only-sro','-dpng','-r300');

figure
hold on
plot(x,sin(x));
plot(x,sin(x),'--');
legend({'Microphone 1', 'Microphone 2'}, 'location', 'west');
title('SRO eliminated');
xlabel('Time');
ylabel('Measured amplitude');
save
set(gcf,'InvertHardcopy','on');
set(gcf,'PaperUnits', 'inches');
papersize = get(gcf, 'PaperSize');
left = (papersize(1)- width)/2;
bottom = (papersize(2)- height)/2;
myfiguresize = [left, bottom, width, height];
set(gcf,'PaperPosition', myfiguresize);
% Save the file as PNG
print('synchronized','-dpng','-r300');

figure
hold on
plot(x,sin(x));
plot(x,sin(x-0.2*pi));
legend({'Microphone 1', 'Microphone 2'}, 'location', 'west');
title('TDOA compensated');
xlabel('Time');
ylabel('Measured amplitude');
save
set(gcf,'InvertHardcopy','on');
set(gcf,'PaperUnits', 'inches');
papersize = get(gcf, 'PaperSize');
left = (papersize(1)- width)/2;
bottom = (papersize(2)- height)/2;
myfiguresize = [left, bottom, width, height];
set(gcf,'PaperPosition', myfiguresize);
% Save the file as PNG
print('tdoa-compensated','-dpng','-r300');
