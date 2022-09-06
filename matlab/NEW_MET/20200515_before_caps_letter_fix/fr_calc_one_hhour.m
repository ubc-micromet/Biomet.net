function stats = fr_calc_one_hhour(SiteFlag,date_num,LocalTime)
%
%
%
% (c) Zoran Nesic              File created:       Feb 25, 1998
%                              Last modification:  Mar 11, 1999

%
% Revisions:
%
% Mar 11, 1999
%   - corrected startDate/endDate syntax. Added LocalTime flag handling.
%
if ~(exist('LocalTime')== 1)
    LocalTime = 1;
end

if LocalTime == 1
   offsetGMT       = FR_get_offsetGMT(SiteFlag);
else
   offsetGMT       = 0;
end

endOfHhour = 0.5;                                   % move to the end of hhour
startDate = date_num + (offsetGMT+endOfHhour)/24;   % correct for GMT offset and end of hhour
endDate = startDate;
stats = fr_calc_main(SiteFlag,startDate,endDate);

