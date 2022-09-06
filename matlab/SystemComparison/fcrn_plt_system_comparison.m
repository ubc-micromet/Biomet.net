function [Stats_xsite,Stats_main] = fcrn_plt_system_comparison(dateIn,SiteId,spec_flag,gmt_to_local)
% [Stats_xsite,Stats_main] = fcrn_plt_system_comparison(dateIn,SiteId)

arg_default('dateIn',now);
arg_default('SiteId',fr_current_siteid);
arg_default('spec_flag',0);
arg_default('gmt_to_local',0);

%----------------------------------------------------------------------
% Re-process data
%----------------------------------------------------------------------
if strcmp(fr_get_pc_name,'XSITE01')
    cd('c:\ubc_pc_setup\site_specific');
else
    cd(fullfile(xsite_base_path,SiteId,'ubc_pc_setup\site_specific'));
end
[Stats_xsite,HF_xsite] = yf_calc_module_main(dateIn,[],2);

cd(fullfile(xsite_base_path,SiteId,'Setup'));
[Stats_main,HF_main] = yf_calc_module_main(dateIn+gmt_to_local,[],2);

%----------------------------------------------------------------------
% HF data rotation
%----------------------------------------------------------------------
[HF_xsite.System(1).EngUnits(:,1:3)] = fr_rotatn_hf(HF_xsite.System(1).EngUnits(:,1:3),...
    [Stats_xsite.XSITE_CP.Three_Rotations.Angles.Eta ...
        Stats_xsite.XSITE_CP.Three_Rotations.Angles.Theta ...
        Stats_xsite.XSITE_CP.Three_Rotations.Angles.Beta]);      

[HF_main.System(1).EngUnits(:,1:3)] = fr_rotatn_hf(HF_main.System(1).EngUnits(:,1:3),...
    [Stats_main.MainEddy.Three_Rotations.Angles.Eta ...
        Stats_main.MainEddy.Three_Rotations.Angles.Theta ...
        Stats_main.MainEddy.Three_Rotations.Angles.Beta]);      

%----------------------------------------------------------------------
% Delays and time vectors
%----------------------------------------------------------------------
% Find IRGA instrument number
irga_xsite = find(strcmp({Stats_xsite.Configuration.Instrument(:).Name}','CP IRGA'));
irga_op    = find(strcmp({Stats_xsite.Configuration.Instrument(:).Name}','OP IRGA'));
irga_main  = find(strcmp({Stats_main.Configuration.Instrument(:).Name}','CP IRGA'));
% Find IRGA & system delays
% First resample data
HF_main_resampled = resample(HF_main.System(1).EngUnits(:,3),10,5,100);  % resample data Fs*P/Q use N=100
HF_main_resampled = resample(HF_main.System(1).EngUnits(:,3),10,5,100);  % resample data Fs*P/Q use N=100
HF_main_inst_resampled = resample(HF_main.Instrument(irga_main).EngUnits(:,1),5,10,100); 
d_sys = fr_delay(HF_xsite.System(1).EngUnits(:,3),HF_main_resampled ,5000);
d_op  = fr_delay(HF_xsite.System(1).EngUnits(:,3),HF_xsite.System(2).EngUnits(:,3),5000);
d_ins = fr_delay(HF_xsite.Instrument(irga_xsite).EngUnits(:,1),HF_main_inst_resampled,5000);
disp(['System Main delay:     ' num2str(d_sys)]);
disp(['System OP delay:       ' num2str(d_op)]);
disp(['Instrument delay:      ' num2str(d_ins)]);

% Time vectors
tv_sys_xsite = ([1:length(HF_xsite.System(1).EngUnits)] )             ./Stats_xsite.Configuration.System(1).Fs;
tv_sys_main  = ([1:length(HF_main.System(1).EngUnits)] - d_sys/2)                      ./Stats_main.Configuration.System(1).Fs;
tv_sys_op    = ([1:length(HF_xsite.System(2).EngUnits)] - d_op)                      ./Stats_main.Configuration.System(1).Fs;
tv_ins_xsite = ([1:length(HF_xsite.Instrument(irga_xsite).EngUnits)])./Stats_xsite.Configuration.Instrument(irga_xsite).Fs;
tv_ins_main  = ([1:length(HF_main.Instrument(irga_main).EngUnits)] - d_ins/2)          ./Stats_main.Configuration.Instrument(irga_main).Fs;
tv_ins_op    = ([1:length(HF_xsite.Instrument(irga_op).EngUnits)])          ./Stats_main.Configuration.Instrument(irga_xsite).Fs;


figure('Name',[datestr(dateIn) ' System w'])
plot(tv_sys_xsite,HF_xsite.System(1).EngUnits(:,3),...
    tv_sys_main, HF_main.System(1).EngUnits(:,3));
legend(sprintf('XSITE %3.2f+/-%3.2f m/s',mean(HF_xsite.System(1).EngUnits(:,3)),std(HF_xsite.System(1).EngUnits(:,3))),...
    sprintf('MainEddy %3.2f+/-%3.2f m/s',mean(HF_main.System(1).EngUnits(:,3)),std(HF_main.System(1).EngUnits(:,3))))
set(gca,'XLim',[0 1800]);
zoom on;

figure('Name',[datestr(dateIn) ' System cup wind speed'])
plot(tv_sys_xsite,sqrt(sum(HF_xsite.System(1).EngUnits(:,1:2).^2,2)),...
    tv_sys_main, sqrt(sum(HF_main.System(1).EngUnits(:,1:2).^2,2)));
legend(sprintf('XSITE %3.2f+/-%3.2f m/s',mean(sqrt(sum(HF_xsite.System(1).EngUnits(:,1:2).^2,2))),std(sqrt(sum(HF_xsite.System(1).EngUnits(:,1:2).^2,2)))),...
    sprintf('MainEddy %3.2f+/-%3.2f m/s',mean(sqrt(sum(HF_main.System(1).EngUnits(:,1:2).^2,2))),std(sqrt(sum(HF_main.System(1).EngUnits(:,1:2).^2,2)))))
set(gca,'XLim',[0 1800]);
zoom on;

figure('Name',[datestr(dateIn) ' System temperatures'])
plot(tv_sys_xsite,detrend(HF_xsite.System(1).EngUnits(:,[4 7 8]),0)+mean(HF_xsite.System(1).EngUnits(:,4)),...
    tv_sys_main, detrend(HF_main.System(1).EngUnits(:,[4 7]),0)+mean(HF_xsite.System(1).EngUnits(:,4)));
legend(sprintf('XSITE Ta %3.2f+/-%3.2f degC',mean(HF_xsite.System(1).EngUnits(:,4)),std(HF_xsite.System(1).EngUnits(:,4))),...
    sprintf('XSITE Tc1 %3.2f+/-%3.2f degC',mean(HF_xsite.System(1).EngUnits(:,7)),std(HF_xsite.System(1).EngUnits(:,7))),...
    sprintf('XSITE Tc2 %3.2f+/-%3.2f degC',mean(HF_xsite.System(1).EngUnits(:,8)),std(HF_xsite.System(1).EngUnits(:,8))),...
    sprintf('MainEddy Ta %3.2f+/-%3.2f degC',mean(HF_main.System(1).EngUnits(:,4)),std(HF_main.System(1).EngUnits(:,4))),...
    sprintf('MainEddy Tc1 %3.2f+/-%3.2f degC',mean(HF_main.System(1).EngUnits(:,7)),std(HF_main.System(1).EngUnits(:,7))))
set(gca,'XLim',[0 1800]);
zoom on;

figure('Name',[datestr(dateIn) ' System CO2'])
plot(tv_sys_xsite,HF_xsite.System(1).EngUnits(:,5),...
    tv_sys_main ,detrend(HF_main.System(1).EngUnits(:,5),0)+mean(HF_xsite.System(1).EngUnits(:,5)),...
    tv_sys_op   ,detrend(HF_xsite.System(2).EngUnits(:,5),0)+mean(HF_xsite.System(1).EngUnits(:,5)));
legend(sprintf('XSITE %3.2f+/-%3.2f ppm',mean(HF_xsite.System(1).EngUnits(:,5)),std(HF_xsite.System(1).EngUnits(:,5))),...
    sprintf('MainEddy %3.2f+/-%3.2f ppm',mean(HF_main.System(1).EngUnits(:,5)),std(HF_main.System(1).EngUnits(:,5))),...
    sprintf('XSITE OP %3.2f+/-%3.2f ppm',mean(HF_xsite.System(2).EngUnits(:,5)),std(HF_xsite.System(2).EngUnits(:,5))))
set(gca,'XLim',[0 1800]);
zoom on;

figure('Name',[datestr(dateIn) ' System H2O'])
plot(tv_sys_xsite,HF_xsite.System(1).EngUnits(:,6),...
    tv_sys_main ,detrend(HF_main.System(1).EngUnits(:,6),0)+mean(HF_xsite.System(1).EngUnits(:,6)),...
    tv_sys_op   ,detrend(HF_xsite.System(2).EngUnits(:,6),0)+mean(HF_xsite.System(1).EngUnits(:,6)));
legend(sprintf('XSITE %3.2f+/-%3.2f mmol/mol',mean(HF_xsite.System(1).EngUnits(:,6)),std(HF_xsite.System(1).EngUnits(:,6))),...
    sprintf('MainEddy %3.2f+/-%3.2f mmol/mol',mean(HF_main.System(1).EngUnits(:,6)),std(HF_main.System(1).EngUnits(:,6))),...
    sprintf('XSITE OP %3.2f+/-%3.2f mmol/mol',mean(HF_xsite.System(2).EngUnits(:,6)),std(HF_xsite.System(2).EngUnits(:,6))))
set(gca,'XLim',[0 1800]);
zoom on;

figure('Name',[datestr(dateIn) ' LI7000 bench temp. & P'])

subplot('Position',subplot_position(4,1,1))
plot(tv_ins_xsite,HF_xsite.Instrument(irga_xsite).EngUnits(:,4));
set(gca,'XTickLabel','','XLim',[0 1800]);
legend('XSITE Tbench')

subplot('Position',subplot_position(4,1,2))
plot(tv_ins_main ,HF_main.Instrument(irga_main).EngUnits(:,3));
set(gca,'XTickLabel','','XLim',[0 1800]);
legend('MainEddy Tbench')

subplot('Position',subplot_position(4,1,3))
plot(tv_ins_xsite,HF_xsite.Instrument(irga_xsite).EngUnits(:,5));
set(gca,'XTickLabel','','XLim',[0 1800]);
legend('XSITE Pbench')

subplot('Position',subplot_position(4,1,4))
plot(tv_ins_main ,HF_main.Instrument(irga_main).EngUnits(:,4));
set(gca,'XLim',[0 1800]);
legend('MainEddy Pbench')
zoom_together(gcf,'x','on');

figure('Name',[datestr(dateIn) ' IRGA diagnostics'])

subplot('Position',subplot_position(2,1,1))
plot(tv_ins_xsite,HF_xsite.Instrument(irga_xsite).EngUnits(:,end),...
     tv_ins_main, HF_main.Instrument(irga_main).EngUnits(:,end));
set(gca,'XTickLabel','','XLim',[0 1800]);
legend('XSITE','MainEddy')

subplot('Position',subplot_position(2,1,2))
plot(tv_ins_op,HF_xsite.Instrument(irga_op).EngUnits(:,6));
set(gca,'XLim',[0 1800]);
legend('XSITE OP diagnostic flag')
zoom_together(gcf,'x','on');


if spec_flag
    
    figure('Name',[datestr(dateIn) ' Cov max CO2'])
    [corr_main,lag_main] = xcorr(detrend(HF_main.System(1).EngUnits(:,3),0),detrend(HF_main.System(1).EngUnits(:,5),0),500);
    [corr_xsite,lag_xsite] = xcorr(detrend(HF_xsite.System(1).EngUnits(:,3),0),detrend(HF_xsite.System(1).EngUnits(:,5),0),500);
    corr_diff = min(corr_xsite)-min(corr_main);
    plot(lag_xsite,corr_xsite,lag_main,corr_main+corr_diff)
    legend('XSITE','MainEddy')
    
    figure('Name',[datestr(dateIn) ' CO2 co-spectrum'])
    semilogx(Stats_xsite.XSITE_CP.Spectra.Flog,Stats_xsite.XSITE_CP.Spectra.fCsd(:,4),...
        Stats_main.MainEddy.Spectra.Flog,Stats_main.MainEddy.Spectra.fCsd(:,4))
    legend('XSITE','MainEddy')
    
    figure('Name',[datestr(dateIn) ' H2O co-spectrum'])
    semilogx(Stats_xsite.XSITE_CP.Spectra.Flog,Stats_xsite.XSITE_CP.Spectra.fCsd(:,5),...
        Stats_main.MainEddy.Spectra.Flog,Stats_main.MainEddy.Spectra.fCsd(:,5))
    legend('XSITE','MainEddy')
    
    figure('Name',[datestr(dateIn) ' w power-spectrum'])
    loglog(Stats_xsite.XSITE_CP.Spectra.Flog,Stats_xsite.XSITE_CP.Spectra.fPsd(:,3),...
        Stats_main.MainEddy.Spectra.Flog,Stats_main.MainEddy.Spectra.fPsd(:,3))
    legend('XSITE','MainEddy')
    
    figure('Name',[datestr(dateIn) ' CO2 power-spectrum'])
    loglog(Stats_xsite.XSITE_CP.Spectra.Flog,Stats_xsite.XSITE_CP.Spectra.fPsd(:,5),...
        Stats_main.MainEddy.Spectra.Flog,Stats_main.MainEddy.Spectra.fPsd(:,5))
    legend('XSITE','MainEddy')
    
    figure('Name',[datestr(dateIn) ' H2O power-spectrum'])
    loglog(Stats_xsite.XSITE_CP.Spectra.Flog,Stats_xsite.XSITE_CP.Spectra.fPsd(:,6),...
        Stats_main.MainEddy.Spectra.Flog,Stats_main.MainEddy.Spectra.fPsd(:,6))
    legend('XSITE','MainEddy')
    
end

return
