function [Stats_xsite,Stats_main] = fcrn_plt_system_data(dateIn,SiteId)

arg_default('dateIn',now);
arg_default('SiteId',fr_current_siteid);

if strcmp(fr_get_pc_name,'XSITE01')
    cd('c:\ubc_pc_setup\site_specific');
else
    cd(fullfile(xsite_base_path,SiteId,'ubc_pc_setup\site_specific'));
end
[Stats_xsite,HF_xsite] = yf_calc_module_main(dateIn,[],2);

cd(fullfile(xsite_base_path,SiteId,'Setup'));
[Stats_main,HF_main] = yf_calc_module_main(dateIn,[],2);


tv_sys_xsite = [1:length(HF_xsite.System(1).EngUnits)]./20;
tv_sys_main  = [1:length(HF_main.System(1).EngUnits)]./20;
tv_ins_xsite = [1:length(HF_xsite.Instrument(2).EngUnits)]./20;
tv_ins_main  = [1:length(HF_main.Instrument(2).EngUnits)]./20;

dir_xsite = FR_Sonic_wind_direction(HF_xsite.System(1).EngUnits(:,1:3)','GILLR3');
dir_main  = FR_Sonic_wind_direction(HF_main.System(1).EngUnits(:,1:3)','CSAT3');

[HF_xsite.System(1).EngUnits(:,1:3)] = fr_rotatn_hf(HF_xsite.System(1).EngUnits(:,1:3),...
    [Stats_xsite.XSITE_CP.Three_Rotations.Angles.Eta ...
     Stats_xsite.XSITE_CP.Three_Rotations.Angles.Theta ...
     Stats_xsite.XSITE_CP.Three_Rotations.Angles.Beta]);      

[HF_main.System(1).EngUnits(:,1:3)] = fr_rotatn_hf(HF_main.System(1).EngUnits(:,1:3),...
    [Stats_main.MainEddy.Three_Rotations.Angles.Eta ...
     Stats_main.MainEddy.Three_Rotations.Angles.Theta ...
     Stats_main.MainEddy.Three_Rotations.Angles.Beta]);      

d_sys = fr_delay(HF_xsite.System(1).EngUnits(:,3),HF_main.System(1).EngUnits(:,3),5000);
disp(['Delay: ' num2str(d_sys)]);

[co2_xsite,co2_main] = fr_remove_delay(HF_xsite.System(1).EngUnits(:,5)',...
    HF_main.System(1).EngUnits(:,5)',d_sys,d_sys);
co2 = [co2_xsite',co2_main'];

[h2o_xsite,h2o_main] = fr_remove_delay(HF_xsite.System(1).EngUnits(:,6)',...
    HF_main.System(1).EngUnits(:,6)',d_sys,d_sys);
h2o = [h2o_xsite',h2o_main'];

[w_xsite,w_main] = fr_remove_delay(HF_xsite.System(1).EngUnits(:,3)',...
    HF_main.System(1).EngUnits(:,3)',d_sys,d_sys);
w = [w_xsite',w_main'];

[T_xsite,T_main] = fr_remove_delay(HF_xsite.System(1).EngUnits(:,4)',...
    HF_main.System(1).EngUnits(:,4)',d_sys,d_sys);
T = [T_xsite',T_main'];

[dir_xsite,dir_main] = fr_remove_delay(dir_xsite,dir_main,d_sys,d_sys);
dir = [dir_xsite',dir_main'];
[dir_s,ind_s] = sort(dir(:,1));

tv = [1:length(T)]./20;

wT = detrend(w(ind_s,:),0).*detrend(T(ind_s,:),0);
diff_wT = diff(wT,[],2);

[dir_bin,wT_bin] = bin_avg(dir_s,diff_wT,0:10:360,[1 4 5]);
ind_n = find(wT_bin(:,3)<500);
wT_bin(ind_n,1) = NaN;

figure('Name','Cumulative flux');
plot(tv,cumsum(diff(detrend(w,0).*detrend(T,0),[],2)));

% Where does the flux come from?
figure('Name','Directional flux contribution');
plot(dir_s,cumsum(wT));

% Where does the flux DIFFERENCE come from?
figure('Name','Directional flux DIFFERENCE contribution');
plot(dir_s,cumsum(diff_wT));

% What is the AVERAGE difference from a given direction DIFFERENCE ?
figure('Name','Directional AVERAGE difference');
bar(dir_bin,wT_bin(:,1))

return

plot(runmean(dir(:,1),20*10,1),runmean(diff(detrend(w,0).*detrend(T,0),[],2),20*10,1),'.');

figure('Name',[datestr(dateIn) ' System w'])
plot(tv_sys_xsite+d_sys/20,HF_xsite.System(1).EngUnits(:,3),...
     tv_sys_main,detrend(HF_main.System(1).EngUnits(:,3),0));
legend('XSITE','MainEddy')

figure('Name',[datestr(dateIn) ' System CO2'])
plot(tv_sys_xsite+d_sys/20,HF_xsite.System(1).EngUnits(:,5),...
     tv_sys_main,detrend(HF_main.System(1).EngUnits(:,5),0)+mean(HF_xsite.System(1).EngUnits(:,5)));
legend('XSITE','MainEddy')

figure('Name',[datestr(dateIn) ' w*Ts'])
plot(tv_sys_xsite+d_sys/20,(detrend(HF_xsite.System(1).EngUnits(:,3),1).*detrend(HF_xsite.System(1).EngUnits(:,4),1)),...
     tv_sys_main,(detrend(HF_main.System(1).EngUnits(:,3),1).*detrend(HF_main.System(1).EngUnits(:,4),1)));
legend('XSITE','MainEddy')

figure('Name',[datestr(dateIn) ' w*Ts'])
plot(tv_sys_xsite+d_sys/20,cumsum(detrend(HF_xsite.System(1).EngUnits(:,3),1).*detrend(HF_xsite.System(1).EngUnits(:,4),1)),...
     tv_sys_main,cumsum(detrend(HF_main.System(1).EngUnits(:,3),1).*detrend(HF_main.System(1).EngUnits(:,4),1)));
legend('XSITE','MainEddy')

figure('Name',[datestr(dateIn) ' w*co2'])
plot(tv_sys_xsite+d_sys/20,(detrend(HF_xsite.System(1).EngUnits(:,3),1).*detrend(HF_xsite.System(1).EngUnits(:,5),1)),...
     tv_sys_main,(detrend(HF_main.System(1).EngUnits(:,3),1).*detrend(HF_main.System(1).EngUnits(:,5),1)));
legend('XSITE','MainEddy')

figure('Name',[datestr(dateIn) ' w*co2'])
plot(tv_sys_xsite+d_sys/20,cumsum(detrend(HF_xsite.System(1).EngUnits(:,3),1).*detrend(HF_xsite.System(1).EngUnits(:,5),1)),...
     tv_sys_main,cumsum(detrend(HF_main.System(1).EngUnits(:,3),1).*detrend(HF_main.System(1).EngUnits(:,5),1)));
legend('XSITE','MainEddy')

d_ins = fr_delay(HF_xsite.Instrument(2).EngUnits(:,3),HF_main.Instrument(2).EngUnits(:,3),5000);

% figure('Name',[datestr(dateIn) ' Instrument CO2'])
% plot(tv_ins_xsite+d_ins/20,HF_xsite.Instrument(2).EngUnits(:,1),...
%      tv_ins_main,detrend(HF_main.Instrument(2).EngUnits(:,1),0)+mean(HF_xsite.Instrument(2).EngUnits(:,1)));
% legend('XSITE','MainEddy')
 
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
 
figure('Name',[datestr(dateIn) ' CO2 co-spectrum difference'])
 semilogx(Stats_xsite.XSITE_CP.Spectra.Flog,Stats_xsite.XSITE_CP.Spectra.fCsd(:,4)-Stats_main.MainEddy.Spectra.fCsd(:,4))

 figure('Name',[datestr(dateIn) ' w power-spectrum'])
 loglog(Stats_xsite.XSITE_CP.Spectra.Flog,Stats_xsite.XSITE_CP.Spectra.fPsd(:,3),...
     Stats_main.MainEddy.Spectra.Flog,Stats_main.MainEddy.Spectra.fPsd(:,3))
legend('XSITE','MainEddy')
     
figure('Name',[datestr(dateIn) ' CO2 power-spectrum'])
 loglog(Stats_xsite.XSITE_CP.Spectra.Flog,Stats_xsite.XSITE_CP.Spectra.fPsd(:,5),...
     Stats_main.MainEddy.Spectra.Flog,Stats_main.MainEddy.Spectra.fPsd(:,5))
legend('XSITE','MainEddy')
     
return
