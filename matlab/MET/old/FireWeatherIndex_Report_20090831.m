function FireWeatherIndex_Report(dateIn, siteInfo)
% FireWeatherIndex report for any site
%
% dateIn - 30 days of 30-minute data
% siteInfo - structure with the site info:
%           siteID, GMT_Shift, climTraces, reportPath
%
%
% Note: used MH_FireWeatherIndex_report as inspiration.
%
% (c) Zoran Nesic           File created:           Jun 23, 2008
%                           Last modification:      Jun 23, 2008
%

% Revisions:
%
%


arg_default('dateIn',fr_round_hhour(now)-30:1/48:fr_round_hhour(now))
GMT_shift = siteInfo.GMT_Shift;              % shift grenich mean time to 24hr day

[years,mm, dd, hh] = datevec(dateIn);
% Find first and last 1 pm PST
tv_1300_PST_start    = fr_round_hhour(datenum(years(1),mm(1),dd(1),13+GMT_shift,0,0),1);
tv_1300_PST_end      = fr_round_hhour(datenum(years(end),mm(end),dd(end),13+GMT_shift,0,0),1);
if tv_1300_PST_end > dateIn(end);
     tv_1300_PST_end = tv_1300_PST_end - 1;     % go one day back if there is no 1 pm time stamp in the last day
end

% get time and all the traces: [Month  Day   Temperature(C) RH (%)  Wind (m/s)  Rainfall (mm)]
tv          = fr_round_hhour(read_bor(siteInfo.climTraces.tv,8,[],years),1);
Tair        = read_bor(siteInfo.climTraces.Tair,[],[],years);
RH          = read_bor(siteInfo.climTraces.RH,[],[],years) * siteInfo.climTraces.RH_gain;
WindSpeed   = read_bor(siteInfo.climTraces.WindSpeed,[],[],years);
WindDir     = read_bor(siteInfo.climTraces.WindDir,[],[],years);
RainFall    = read_bor(siteInfo.climTraces.RainFall,[],[],years);

% find 1 pm PST indexes
ind_start = find(tv_1300_PST_start == tv);
ind_end   = find(tv_1300_PST_end   == tv);
ind = [0:tv_1300_PST_end-tv_1300_PST_start]*48 + ind_start;

tv = tv(ind);
Tair = Tair(ind);
RH = RH(ind);
WindSpeed = WindSpeed(ind);
WindDir = WindDir(ind);

Rain24h_tot = fastavg(RainFall(ind_start-48:ind_end),48)*48;        % find rain daily totals
%RainFall = RainFall(ind);
[YearX, MonthX, DayX] = datevec(tv-GMT_shift/24);

[fwi,dataOutAll] = FireWeatherIndex([MonthX DayX Tair RH WindSpeed Rain24h_tot]);

Rating = ones(size(dataOutAll,1),3);
indRating = find (fwi < 3);
RatingTemp = 'L  ';
Rating(indRating,:) = RatingTemp(ones(size(indRating,1),1),:);
indRating = find (fwi >= 3 & fwi < 10);
RatingTemp = 'M  ';
Rating(indRating,:) = RatingTemp(ones(size(indRating,1),1),:);
indRating = find (fwi >= 10 & fwi < 23);
RatingTemp = 'H* ';
Rating(indRating,:) = RatingTemp(ones(size(indRating,1),1),:);
indRating = find (fwi >= 23);
RatingTemp = 'E**';
Rating(indRating,:) = RatingTemp(ones(size(indRating,1),1),:);


dataOut = [YearX, MonthX, DayX, ones(size(YearX))*13, Tair, RH, WindSpeed, WindDir, Rain24h_tot,fwi,dataOutAll(:,4)];

%fid = fopen('D:\Sites\web_page_weather\MH_clim.dat','wt');
%fid = fopen('D:\temp.dat','wt');
%fid = fopen('\\paoa001\web_page_wea\MH_clim.dat','wt');
fid = fopen(siteInfo.reportPath,'wt'); % May 15, 2007
fprintf(fid,'Year  Month  Day  Hour  Tair(C) RH(%%) Wind(m/s) W_Dir(deg)  Rain(mm) FWI    bui   Rating\n');
for i = 1:size(dataOut,1)
    fprintf(fid,'%d     %2d   %2d   %2d  %6.2f  %6.2f  %6.2f    %6.2f    %6.2f  %6.2f  %6.2f   %s\n',dataOut(i,:),char(Rating(i,:)));
end
fclose(fid);
