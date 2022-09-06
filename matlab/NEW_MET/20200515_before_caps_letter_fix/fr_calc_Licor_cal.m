function [CO2_cal, H2O_cal, cal_voltage, calTime,LicorNum] = fr_calc_Licor_cal(calTime,cal_voltage,dateIn)
% FR_CALC_LICOR_CAL - Caculate licor calibrations from cal_voltage information 
%
%   [CO2_cal, H2O_cal, cal_voltage, calTime,LicorNum] = fr_calc_Licor_cal(calTime,cal_voltage)
%
% Core part of the old fr_get_licor_cal
%
% (c) kai*       File created:       Aug 16, 2003
%                Last modification:  Jan 14, 2004

% Revisions:
% Jan 14, 2004 - kai*
%   Introduce the use of cal_voltage(6,:) as a flag to exclude calculations from use.
%   Calibrations are now only used if cal_voltage(6,:)~=1

[n,m] = size(cal_voltage);

% Find those calibrations that should not be ignored
ind_notignore = find(cal_voltage(6,:) ~= 1);
calTime = calTime(ind_notignore);        
cal_voltage = cal_voltage(:,ind_notignore);

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
    ind = [ind ;ind(end)+1];                                            % the selected indexes
end

calTime = calTime(ind);                                                 % extract the requsted range
cal_voltage = cal_voltage(:,ind);                                       %
LicorNum = cal_voltage(3,:)';                                           %
[licors,i,j] = unique(LicorNum);                                        % find all different LI-6262s
cal_value = NaN*zeros(size(ind));                                       % create space for results
for k = licors'                                                        % cycle through all the licors
    ind1 = find(LicorNum ==k);                                         % calculate calibrations for each licor
    try
        cal_value(ind1) = fr_cal_licor(k, cal_voltage(4,ind1),cal_voltage(10,ind1),...
                             cal_voltage(12,ind1), cal_voltage(13,ind1), ...
                             cal_voltage(25,ind1), cal_voltage(26,ind1),...
                             min(cal_voltage([11 13],ind1)))';                     % and store them in the output array
    end
end

CO2_cal1 = [cal_value -cal_voltage([10],:)'];                           % add zero calibrations 
H2O_cal1 = [cal_value max(-cal_voltage([11 13],:))'];                   % add zero calibrations

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

