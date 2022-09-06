function [CO2_cal, H2O_cal] = fr_get_LI7000_cal(par1,dateIn,configIn,instrumentNum)
% fr_get_LI7000_cal - returns Licor 7000 calibrations from the calibration file
%
% The call to this function can have two syntaxes:
%   1. Working on the eddy Licor cal. file
%       function [CO2_cal, H2O_cal, cal_voltage, calTime] = 
%                               fr_get_LI7000_cal(SiteID,dateIn,Instrument_Num)
%   2. Working on any specific Licor cal file
%       function [CO2_cal, H2O_cal, cal_voltage, calTime] = 
%                               fr_get_Licor_cal(calFileName,dateIn)
%
% 
%
% (c) kai*       File created:       Aug 12, 2005
%                Last modification:  

%
% Revisions:

if exist(par1,'file')==2
    calFileName = par1;
else
    if exist('par1')~=1 | isempty(par1)
        SiteID = fr_current_siteID;
    else
        SiteID = par1;
    end
    
    extTmp = configIn.ext;
    extTmp(2) = 'c';            % replace "d" with "c" for calibration
    calFileName = fullfile(configIn.hhour_path,['calibrations' extTmp configIn.Instrument(instrumentNum).FileID '.mat']);

end

try
    load(calFileName);
catch
    disp(['Cannot open file: ' calFileName]);
    CO2_cal = [1 0];
    H2O_cal = [1 0];
    return
end        

calTime  = get_stats_field(cal_values,'TimeVector');
CO2_zero = get_stats_field(cal_values,'corrected.Cal0.CO2');
H2O_zero = get_stats_field(cal_values,'corrected.Cal0.H2O');
CO2_span = get_stats_field(cal_values,'corrected.Cal1.CO2');
H2O_span = get_stats_field(cal_values,'corrected.Cal1.H2O');
Tbench   = get_stats_field(cal_values,'corrected.Cal1.Tbench');
Plicor   = get_stats_field(cal_values,'corrected.Cal1.Plicor');
CAL_ppm  = get_stats_field(cal_values,'corrected.Cal1.Cal_ppm');

% CO2_cal1 = [ones(size(calTime))*CAL_ppm./(CO2_span-CO2_zero-polyval(Tp,Tbench(ind))) ...
%         CO2_zero];
CO2_cal1 = [CAL_ppm./(CO2_span-CO2_zero) CO2_zero];
H2O_cal1 = [CO2_cal1(:,1) min(H2O_zero,H2O_span)];

if length(CO2_cal1(:,1))>1
    CO2_cal = interp1(calTime,CO2_cal1, dateIn);
    H2O_cal = interp1(calTime,H2O_cal1, dateIn);
end

outsideInd = find(dateIn <= calTime(1));                                 % find dateIn values outside of calTime range
CO2_cal(outsideInd,1) = CO2_cal1(1,1);                                  % and use first or last cal. time instead.
CO2_cal(outsideInd,2) = CO2_cal1(1,2);                                  % 
H2O_cal(outsideInd,1) = H2O_cal1(1,1);                                  % 
H2O_cal(outsideInd,2) = H2O_cal1(1,2);                                  % 
outsideInd = find(dateIn > calTime(end));                               % this will remove NaNs put there by interp1
CO2_cal(outsideInd,1) = CO2_cal1(end,1);                                % for all the points outside of existing range
CO2_cal(outsideInd,2) = CO2_cal1(end,2);                                % 
H2O_cal(outsideInd,1) = H2O_cal1(end,1);                                % 
H2O_cal(outsideInd,2) = H2O_cal1(end,2);                                % 
