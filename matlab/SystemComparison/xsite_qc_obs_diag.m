function xsite_qc_obs_diag

cd D:\Experiments\QC_OBS\Setup
[Stats,HF_data] = yf_calc_module_main(datenum(2004,7,18,12,0,0),[],1);

tv = linspace(1,1800,length(HF_data.Instrument(1).EngUnits(:,8)));
T = HF_data.Instrument(1).EngUnits(:,7);
w = HF_data.Instrument(1).EngUnits(:,6);
ind = find(HF_data.Instrument(1).EngUnits(:,8)<63);

figure
subplot(2,1,1)
plot(tv,T)
axis([800 1000 19 24])
xlabel('t (s)')
ylabel('T_{sonic} (^\circC)')

subplot(2,1,2)
hist(diff(T),-1:0.02:1)
xlabel('\DeltaT_{sonic}')
ylabel('N')

figure
plot(diff(w),diff(T),'.')
xlabel('\Deltaw_{sonic}')
ylabel('\DeltaT_{sonic}')

return

figure
subplot(2,1,1)
plot(tv,T,tv(ind),T(ind),'r.')
subplot(2,1,2)
plot(tv,w,tv(ind),w(ind),'r.')


return

divider = runmean(T,100,1);

figure
plot(tv,T,tv,divider)

ind = find(T>divider);
figure
plot(tv,T,tv(ind),T(ind),'r.')

figure
hist(diff(T(ind)),-1:0.02:1)

return

% Comparison MAIN SITE vs MAIN SITE with diag excluded
tv_exp = datenum(2004,7,17:19);

cd D:\Experiments\QC_OBS\Setup_XSITE
Stats_xsite = fcrn_load_data([tv_exp tv_exp(end)+1]);

cd D:\Experiments\QC_OBS\Setup
Stats_main = fcrn_load_data(tv_exp);

cd D:\Experiments\QC_OBS\Setup_exclude_diag
%new_calc_and_save(datenum(2004,6,18),[],1);
Stats_exdiag = fcrn_load_data(tv_exp);

tv_july  = get_stats_field(Stats_main,'TimeVector') - datenum(2004,7,0);
N_main   = get_stats_field(Stats_main,'Instrument(1).MiscVariables.NumOfSamples');
N_exdiag = get_stats_field(Stats_exdiag,'Instrument(1).MiscVariables.NumOfSamples');

Stats_xsite = Stats_xsite(11:10+(length(tv_exp)*48));
fc_xsite  = get_stats_field(Stats_xsite,'XSITE_CP.Three_Rotations.AvgDtr.Fluxes.Fc');
fc_main   = get_stats_field(Stats_main,'MainEddy.Three_Rotations.AvgDtr.Fluxes.Fc');
fc_exdiag = get_stats_field(Stats_exdiag,'MainEddy.Three_Rotations.AvgDtr.Fluxes.Fc');

Hs_xsite  = get_stats_field(Stats_xsite,'XSITE_CP.Three_Rotations.AvgDtr.Fluxes.Hs');
Hs_main   = get_stats_field(Stats_main,'MainEddy.Three_Rotations.AvgDtr.Fluxes.Hs');
Htc_main   = get_stats_field(Stats_main,'MainEddy.Three_Rotations.AvgDtr.Fluxes.Htc1');
Hs_exdiag = get_stats_field(Stats_exdiag,'MainEddy.Three_Rotations.AvgDtr.Fluxes.Hs');

figure
plot(tv_july,[N_main,N_exdiag])

figure
plot(tv_july,[fc_xsite,fc_main,fc_exdiag])

figure
plot(tv_july,[Hs_xsite,Hs_main,Hs_exdiag,Htc_main])
axis([17 20 -100 1000])
 
return

%---------------------------------------------------------------------
% Comparison XSITE vs MAIN SITE 
tv_exp = datenum(2004,7,17:22);
cd D:\Experiments\QC_OBS\Setup_XSITe
Stats_xsite = fcrn_load_data(tv_exp);

cd D:\Experiments\QC_OBS\Setup
% new_calc_and_save(datenum(2004,6,16:20),[],1);
Stats_site = fcrn_load_data(tv_exp);

Stats_all = fcrn_merge_stats(Stats_xsite,Stats_site,5/24);
Stats_all(1).Configuration.pth_tv_exclude = Stats_site(1).Configuration.hhour_path;

% Winddir to exclude
tv  = get_stats_field(Stats_all,'TimeVector');
wd  = get_stats_field(Stats_all,'Instrument(1).MiscVariables.WindDirection');
ust = get_stats_field(Stats_all,'XSITE_CP.Three_Rotations.AvgDtr.Fluxes.Ustar');
AGC_xsite = get_stats_field(Stats_all,'Instrument(3).MiscVariables.AGC_Max');
AGC_main  = get_stats_field(Stats_all,'Instrument(end).MiscVariables.AGC_Max');
CSAT_diag_max  = get_stats_field(Stats_all,'Instrument(end-2).Max(end)');
tv_jul = tv - datenum(2004,7,0);

figure(1)
subplot('Position',subplot_position(2,1,1));
plot(tv_jul,[AGC_xsite,AGC_main]);
subplot_label(gca,2,1,1);

subplot('Position',subplot_position(2,1,2));
plot(tv_jul,[CSAT_diag_max]);
subplot_label(gca,2,1,2);



return