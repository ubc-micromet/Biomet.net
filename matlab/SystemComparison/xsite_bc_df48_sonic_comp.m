%----------------------------
% Load data and merge
%----------------------------
% tv_exp = datenum(2005,4,27):datenum(2005,5,4);
tv_exp = datenum(2005,5,5):floor(now);
cd(fullfile(xsite_base_path,'bc_df48','setup_xsite'));
Stats_xsite = fcrn_load_data(tv_exp);

cd(fullfile(xsite_base_path,'bc_df48','setup'));
Stats_main = fcrn_load_data(tv_exp);

Stats_all = fcrn_merge_stats(Stats_xsite,Stats_main,0/24);

% fcrn_clean(Stats_all,{'Instrument(1)','Instrument(10)'},'report_sonic_comp',[],0,[20 20]);
% fcrn_clean(Stats_all,{'Instrument(1)','Instrument(15)'},'report_sonic_comp',[],0,[20 20]);
% fcrn_clean(Stats_all,{'Instrument(10)','Instrument(15)'},'report_sonic_comp',[],0,[20 20]);

%----------------------------
% Rotate Sonic data
%----------------------------
for i = 1:length(Stats_all)
    try
        wd(i) = Stats_all(i).Instrument(16).Avg(2);
        ws(i) = Stats_all(i).Instrument(16).Avg(1);
        
        [sonic1(i,:),cov1(:,:,i),angles1(i,:)]    = FR_rotate(Stats_all(i).Instrument(1).Avg(1:3),Stats_all(i).Instrument(1).Cov,'N');
        [sonic10(i,:),cov10(:,:,i),angles10(i,:)] = FR_rotate(Stats_all(i).Instrument(10).Avg(1:3),Stats_all(i).Instrument(10).Cov,'N');
        [sonic15(i,:),cov15(:,:,i),angles15(i,:)] = FR_rotate(Stats_all(i).Instrument(15).Avg(1:3),Stats_all(i).Instrument(15).Cov,'N');

        tv(i) = Stats_all(i).TimeVector;
    end
end

%----------------------------
% Plot regressions
%----------------------------
wd = 360 - wd(:);
ws = ws(:);
ind = find(wd < 150); % good wind directions

%----------------------------
% Average wind speeds
%----------------------------
figure('Name','Average Wind speed comparison')

subplot(2,2,1);
plot_regression(sonic1(ind,1),sonic15(ind,1),[],[],'ortho');
xlabel('XSITE');
ylabel('Main');

subplot(2,2,2);
plot_regression(sonic1(ind,1),sonic10(ind,1),[],[],'ortho');
xlabel('XSITE');
ylabel('S/N 244');

subplot(2,2,3);
plot_regression(sonic10(ind,1),sonic15(ind,1),[],[],'ortho');
xlabel('S/N 244');
ylabel('Main');

subplot(2,2,4);
plot_regression(sonic1(ind,1),ws(ind),[],[],'ortho');
xlabel('XSITE');
ylabel('RMY');

%----------------------------
% var(u) covariances
%----------------------------
figure('Name','var(u) comparison')

subplot(2,2,1);
plot_regression(squeeze(cov1(1,1,ind)),squeeze(cov15(1,1,ind)),[],[],'ortho');
xlabel('XSITE');
ylabel('Main');

subplot(2,2,2);
plot_regression(squeeze(cov1(1,1,ind)),squeeze(cov10(1,1,ind)),[],[],'ortho');
xlabel('XSITE');
ylabel('S/N 244');

subplot(2,2,3);
plot_regression(squeeze(cov10(1,1,ind)),squeeze(cov15(1,1,ind)),[],[],'ortho');
xlabel('S/N 244');
ylabel('Main');

%----------------------------
% var(w) covariances
%----------------------------
figure('Name','var(w) comparison')

subplot(2,2,1);
plot_regression(squeeze(cov1(3,3,ind)),squeeze(cov15(3,3,ind)),[],[],'ortho');
xlabel('XSITE');
ylabel('Main');

subplot(2,2,2);
plot_regression(squeeze(cov1(3,3,ind)),squeeze(cov10(3,3,ind)),[],[],'ortho');
xlabel('XSITE');
ylabel('S/N 244');

subplot(2,2,3);
plot_regression(squeeze(cov10(3,3,ind)),squeeze(cov15(3,3,ind)),[],[],'ortho');
xlabel('S/N 244');
ylabel('Main');

%----------------------------
% u,w covariances
%----------------------------
figure('Name','cov(u,w) comparison ')

subplot(2,2,1);
plot_regression(squeeze(cov1(1,3,ind)),squeeze(cov15(1,3,ind)),[],[],'ortho');
xlabel('XSITE');
ylabel('Main');

subplot(2,2,2);
plot_regression(squeeze(cov1(1,3,ind)),squeeze(cov10(1,3,ind)),[],[],'ortho');
xlabel('XSITE');
ylabel('S/N 244');

subplot(2,2,3);
plot_regression(squeeze(cov10(1,3,ind)),squeeze(cov15(1,3,ind)),[],[],'ortho');
xlabel('S/N 244');
ylabel('Main');

%----------------------------
% var(Ts) covariances
%----------------------------
figure('Name','var(Ts) comparison')

subplot(2,2,1);
plot_regression(squeeze(cov1(4,4,ind)),squeeze(cov15(4,4,ind)),[],[],'ortho');
xlabel('XSITE');
ylabel('Main');

subplot(2,2,2);
plot_regression(squeeze(cov1(4,4,ind)),squeeze(cov10(4,4,ind)),[],[],'ortho');
xlabel('XSITE');
ylabel('S/N 244');

subplot(2,2,3);
plot_regression(squeeze(cov10(4,4,ind)),squeeze(cov15(4,4,ind)),[],[],'ortho');
xlabel('S/N 244');
ylabel('Main');

%----------------------------
% wTs covariances
%----------------------------
figure('Name','cov(w,Ts) comparison')

subplot(2,2,1);
plot_regression(squeeze(cov1(3,4,ind)),squeeze(cov15(3,4,ind)),[],[],'ortho');
xlabel('XSITE');
ylabel('Main');

subplot(2,2,2);
plot_regression(squeeze(cov1(3,4,ind)),squeeze(cov10(3,4,ind)),[],[],'ortho');
xlabel('XSITE');
ylabel('S/N 244');

subplot(2,2,3);
plot_regression(squeeze(cov10(3,4,ind)),squeeze(cov15(3,4,ind)),[],[],'ortho');
xlabel('S/N 244');
ylabel('Main');
