function [CO2_cal, H2O_cal, manual_calibrations, calTime,LicorNum] = fr_get_manual_Licor_cal(par1,dateIn,pth)
% fr_get_manual_Licor_cal - returns Licor 6262 or li7500 calibrations from a calibration file including manual calibrations
%
% The call to this function can have two syntaxes:
%   1. Working on the eddy Licor cal. file
%       function [CO2_cal, H2O_cal, cal_voltage, calTime] = 
%                               fr_get_Licor_cal(SiteID,dateIn,pth)
%   2. Working on any specific Licor cal file
%       function [CO2_cal, H2O_cal, cal_voltage, calTime] = 
%                               fr_get_Licor_cal(calFileName,dateIn)
%
% 
%
% (c) E. Humphreys Aug 21, 2003 based on fr_get_Licor_cal by Zoran Nesic Jul 14, 2003
% Revisions:
%
%

if exist(par1,'file')==2
    calFileName = par1;
    try; load(calFileName);
    catch
        disp(['Cannot open file: ' calFileName])
    end        
else
    if exist('par1')~=1 | isempty(par1)
        SiteID = fr_current_siteID;
    else
        SiteID = par1;
    end

    if exist('pth')~=1 | isempty(pth)
        [junk, pth] = fr_get_local_path;                            % site computer and use the local path
    end

    switch upper(SiteID)
        case 'YF', ext = ['cmy' ];
        case 'OY', ext = ['cmo' ];
        case 'HJP02', ext = ['cmhjp02' ];
        case 'FEN', ext = ['cmFEN' ];
        case 'XSITE', ext = ['cmXSITE' ];
        otherwise, ext = ['cm' SiteID];
    end

    fileName = [pth 'manual_calibrations.' ext];

    try, load(fileName);
    catch,disp(['Cannot open file: ' fileName])
    end
end


calTime = datenum(manual_calibrations(:,3), manual_calibrations(:,4), manual_calibrations(:,5), ...
   manual_calibrations(:,6), manual_calibrations(:,7), manual_calibrations(:,8));       % convert calibration times to a time vector

if exist('dateIn')~=1 | isempty(dateIn)                                 % dateIn not given use dateIn = calTime
    dateIn = calTime;                                                   % in that case all the cal values are returned
end
ind = find(calTime >= dateIn(1) & calTime <= dateIn(end));              % find all calibrations for the given dates

if isempty(ind)
    if length(dateIn) == 1
        [junk, ind]= min(abs(dateIn-calTime));
    else
        ind = zeros(2,1);
        [junk, ind(1)]= min(abs(dateIn(1)-calTime));
        [junk, ind(2)]= min(abs(dateIn(end)-calTime));
        ind = unique(ind);
    end
end

if ind(1) > 1                                                           % for proper interpolation grab
    ind = [ind(1)-1; ind];                                              % one point before
end
if ind(end) < length(calTime)                                           % and one point after
   ind = [ind ;ind(end)+1];                                             % the selected indexes
end

calTime = calTime(ind);                                                 % extract the requsted range
manual_calibrations = manual_calibrations(ind,:);                       %
LicorNum = manual_calibrations(:,1);

CO2_cal1 = [manual_calibrations(:,10) -manual_calibrations(:,9)];                           % add zero calibrations 
H2O_cal1 = [manual_calibrations(:,12) -manual_calibrations(:,11)];                          % add zero calibrations

% CO2_cal1 and H2O_cal1 have properly calculated values at the *calibration times*
% If one wants the calibration values at any arbitrary point in time 
% these calibrations need to be interpolated (using a table look-up)

CO2_cal = interp1(calTime,CO2_cal1, dateIn);
H2O_cal = interp1(calTime,H2O_cal1, dateIn);

outsideInd = find(dateIn < calTime(1));                                 % find dateIn values outside of calTime range
CO2_cal(outsideInd,1) = CO2_cal1(1,1);                                  % and use first or last cal. time instead.
CO2_cal(outsideInd,2) = CO2_cal1(1,2);                                  % 
H2O_cal(outsideInd,1) = H2O_cal1(1,1);                                  % 
H2O_cal(outsideInd,2) = H2O_cal1(1,2);                                  % 
outsideInd = find(dateIn > calTime(end));                               % this will remove NaNs put there by interp1
CO2_cal(outsideInd,1) = CO2_cal1(end,1);                                % for all the points outside of existing range
CO2_cal(outsideInd,2) = CO2_cal1(end,2);                                % 
H2O_cal(outsideInd,1) = H2O_cal1(end,1);                                % 
H2O_cal(outsideInd,2) = H2O_cal1(end,2);                                % 

