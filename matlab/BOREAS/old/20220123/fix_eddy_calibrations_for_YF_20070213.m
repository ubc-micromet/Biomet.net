function fix_YF_cals_20070213

fileName = 'D:\Nick_Share\recalcs\YF\hhour\calibrations.cY5.mat';
load(fileName);

%read cal data

tv = get_stats_field(cal_values,'TimeVector');
co2_zero_m = get_stats_field(cal_values,'measured.Cal0.CO2');
co2_span_m = get_stats_field(cal_values,'measured.Cal1.CO2');
h2o_zero_m = get_stats_field(cal_values,'measured.Cal0.H2O');
h2o_span_m = get_stats_field(cal_values,'measured.Cal1.H2O');

co2_zero = get_stats_field(cal_values,'corrected.Cal0.CO2');
co2_span = get_stats_field(cal_values,'corrected.Cal1.CO2');
h2o_zero = get_stats_field(cal_values,'corrected.Cal0.H2O');
h2o_span = get_stats_field(cal_values,'corrected.Cal1.H2O');


%Find bad values

ind_bad = find( (tv > datenum(2007,1,18) & tv <= datenum(2007,1,23) ...
    & co2_zero_m > 200 ) | (tv > datenum(2007,1,33) & tv <= datenum(2007,1,39) ...
    & co2_zero_m > 200 ) );

doy=tv-datenum(2007,1,0)-8/24;

figure(1);
subplot(4,1,1)
plot(doy,co2_zero,'b.-',doy(ind_bad),co2_zero_m(ind_bad),'go')
ylabel('CO2 zero')
title('Before cal fix');
subplot(4,1,2)
plot(doy,h2o_zero,'b.-',doy(ind_bad),h2o_zero_m(ind_bad),'go')
ylabel('H2O zero')
subplot(4,1,3)
plot(doy,co2_span,'b.-',doy(ind_bad),co2_span_m(ind_bad),'go')
ylabel('CO2 span')
subplot(4,1,4)
plot(doy,h2o_span,'b.-',doy(ind_bad),h2o_span_m(ind_bad),'go')
ylabel('H2O span')

zoom on; pause;

co2_zero(ind_bad) = NaN;
co2_span(ind_bad) = NaN;
h2o_zero(ind_bad) = NaN;
h2o_span(ind_bad) = NaN;

% General filling of individual cal that were bad

ind_nan = find( isnan(co2_zero) & tv > datenum(2007,1,0) & tv <= datenum(2007,1,45)); ind_notnan = find(~isnan(co2_zero) ...
    & tv > datenum(2007,1,0) & tv <= datenum(2007,1,45));
co2_zero(ind_nan) = interp1(tv(ind_notnan),co2_zero(ind_notnan),tv(ind_nan));

ind_nan = find(isnan(co2_span) & tv > datenum(2007,1,0) & tv <= datenum(2007,1,45)); ind_notnan = find(~isnan(co2_span) ...
    & tv > datenum(2007,1,0) & tv <= datenum(2007,1,45));
co2_span(ind_nan) = interp1(tv(ind_notnan),co2_span(ind_notnan),tv(ind_nan));

ind_nan = find(isnan(h2o_zero) & tv > datenum(2007,1,0) & tv <= datenum(2007,1,45) ); ind_notnan = find(~isnan(h2o_zero) ... 
    & tv > datenum(2007,1,0) & tv <= datenum(2007,1,45));
h2o_zero(ind_nan) = interp1(tv(ind_notnan),h2o_zero(ind_notnan),tv(ind_nan));

ind_nan = find(isnan(h2o_span) & tv > datenum(2007,1,0) & tv <= datenum(2007,1,45) ); ind_notnan = find(~isnan(h2o_span) ... 
    & tv > datenum(2007,1,0) & tv <= datenum(2007,1,45));
h2o_span(ind_nan) = interp1(tv(ind_notnan),h2o_span(ind_notnan),tv(ind_nan));

figure(2);
subplot(4,1,1)
plot(doy,co2_zero,'b.-',doy(ind_bad),co2_zero_m(ind_bad),'go')
ylabel('CO2 zero')
title('After cal fix');
subplot(4,1,2)
plot(doy,h2o_zero,'b.-',doy(ind_bad),h2o_zero_m(ind_bad),'go')
ylabel('H2O zero')
subplot(4,1,3)
plot(doy,co2_span,'b.-',doy(ind_bad),co2_span_m(ind_bad),'go')
ylabel('CO2 span')
subplot(4,1,4)
plot(doy,h2o_span,'b.-',doy(ind_bad),h2o_span_m(ind_bad),'go')
ylabel('H2O span')


% Write corrected calibrations into structure and save

for k = 1:length(tv)
    cal_values(k).corrected.Cal0.CO2 = co2_zero(k);
    cal_values(k).corrected.Cal0.H2O = h2o_zero(k);
    cal_values(k).corrected.Cal1.CO2 = co2_span(k);
    cal_values(k).corrected.Cal1.H2O = h2o_span(k);
end

save(fileName,'cal_values');