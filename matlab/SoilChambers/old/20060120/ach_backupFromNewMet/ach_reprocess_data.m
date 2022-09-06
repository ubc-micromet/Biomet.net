function ach_reprocess_data(year,SiteId,ch)
%(c)dgg  May 13, 2002

warning off;

year = num2str(year);

%loads cleaned chamber data (slope min and all) from the database
tv_all   = read_bor(['D:\david_data\' year '\' SiteId '\chambers\slope_all\clean\clean_tv'],8);
doy_all  = convert_tv(tv_all,'nod');
dcdt_all = read_bor(['D:\david_data\' year '\' SiteId '\chambers\slope_all\clean\dcdt_ch' num2str(ch)],1);
ev_all   = read_bor(['D:\david_data\' year '\' SiteId '\chambers\slope_all\clean\effective_volume_ch' num2str(ch)],1);
flux_all = read_bor(['D:\david_data\' year '\' SiteId '\chambers\slope_all\clean\co2_flux_ch' num2str(ch)],1);
r2_all   = read_bor(['D:\david_data\' year '\' SiteId '\chambers\slope_all\clean\rsquare_ch' num2str(ch)],1);

tv_min   = read_bor(['D:\david_data\' year '\' SiteId '\chambers\slope_min\clean\clean_tv'],8);
doy_min  = convert_tv(tv_min,'nod');
dcdt_min = read_bor(['D:\david_data\' year '\' SiteId '\chambers\slope_min\clean\dcdt_ch' num2str(ch)],1);
ev_min   = read_bor(['D:\david_data\' year '\' SiteId '\chambers\slope_min\clean\effective_volume_ch' num2str(ch)],1);
flux_min = read_bor(['D:\david_data\' year '\' SiteId '\chambers\slope_min\clean\co2_flux_ch' num2str(ch)],1);
r2_min   = read_bor(['D:\david_data\' year '\' SiteId '\chambers\slope_min\clean\rsquare_ch' num2str(ch)],1);

%recalculates effective volumes using a moving window

%plots the effective volumes
figure(1);
plot(doy_all,ev_all.*1000,'k.',doy_min,ev_min.*1000,'r.');
legend('3 min slope','1 min slope');
ylabel('Effective volume (litres)');
title([SiteId ' - ' year ' - ch' num2str(ch)]);
axis([doy_all(1) doy_all(end) 0 150]);
hold on;


[ev_all_new, ind_all_new]= runmean(ev_all,5*48,1);


ind_nan_ev_all = find(isnan(ev_all));               % find index for the bad points
ind_not_nan_ev_all = find(~isnan(ev_all));          % find index of all good points
ev_all_new(ind_nan_ev_all) = interp1(tv_all(ind_not_nan_ev_all),...
                             ev_all(ind_not_nan_ev_all),...
                             tv_all(ind_nan_ev_all));

ind_nan_ev_all_new = find(isnan(ev_all_new));
ind_nonan_ev_all_new = find(~isnan(ev_all_new));
ev_all_new(ind_nan_ev_all_new) = mean(ev_all_new(ind_nonan_ev_all_new));

[ev_min_new, ind_min_new]= runmean(ev_min,5*48,1);

ind_nan_ev_min = find(isnan(ev_min));               % find index for the bad points
ind_not_nan_ev_min = find(~isnan(ev_min));          % find index of all good points
ev_min_new(ind_nan_ev_min) = interp1(tv_min(ind_not_nan_ev_min),...
                             ev_min(ind_not_nan_ev_min),...
                             tv_min(ind_nan_ev_min));

ind_nan_ev_min_new = find(isnan(ev_min_new));
ind_nonan_ev_min_new = find(~isnan(ev_min_new));
ev_min_new(ind_nan_ev_min_new) = mean(ev_min_new(ind_nonan_ev_min_new));


plot(doy_all,ev_all_new.*1000,'k-',doy_min,ev_min_new.*1000,'r-');
legend('3 min slope','1 min slope');
ylabel('Effective volume (litres)');
axis([doy_all(1) doy_all(end) 0 150]);
hold off;
zoom on;

%recalculates flux with new ev values
if SiteId == 'PA'
 T = read_bor(['\\ANNEX001\DATABASE\' year '\' SiteId '\Clean\SecondStage\air_temperature_1'],1); % PA
 %T = read_bor(['\\ANNEX001\DATABASE\' year '\' SiteId '\Climate\Clean\air_temperature_hmp_50cm'],1); % PA 2001 
 P = read_bor(['\\ANNEX001\DATABASE\' year '\' SiteId '\Climate\Clean\barometric_pressure'],1); % PA 2001  
 T = T + 273.15;
 P = P .* 1000;
   if ch == 3
      A = 0.33;
   else
      A = 0.20;
   end

   if str2num(year) == 2002
      if ch == 2
         ind_nobole = find(doy_all < 161);
         dcdt_all(ind_nobole) = NaN;
         ev_all(ind_nobole) = NaN;
         ev_all_new(ind_nobole) = NaN;
         flux_all(ind_nobole) = NaN;
         r2_all(ind_nobole) = NaN;
         dcdt_min(ind_nobole) = NaN;
         ev_min(ind_nobole) = NaN;
         ev_min_new(ind_nobole) = NaN;
         flux_min(ind_nobole) = NaN;
         r2_min(ind_nobole) = NaN;
      end
   end
elseif SiteId == 'BS'
 T = read_bor(['\\ANNEX001\DATABASE\' year '\' SiteId '\Clean\SecondStage\air_temperature_1'],1); % BS 2000,2001,2002 
 P = read_bor(['\\ANNEX001\DATABASE\' year '\' SiteId '\Clean\SecondStage\barometric_pressure_main'],1); % BS 2000,2001,2002  
 T = T + 273.15;
 P = P .* 1000;
 A = 0.20;
elseif SiteId == 'JP'
 T = read_bor(['\\ANNEX001\DATABASE\' year '\' SiteId '\Clean\SecondStage\air_temperature_1'],1); % JP 2002 
 P = read_bor(['\\ANNEX001\DATABASE\' year '\' SiteId '\Clean\SecondStage\barometric_pressure_main'],1); % JP 2002  
 T = T + 273.15;
 P = P .* 1000;
 A = 0.20;
end

%[air_t_tmp] = fr_chamber_get_air_temperature(year,SiteId);

ind_nan_P = find(isnan(P));
P(ind_nan_P) = 94500;
ind_nan_T = find(isnan(T));
T(ind_nan_T) = 273.15;

R = 8.3144;

ind_dcdt_all = find(~isnan(dcdt_all));
ind_dcdt_min = find(~isnan(dcdt_min));

flux_all_new = flux_all ./ ev_all .* ev_all_new;
flux_min_new = flux_min ./ ev_min .* ev_min_new;

flux_all_new2 = (P .* ev_all_new .* dcdt_all) ./ (R .* T .* A);
flux_min_new2 = (P .* ev_min_new .* dcdt_min) ./ (R .* T .* A);

figure(2);
plot(doy_all,flux_all,'r.');
hold on;
plot(doy_all,flux_all_new,'k.');
hold off;
axis([doy_all(1) doy_all(end) 0 20]);
ylabel('Flux (\mumol m^{-2} s^{-1})');
legend('3 min slope','3 min slope (ev corr)');
zoom on;

figure(3);
plot(doy_min,flux_min,'r.');
hold on;
plot(doy_min,flux_min_new,'k.');
hold off;
axis([doy_all(1) doy_all(end) 0 20]);
ylabel('Flux (\mumol m^{-2} s^{-1})');
legend('1 min slope','1 min slope (ev corr)');
zoom on;

figure(4);
plot(doy_min,dcdt_min,'r.');
hold on;
plot(doy_all,dcdt_all,'k.');
hold off;
axis([doy_all(1) doy_all(end) 0 2]);
ylabel('dcdt (ppm s^{-1})');
legend('1 min slope','3 min slope');
zoom on;

figure(5);
plot(doy_min,flux_min_new,'r.');
hold on;
plot(doy_all,flux_all_new,'k.');
hold off;
axis([doy_all(1) doy_all(end) 0 20]);
ylabel('Flux (\mumol m^{-2} s^{-1})');
legend('1 min slope (ev corr)','3 min slope(ev corr)');
zoom on;

%applies ev correction (calculated on 1 min slope) on flux calculated for the 3 min slope
flux_all_new_corrected = (flux_all_new ./ ev_all_new) .* ev_min_new;

figure(6);
plot(doy_all,flux_all_new_corrected,'r.');
hold on;
plot(doy_all,flux_all_new,'k.');
axis([doy_all(1) doy_all(end) 0 20]);
hold off;
ylabel('Flux (\mumol m^{-2} s^{-1})');
legend('3 min slope (ev corr)','3 min slope (ev corr) corrected with ev 1 min');
zoom on;

ind_nonan = find(~isnan(flux_min_new) & ~isnan(flux_all_new_corrected));
[p, R2, sigma, s, Y_hat] = polyfit1(flux_min_new(ind_nonan),flux_all_new_corrected(ind_nonan),1);

figure(7);
plot(flux_min_new,flux_all_new_corrected,'k.',[0 max(flux_min_new)+1],[0 max(flux_min_new)+1],'k--',flux_min_new(ind_nonan),Y_hat,'r-');
text(1,max(flux_all_new_corrected)-1,[SiteId year]);
text(1,max(flux_all_new_corrected)-2,['chamber ' num2str(ch)]);
text(1,max(flux_all_new_corrected)-3,sprintf('y = %4.4fx + %4.2f',p));
axis([0 max(flux_min_new)+1 0 max(flux_min_new)+1]);
ylabel('Flux (1 to 4 minutes)');
xlabel('Flux (1 to 2 minutes)');
zoom on;

correction_factor = 1 + (1 - p(1));

flux_final = flux_all_new_corrected .* correction_factor;

figure(8);
plot(doy_min,flux_min_new,'r.',doy_all,flux_final,'k.');
axis([doy_min(1) doy_min(end) 0 20]);
ylabel('Flux (\mumol m^{-2} s^{-1})');
legend('1 min slope (ev corr)','Flux final (with correction factor)');
zoom on;

%finally, simonac, saves the data

if 1==0
hiha = save_bor(['D:\david_data\' year '\' SiteId '\chambers\clean\effective_volume_ch' num2str(ch)],1,ev_all_new);
hiho = save_bor(['D:\david_data\' year '\' SiteId '\chambers\clean\co2_flux_ch' num2str(ch)],1,flux_final);
end

