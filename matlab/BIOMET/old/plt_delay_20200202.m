function plt_delay(SiteId,tv_out)
% PLt_DELAYS Plots calculated and preset delays
%
%   PLD_DELAYS(SITEID,YEAR) Plots delays for Site and year
% 
%   PLD_DELAYS(SITEID,TV) Plots delays for times in timevector tv
%

% (c) kai*, Oct 22, 2003


% revisions:
% Sept 19, 2012
%   -added HJP94
% Oct 3, 2011
%   -added HDF11 to new eddy site list
% Nov 3, 2010
%   -commented out fc_main and le_main screening... was only partially
%   commented out before and was never used in QA/QC of delays; made graph
%   titles more useful (siteId and CO2/H2O)

if length(tv_out) == 1 % assume a year was given
   tv_out = datenum(tv_out,1,1,0,30,0):1/48:datenum(tv_out,12,31,23,59,59);
end

%-----------------------------------------------
% Make tv_out a column vector
%
[a,b] = size(tv_out);
if a<b 
   tv_out = tv_out';
end

dv = datevec(tv_out);
years = unique(dv(:,1));

pth = biomet_path('yyyy',SiteId,'flux');

switch upper(SiteId)
case {'BS' 'CR' 'JP' 'PA'};

   tv             = read_bor([pth 'misc_tv'],8,[],years,[],1);
   [tv_in,indOut] = intersect(fr_round_hhour(tv),fr_round_hhour(tv_out),'tv'); 
   tv_doy_calc = convert_tv(tv_in,'doy');

   %-----------------------------------------------
   % Read calculated dealy times from database
   delay_co2_calc = read_bor([pth 'misc.11'],[],[],years,indOut,1);
   delay_h2o_calc = read_bor([pth 'misc.12'],[],[],years,indOut,1);

   %-------------------------------------------------------
   % Read delay times used in calculation (one value a day)
   tv_days = unique(floor(tv_in));
   for i = 1:length(tv_days)
      c = fr_get_init(SiteId,tv_days(i));
      delay_co2_set(i) = c.Delays.All(6+c.GillR2chNum);
      delay_h2o_set(i) = c.Delays.All(7+c.GillR2chNum);
   end
   tv_doy_days = convert_tv(tv_days,'doy');

case {'HJP02' 'HJP75' 'HJP94' 'OY' 'YF' 'HDF11'};

   tv       = read_bor([pth 'TimeVector'],8,[],years,[],1);
   [tv_in,indOut] = intersect(fr_round_hhour(tv),fr_round_hhour(tv_out),'tv'); 
   tv_doy_calc = convert_tv(tv_in,'doy');

   %-----------------------------------------------
   % Read calculated dealy times from database
   delay_co2_calc = read_bor([pth 'MainEddy.Delays.Calculated_1'],[],[],years,indOut,1);
   delay_h2o_calc = read_bor([pth 'MainEddy.Delays.Calculated_2'],[],[],years,indOut,1);

   %-------------------------------------------------------
   % Read delay times used in calculation (one value a day)
   delay_co2_set = read_bor([pth 'MainEddy.Delays.Implemented_1'],[],[],years,indOut,1);
   delay_h2o_set = read_bor([pth 'MainEddy.Delays.Implemented_2'],[],[],years,indOut,1);
   tv_doy_days = convert_tv(tv_in,'doy');
   tv_days = tv_in;

otherwise
   disp([SiteId ' - unknown SiteId']);
end

%-------------------------------------------------------
% Read fluxes to exclude random variations of delay
%
% pth     = biomet_path('yyyy',SiteId,'Clean\Secondstage');
% fc_main = read_bor([pth 'fc_main'],[],[],years,indOut,1);
% le_main = read_bor([pth 'le_main'],[],[],years,indOut,1);


%-----------------------------------------------
% Running mean of dealy time
%
delay_co2_good = NaN .* zeros(size(delay_co2_calc));
% ind_good = find(abs(fc_main)>0.2);
ind_good = find(delay_co2_calc>4 & delay_co2_calc<30);
delay_co2_good(ind_good) = delay_co2_calc(ind_good);
delay_co2_mean = runmean(delay_co2_good,48,1);
delay_co2_median = fcrn_nanmedian(reshape_cut(delay_co2_good,48));
delay_co2_median = ones(48,1) * delay_co2_median;

delay_h2o_good = NaN .* zeros(size(delay_h2o_calc));
%ind_good = find((le_main)>10);
ind_good = find(delay_h2o_calc>4 & delay_h2o_calc<50);
delay_h2o_good(ind_good) = delay_h2o_calc(ind_good);
delay_h2o_mean = runmean(delay_h2o_good,48,1);
delay_h2o_median = reshape_cut(delay_h2o_good,48);
ind_median = 1:length(delay_h2o_median(:));
delay_h2o_median = fcrn_nanmedian(delay_h2o_median);
delay_h2o_median = ones(48,1) * delay_h2o_median;

%-----------------------------------------------
% CO_2 delay times
%
figure
plot(tv_doy_calc,delay_co2_calc,'.','MarkerSize',0.5);
hold on
plot(tv_doy_calc,delay_co2_good,'ro');
plot(tv_doy_calc,delay_co2_mean,'g-');
plot(tv_doy_calc(ind_median),delay_co2_median(:),'c-');
plot(tv_doy_days,delay_co2_set,'m','Linewidth',2);
axis([min(tv_doy_calc) max(tv_doy_calc) 10 30]);
title([SiteId ' CO_{2} delays ' datestr(tv_days(1),1) ' to ' datestr(tv_days(end),1)]);

%-----------------------------------------------
% H2O_2 delay times
%
figure
plot(tv_doy_calc,delay_h2o_calc,'.','MarkerSize',0.5);
hold on
plot(tv_doy_calc,delay_h2o_good,'ro');
plot(tv_doy_calc,delay_h2o_mean,'g-');
plot(tv_doy_calc(ind_median),delay_h2o_median(:),'c-');
plot(tv_doy_days,delay_h2o_set,'m-','Linewidth',2);
axis([min(tv_doy_calc) max(tv_doy_calc) 10 50]);
title([SiteId ' H_{2}O delays ' datestr(tv_days(1),1) ' to ' datestr(tv_days(end),1)]);

return