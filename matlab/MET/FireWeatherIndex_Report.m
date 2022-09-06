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
%                           Last modification:      Apr 14, 2010
%

% Revisions:
%
% Apr 14, 2010 (Z)
%   - changed the 5 letter based ratings to number based ratings
%     VL - 1, L - 2, M - 3, H - 4, E - 5
% Aug 31, 2009 (Z)
%   - Proper Danger class calculations are added.  The old style,
%     FWI-only based calculations are removed.


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

%=============================================
% Danger Class calculations
%

% Create the danger class table:
% DangerClassTable = f(BUI, FWI), where
% BUI = {0-19,20-42,43-69,70-118,>119)
% FWI = {0, 1-7, 8-16, 17-30,>31}
DangerClassTable = [1 2 2 3 3;
                    2 2 3 3 4;
                    2 3 3 4 4;
                    2 3 4 4 5;
                    3 3 4 5 5];

bui = dataOutAll(:,4);                  % Extract bui
nBUI = zeros(size(bui));                % set indexes to 0
nFWI = zeros(size(bui));                % set indexes to 0

intFWI = round(fwi);                    % use integer values for FWI
intBUI = round(bui);                    % use integer values for BUI

% Find fwi rating for each day
nFWI(intFWI ==  0) = 1;
nFWI(intFWI >=  1 & intFWI <=  7) = 2;
nFWI(intFWI >=  8 & intFWI <= 16) = 3;
nFWI(intFWI >= 17 & intFWI <= 30) = 4;
nFWI(intFWI >= 31) = 5;

% Find bui rating for each day    
nBUI(intBUI >= 0  & intBUI <= 19) = 1;
nBUI(intBUI >= 20 & intBUI <= 42) = 2;
nBUI(intBUI >= 43 & intBUI <= 69) = 3;
nBUI(intBUI >= 70 & intBUI <= 118) = 4;
nBUI(intBUI >= 119) = 5;

% using fwi and bui ratings extract the DangerClass ratings
%for i = 1:length(nBUI)
%    DangerClass(i) = DangerClassTable(nBUI(i),nFWI(i));
%end
% the next line replaces the loop above.


% nBUI'
% nFWI'
% save d:\fwi_test
% 
% DangerClass = DangerClassTable(sub2ind(size(DangerClassTable),[1:5 5 5 5],[2 1 1 1 3 1 1 1]))

DangerClass = DangerClassTable(sub2ind(size(DangerClassTable),nBUI,nFWI));

Rating = ones(size(DangerClass,1),3);
indRating = find (DangerClass == 1);RatingTemp = '1  ';
    Rating(indRating,:) = RatingTemp(ones(size(indRating,1),1),:);
indRating = find (DangerClass == 2);RatingTemp = '2  ';
    Rating(indRating,:) = RatingTemp(ones(size(indRating,1),1),:);
indRating = find (DangerClass == 3);RatingTemp = '3  ';
    Rating(indRating,:) = RatingTemp(ones(size(indRating,1),1),:);
indRating = find (DangerClass == 4);RatingTemp = '4* ';
    Rating(indRating,:) = RatingTemp(ones(size(indRating,1),1),:);
indRating = find (DangerClass == 5);RatingTemp = '5**';
    Rating(indRating,:) = RatingTemp(ones(size(indRating,1),1),:);


%dataOut = [YearX, MonthX, DayX, ones(size(YearX))*13, Tair, RH, WindSpeed, WindDir, Rain24h_tot,fwi,dataOutAll(:,4)];
dataOut = [YearX, MonthX, DayX, ones(size(YearX))*13, Tair, RH, WindSpeed, WindDir, Rain24h_tot,dataOutAll];

%fid = fopen('D:\Sites\web_page_weather\MH_clim.dat','wt');
%fid = fopen('D:\temp.dat','wt');
%fid = fopen('\\paoa001\web_page_wea\MH_clim.dat','wt');
% [ffmc dmc dc bui isi fwi dsr]
fid = fopen(siteInfo.reportPath,'wt'); % May 15, 2007
fprintf(fid,'Year  Month  Day  Hour  Tair(C) RH(%%) Wind(m/s) W_Dir(deg)  Rain(mm)   ffmc     dmc      dc     bui     isi     fwi     dsr     Rating\n');
for i = 1:size(dataOut,1)
    fprintf(fid,'%d     %2d   %2d   %2d  %6.2f  %6.2f  %6.2f    %6.2f    %6.2f  %8.2f%8.2f%8.2f%8.2f%8.2f%8.2f%8.2f       %s\n',dataOut(i,:),char(Rating(i,:)));
end
fclose(fid);
