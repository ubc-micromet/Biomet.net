function fr_plot_mat_comp(Year,DOYs)
% fr_plot_mat_comp(Year,DOYs)
%
% Produces comparison plots for calculation results stored
% in hhour_path and hhour_path\old 
%
% Used to test new fr_calc_main with profile calculations.
%
% kai* Aug 1, 2003

% Year default: this year
if ~exist('Year') | isempty(Year)
   dv_now = datevec(now);
   Year = dv_now(1);
end

% DOYs default: yesterday
if ~exist('DOYs') | isempty(DOYs)
   DOYs = floor(now) - datenum(Year,1,0) - 1;
end

SiteId = fr_current_siteid;
[pth_data,pth_hhour] = fr_get_local_path;
pth_old = [pth_hhour 'old\'];

fileExt = ['s.h' lower(SiteId(1)) '.mat'];

doy_st = datenum(Year,1,DOYs(1));
doy_ed = datenum(Year,1,DOYs(end));

%------------------------------------------------------------------------------
% Test concentrations Eddy & Profile
%------------------------------------------------------------------------------
switch upper(SiteId)
case 'CR'
   traceName = 'squeeze(stats.AfterRot.AvgMinMax(1,6+5,:))';
case {'PA','BS','JP'}
   traceName = 'squeeze(stats.AfterRot.AvgMinMax(1,6,:))';
end
[DecDOY,co2_ec_new] = fr_join_trace(traceName,doy_st,doy_ed,fileExt,pth_hhour);
[DecDOY,co2_ec_old] = fr_join_trace(traceName,doy_st,doy_ed,fileExt,pth_old);

traceName = 'squeeze(stats.Profile.co2.Avg(:,end))';
[DecDOY,co2_pr_new] = fr_join_trace(traceName,doy_st,doy_ed,fileExt,pth_hhour);
[DecDOY,co2_pr_old] = fr_join_trace(traceName,doy_st,doy_ed,fileExt,pth_old);

traceName = 'squeeze(stats.Fluxes.AvgDtr(:,1:5))';
[DecDOY,fl_new] = fr_join_trace(traceName,doy_st,doy_ed,fileExt,pth_hhour);
[DecDOY,fl_old] = fr_join_trace(traceName,doy_st,doy_ed,fileExt,pth_old);

DecDOY = DecDOY + 1; % because fr_join_trace does return 'julian' DOY.

figure
plot(DecDOY,[co2_ec_old],'r-+',DecDOY,[co2_ec_new],'g-');
title('EC CO_2 Mixing Ratio')
ylabel('ppm')

figure
plot(DecDOY,[co2_pr_old],'r-+',DecDOY,[co2_pr_new],'g-');
title('Profile Top CO_2 Mixing Ratio')
ylabel('ppm')

figure
plot(DecDOY,[co2_ec_new-co2_pr_new],'r-');
title('Difference EC-Profile(top)')
ylabel('ppm')

figure
plot(DecDOY,[fl_old(:,1)],'r-+',DecDOY,[fl_new(:,1)],'g-');
title('EC Latent Heat Flux')
ylabel('W m^{-2}')

figure
plot(DecDOY,[fl_old(:,2:4)],'r-+',DecDOY,[fl_new(:,2:4)],'g-');
title('EC Sensible Heat Flux')
ylabel('W m^{-2}')

figure
plot(DecDOY,[fl_old(:,5)],'r-+',DecDOY,[fl_new(:,5)],'g-');
title('EC CO_2 Flux')
ylabel('\mumol m^{-2} s^{-1}')

switch upper(SiteId)
case {'PA','BS','JP'}
	traceName = 'squeeze(stats.Chambers.Fluxes_Stats.fluxes(:,1))';
	[DecDOY,ch1_new] = fr_join_trace(traceName,doy_st,doy_ed,fileExt,pth_hhour);
	[DecDOY,ch1_old] = fr_join_trace(traceName,doy_st,doy_ed,fileExt,pth_old);
   
   figure
	plot(DecDOY,[ch1_old],'r-+',DecDOY,[ch1_new],'g-');
	title('Chamber 1 CO_2 Flux')
	ylabel('\mumol m^{-2} s^{-1}')
end

return