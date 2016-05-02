function delay = plot_real_life_example(res)
% plot_real_life_example
% result stored in res variable
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

delay = computeOffsetTD(res(:,1),res(:,2));
res_sync1 = [[zeros(abs(delay),1); res(:,1)] [res(:,2); zeros(abs(delay),1)]];

figure
grid on;
plot(res(:,1)/2^15);hold on;
plot(res_sync1(:,2)/2^15);
ylim([-0.4 0.4]);
xlim([0 12e5]);
xlabel('Sample index');
ylabel('Normalized signal amplitude');
legend({'Phone 1', 'Phone 2'}, 'location', 'northeast')
% resolutie=half_min_resolutie/10;
% set(gca,'ytick',resolutie*[-10000:10000])
title('Unsynchronized incoming signals')
% save
set(gcf,'InvertHardcopy','on');
set(gcf,'PaperUnits', 'inches');
papersize = get(gcf, 'PaperSize');
left = (papersize(1)- width)/2;
bottom = (papersize(2)- height)/2;
myfiguresize = [left, bottom, width, height];
set(gcf,'PaperPosition', myfiguresize);
% Save the file as PNG
print('result_unsynced','-dpng','-r300');

%%
    function [offset, qual] = computeOffsetTD(input, ref)
        %     figure();
        [mlscorr, lag] = xcorr(input,ref);
        mlscorr = mlscorr/(norm(input)*norm(ref));
        [maximum, index] = max(abs(mlscorr));
        %     subplot(numberOfPhones,1,i);
        %     hold on;
        %     plot(lag, mlscorr);
        %     plot(lag(index(1)),maximum,'r+');
        
        % return the offsets
        offset = lag(index(1));
        qual = maximum/var(mlscorr);
    end
figure
grid on;
plot(res_sync1/2^15);
ylim([-0.4 0.4]);
xlim([0 12e5]);
xlabel('Sample index');
ylabel('Normalized signal amplitude');
legend({'Phone 1', 'Phone 2'}, 'location', 'northeast')
title('Synchronized signals')
% save
set(gcf,'InvertHardcopy','on');
set(gcf,'PaperUnits', 'inches');
papersize = get(gcf, 'PaperSize');
left = (papersize(1)- width)/2;
bottom = (papersize(2)- height)/2;
myfiguresize = [left, bottom, width, height];
set(gcf,'PaperPosition', myfiguresize);
% Save the file as PNG
print('result_synced','-dpng','-r300')
end
