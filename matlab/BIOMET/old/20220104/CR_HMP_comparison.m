function CR_HMP_comparison

Year = 2003:2006;
SiteId = 'cr';

rh_names_clean = {'relative_humidity_hmp_4m','relative_humidity_hmp_27m','relative_humidity_hmp_40m'};
ta_names_clean = {'air_temperature_hmp_4m','air_temperature_hmp_27m','air_temperature_hmp_40m'};
% Compare with uncleaned traces
rh_names_raw = {'fr_clim\fr_clim_105.80','fr_clim\fr_clim_105.76','fr_clim\fr_clim_105.78'};
ta_names_raw = {'fr_clim\fr_clim_105.79','fr_clim\fr_clim_105.75','fr_clim\fr_clim_105.77'};

% s for mixing ratio!
[s_lic,tv] = read_db(Year,SiteId,'flux\clean','h2o_avg_licor');
ind = find(tv>=now-7 & tv<now);

% Function for 3-HMP regression plot is defined below
[h,s_hmp_clean,rh_hmp_clean,s_lic,rh_lic] = pl_HMP_comparison(ind,Year,SiteId,'climate\clean',rh_names_clean,ta_names_clean);
[h,s_hmp_raw,rh_hmp_raw,s_lic,rh_lic]     = pl_HMP_comparison(ind,Year,SiteId,'climate',rh_names_raw,ta_names_raw);

figure('Name','Time series mixing ratio');
plot(tv(ind),s_hmp_clean(ind,:));
hold on
plot(tv(ind),s_hmp_raw(ind,:),'.');
legend([rh_names_clean,rh_names_raw])

figure('Name','Time series relative humidity');
plot(tv(ind),rh_hmp_clean(ind,:));
hold on
plot(tv(ind),rh_hmp_raw(ind,:),'.');
hold on
plot(tv(ind),rh_lic(ind,:),'c');
legend([rh_names_clean,rh_names_raw])

figure('Name','Time series rel. humidity (4m corrected)');
plot(tv(ind),[rh_hmp_raw(ind,1)*97/113 rh_hmp_clean(ind,2:3)]);
hold on
plot(tv(ind),rh_hmp_raw(ind,:),'.');
hold on
plot(tv(ind),rh_lic(ind,:),'c');
legend([rh_names_clean,rh_names_raw])

figure('Name','Time series mixing ratio (4m corrected)');
plot(tv(ind),[s_hmp_raw(ind,1)*97/113 s_hmp_clean(ind,2:3)]);
hold on
plot(tv(ind),s_hmp_raw(ind,:),'.');
hold on
plot(tv(ind),s_lic(ind,:),'c');
legend([rh_names_clean,rh_names_raw])

figure('Name','Regression mixing ration Licor vs. 4m corrected)');
plot_regression(s_lic(ind),s_hmp_raw(ind,1)*97/113);
xlabel('s_{Licor} (mmol/mol)');
ylabel('s_{HMP 4m} (mmol/mol)');

step = 7*48;
for i = 1:length(tv)/step
    ind = (i-1)*step+1:i*step;
    tv_int(i) = mean(tv(ind));
    a(i,:) = linregression(s_lic(ind,:),s_hmp_raw(ind,3));
end

figure('Name','Weekly regression s_HMP vs s_licor');
plot(tv_int,a(:,1)),datetick('x')
ylabel('Slope');
grid on

function [h,s_hmp,rh_hmp,s_lic,rh_lic,tv] = pl_HMP_comparison(ind,Year,SiteId,pth_cl,rh_names,ta_names)
% [h,s_hmp,s_lic] = pl_HMP_comparison(ind,Year,SiteId,rh_names,ta_names);

p  = read_db(Year,SiteId,'clean\secondstage','barometric_pressure_main');
ta = read_db(Year,SiteId,'clean\secondstage','air_temperature_main');

% s for mixing ratio!
s_lic = read_db(Year,SiteId,'flux\clean','h2o_avg_licor');

e_lic  = s_lic./1000 ./ (1+s_lic./1000) .* p;
es_lic = sat_vp(ta);
rh_lic = e_lic./es_lic * 100;

% Read data from cleaned climate, i.e. rh has been capped at 100%
for i = 1:length(rh_names)
    [rh_hmp(:,i),tv] = read_db(Year,SiteId,pth_cl,char(rh_names(i)));
    ta_hmp(:,i) = read_db(Year,SiteId,pth_cl,char(ta_names(i)));
end
p = p * ones(1,length(rh_names));

% Calculate mixing ratio from rh
es_hmp = sat_vp(ta_hmp);
e_hmp  = rh_hmp./100.*es_hmp;
s_hmp  = 1000.*e_hmp./(p-e_hmp);

kais_plotting_setup;
h = figure('Name','HMP vs. Licor regressions');
for i = 1:length(rh_names)
    subplot(2,2,i)
    plot_regression(s_lic(ind),s_hmp(ind,i),[],[],'ortho');
    xlabel('s_{Licor} (mmol/mol)');
    ylabel(['s_{HMP} ' char(rh_names(i)) ' (mmol/mol)']);
    grid on
end
