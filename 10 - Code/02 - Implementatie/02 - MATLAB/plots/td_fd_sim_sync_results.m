% plot synchronization simulation results
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

% process results
SIGMA_IDX  = 1;
DELAY_IDX  = floor(length(DELAYS)/2);
ABSORB_IDX = 1;

run_idx = @(sig_i, del_i, ab_i) 1 + (ab_i-1)*length(NOISE_SIGMAS)*length(DELAYS)*RUNS_PER_PARAM + (del_i-1)*length(NOISE_SIGMAS)*RUNS_PER_PARAM + (sig_i-1)*RUNS_PER_PARAM;
TD_run  = @(sig_i, del_i, ab_i) res_errors_TD(run_idx(sig_i, del_i, ab_i):run_idx(sig_i, del_i, ab_i)+RUNS_PER_PARAM-1);
FD_run  = @(sig_i, del_i, ab_i) res_errors_FD(run_idx(sig_i, del_i, ab_i):run_idx(sig_i, del_i, ab_i)+RUNS_PER_PARAM-1);

rms_per_sigma_TD  = zeros(length(NOISE_SIGMAS), 1);
rms_per_delay_TD  = zeros(length(DELAYS),       1);
rms_per_absorb_TD = zeros(length(ABSORPTIONS),  1);

rms_per_sigma_FD  = zeros(length(NOISE_SIGMAS), 1);
rms_per_delay_FD  = zeros(length(DELAYS),       1);
rms_per_absorb_FD = zeros(length(ABSORPTIONS),  1);

for sigma_index = 1:length(NOISE_SIGMAS)
    rms_per_sigma_FD(sigma_index) = rms(FD_run(sigma_index, DELAY_IDX, ABSORB_IDX));
    rms_per_sigma_TD(sigma_index) = rms(TD_run(sigma_index, DELAY_IDX, ABSORB_IDX));
end

for absorb_index = 1:length(ABSORPTIONS)
    rms_per_absorb_FD(absorb_index) = rms(FD_run(SIGMA_IDX, DELAY_IDX, absorb_index));
    rms_per_absorb_TD(absorb_index) = rms(TD_run(SIGMA_IDX, DELAY_IDX, absorb_index));
end

for delay_index = 1:length(DELAYS)
    rms_per_delay_FD(delay_index) = rms(FD_run(SIGMA_IDX, delay_index, ABSORB_IDX));
    rms_per_delay_TD(delay_index) = rms(TD_run(SIGMA_IDX, delay_index, ABSORB_IDX));
end
%% 
LEGEND = { 'Frequency domain', 'Time domain'};

figure(1);
plot(NOISE_SIGMAS, [rms_per_sigma_FD, rms_per_sigma_TD]);
xlabel('Noise standard deviation'); ylabel('RMS error [samples]');
legend(LEGEND, 'location', 'southeast');
title('Sync. error per noise level')
% print to file
set(gcf,'InvertHardcopy','on');
set(gcf,'PaperUnits', 'inches');
papersize = get(gcf, 'PaperSize');
left = (papersize(1)- width)/2;
bottom = (papersize(2)- height)/2;
myfiguresize = [left, bottom, width, height];
set(gcf,'PaperPosition', myfiguresize);
% Save the file as PNG
print('error-vs-noise','-dpng','-r300');

figure(2);
plot(DELAYS*FS, [rms_per_delay_FD, rms_per_delay_TD],'*');
xlabel('Delay [samples]'); ylabel('RMS error [samples]');
legend(LEGEND);
title('Sync. error per delay value')
% print to file
set(gcf,'InvertHardcopy','on');
set(gcf,'PaperUnits', 'inches');
papersize = get(gcf, 'PaperSize');
left = (papersize(1)- width)/2;
bottom = (papersize(2)- height)/2;
myfiguresize = [left, bottom, width, height];
set(gcf,'PaperPosition', myfiguresize);
% Save the file as PNG
print('error-vs-delay','-dpng','-r300');

%%
figure(3);
hold on;
plot(ABSORPTIONS, (rms_per_absorb_FD), '*');
plot(ABSORPTIONS, (rms_per_absorb_TD), 'x');
xlabel('Reflection coefficient'); ylabel('RMS error [samples]');
% LEGEND = { 'Frequency domain', 'Time domain'};
legend(LEGEND);
title('Sync. error per wall reflection')
% print to file
set(gcf,'InvertHardcopy','on');
set(gcf,'PaperUnits', 'inches');
papersize = get(gcf, 'PaperSize');
left = (papersize(1)- width)/2;
bottom = (papersize(2)- height)/2;
myfiguresize = [left, bottom, width, height];
set(gcf,'PaperPosition', myfiguresize);
% Save the file as PNG
print('error-vs-reflection','-dpng','-r300');


% legend({'TD algorithm', 'FD algorithm'}, 'location', 'west');
% title('TD vs FD algorithm');
% % print('to-and-sro','-dpng','-r300');
