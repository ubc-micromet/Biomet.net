function  [cal_values_new,HF_data,cal_values] = extract_LI6262_all_cal(dateIn,SiteID,overwriteCal_flag)
% [cal_values_new,cal_values] = extract_LI6262_all_cal(dateIn,SiteID)
%
% Extract calibrations for dateIn time vector for all LI6262 at the site 
% (SiteID default is fr_current_siteid). If dateIn is not a calibration
% half-hour (specified per LI7000 in ini-file) nothing is done.
%
% Calibrations already present in the cal file are NOT overwritten
% (otherwise corrected calibration values will be lost)
% 
% See extract_LI6262_calibrations.m for details on output structures
%
% Nick, Zoran - June 26, 2008

% Revisions:

arg_default('dateIn',now);
arg_default('SiteID',fr_current_siteid);
arg_default('overwriteCal_flag',0);

% Cycle through all given dates
disp(['Extracting calibrations...']);
cal_values_new = [];
for i=1:length(dateIn)
    configIn = fr_get_init(SiteID,dateIn(i));
    % Find all LI6262 and cycle through them
    types = {configIn.Instrument(:).Type};
    instrumentNum = find(strcmp(types,'6262'));
    dv = datevec(dateIn(i));
    dv_cal = datevec(configIn.Instrument(instrumentNum).Cal.time);
    dateIn(i) = datenum(dv(1),dv(2),dv(3),dv_cal(4),dv_cal(5),dv_cal(6));
    for j = 1:length(instrumentNum)
        [cal_values_temp,cal_values] = extract_LI6262_calibrations(dateIn(i),configIn,instrumentNum(j),overwriteCal_flag);
        if ~isempty(cal_values_temp)
            cal_values_new = [cal_values_new cal_values_temp];
        end
    end
end


disp([num2str(length(cal_values_new)) ' calibrations extracted']);