function [newTime] = ch_time(timeSer,Month,flagDOY)

%function to manipulate timevector
%
% flagDOY:  0 = DOY
%				1 = day of month
%				2 = minutes of month
%           3 = PDT DOY
%           4 = PST DOY
%           5 = CST DOY

if exist('flagDOY')~= 1
    flagDOY = 0;
end
if exist('Month') ~= 1
    Month = 1;
    flagDOY = 0;
end

switch flagDOY
    case 0, timeOffset = datenum(1998,1,1)-1;newTime = timeSer - timeOffset;Xlabel = 'DOY';
    case 1, timeOffset = datenum(1998,Month,1)-1;newTime = timeSer - timeOffset;Xlabel = ['Day of month #' num2str(Month)];
    case 2, timeOffset = datenum(1998,Month,1)-1;newTime = timeSer - timeOffset;newTime = newTime * 24 * 60;Xlabel = ['Minutes of month #' num2str(Month)];
    case 3, timeOffset = datenum(1998,1,1)-1;newTime = timeSer - timeOffset - 7/24;Xlabel = 'PDT DOY';
    case 4, timeOffset = datenum(1998,1,1)-1;newTime = timeSer - timeOffset - 8/24;Xlabel = 'PST DOY';
    case 5, timeOffset = datenum(1998,1,1)-1;newTime = timeSer - timeOffset - 6/24;Xlabel = 'CST DOY'; 
end
