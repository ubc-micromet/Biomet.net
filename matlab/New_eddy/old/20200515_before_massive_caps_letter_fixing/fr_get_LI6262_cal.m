function [CO2_cal, H2O_cal] = fr_get_LI6262_cal(par1,dateIn,configIn,instrumentNum)
% fr_get_LI6262_cal - returns Licor 6262 calibrations from a new eddy style calibration file
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
% (c) Nick       File created:       June 26, 2008
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
    calFileName = fullfile(configIn.hhour_path,['calibrations' extTmp num2str(instrumentNum) '.mat']);

end

try
    load(calFileName);
catch
    disp(['Cannot open file: ' calFileName]);
    CO2_cal = [1 0];
    H2O_cal = [1 0];
    return
end        

% Find those calibrations that should not be ignored
cal_ignore = get_stats_field(cal_values,'Ignore');
ind_notignore = find(cal_ignore ~= 1);        
cal_values = cal_values(ind_notignore);


calTime  = get_stats_field(cal_values,'TimeVector');
CO2_zero = get_stats_field(cal_values,'corrected.Cal0.CO2');
H2O_zero = get_stats_field(cal_values,'corrected.Cal0.H2O');
CO2_span = get_stats_field(cal_values,'corrected.Cal1.CO2');
H2O_span = get_stats_field(cal_values,'corrected.Cal1.H2O');
Tbench   = get_stats_field(cal_values,'corrected.Cal1.Tbench');
Plicor   = get_stats_field(cal_values,'corrected.Cal1.Plicor');
CAL_ppm  = get_stats_field(cal_values,'corrected.Cal1.Cal_ppm');

% added ignore flag (H\Nick, June 26, 2008)
cal_ignore = get_stats_field(cal_values,'Ignore');
ind_notignore = find(cal_ignore ~= 1);

% CO2_cal1 = [ones(size(calTime))*CAL_ppm./(CO2_span-CO2_zero-polyval(Tp,Tbench(ind))) ...
%         CO2_zero];

% recall from init_all file configIn.Instrument(nIRGA).Cal.ppm = [0 c.cal1 c.cal2];
c_cal_ppm = configIn.Instrument(instrumentNum).Cal.ppm(2);
licor_num = configIn.Instrument(instrumentNum).SerNum;

%%%%%% LINES ADDED TO HANDLE LI-6262 PROCESSED THRU NEW EDDY CODE (e.g. OY)
% fr_cal_licor(num,c_cal_ppm,c_zero_off_mV, c_mV, h_mV, To_mV, Plicor_mV,h_zero_off_mV,h_cal_mmol)
[CO2_cal,H2O_cal] = fr_cal_licor(licor_num,c_cal_ppm,CO2_zero,CO2_span,H2O_span,Tbench,Plicor,H2O_zero,min(H2O_zero,H2O_span));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% CO2_cal1 = [CAL_ppm./(CO2_span-CO2_zero) CO2_zero];
% H2O_cal1 = [CO2_cal1(:,1) min(H2O_zero,H2O_span)];

CO2_cal1 = [CO2_cal -CO2_zero];
H2O_cal1 = [CO2_cal max(-H2O_zero,-H2O_span)];

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
