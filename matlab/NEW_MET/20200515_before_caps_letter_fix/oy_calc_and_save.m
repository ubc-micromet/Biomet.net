function stats = oy_calc_and_save(siteID,year,month,day,LocalTimeFlag,LocalPth)

%stats = oy_calc_and_save('OY',2001,1,1:365,0,'D:\Elyn_data\TraceAnalysis\OY\stats\');

% E. Humphreys  Oct 2001

if ~exist('LocalPth')
    LocalPth = [];
end

if LocalTimeFlag == 1
    offsetGMT       = FR_get_offsetGMT(siteID);
else
   offsetGMT       = 0;
end

startDate   = datenum(year,month,day(1),0.5+offsetGMT, 0,0);
endDate     = datenum(year,month,day(end),23 +offsetGMT, 30,0);
%endDate     = datenum(year,month,day(end),24 +offsetGMT, 0,0);   Changed to above as per Elyn's instruction (bug fix) Zoran Jan 29, 2003


if endDate <= datenum(2001,12,12);
    [statsar, statsbr, statsRaw, statsDiag, tv] = oy_calc_main([startDate endDate],year);
else
    [statsar, statsbr, statsRaw, statsDiag, tv] = oy_calc_main_cp([startDate endDate],year);
end

stats.statsar   = statsar;
stats.statsbr   = statsbr;
stats.statsRaw  = statsRaw;
stats.statsDiag = statsDiag;
stats.TimeVector= tv;

% get the time and date for the first hhour in new_stats

FileName_p1      = FR_DateToFileName(startDate);
FileName_p2      = FR_DateToFileName(endDate);
FileName         = ([LocalPth FileName_p1(1:6) '_' FileName_p2(1:6)]);    % File name for the full set of stats


% save the new files
save(FileName,'stats');
