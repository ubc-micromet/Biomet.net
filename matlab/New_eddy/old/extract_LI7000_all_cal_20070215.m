function  [cal_values_new,HF_data,cal_values] = extract_LI7000_all_cal(dateIn,SiteID)
% [cal_values_new,cal_values] = extract_LI7000_all_cal(dateIn,SiteID)
%
% Extract calibrations for dateIn time vector for all LI7000 at the site 
% (SiteID default is fr_current_siteid). If dateIn is not a calibration
% half-hour (specified per LI7000 in ini-file) nothing is done.
%
% Calibrations already present in the cal file are NOT overwritten
% (otherwise corrected calibration values will be lost)
% 
% See extract_LI7000_calibrations.m for details on output structures
%
% kai* - Nov 29, 2005

% Revisions:

arg_default('dateIn',now);
arg_default('SiteID',fr_current_siteid);

overwriteCal_flag = 0;

% Cycle through all given dates
disp(['Extracting calibrations...']);
cal_values_new = [];
for i=1:length(dateIn)
    configIn = fr_get_init(SiteID,dateIn(i));
    % Find all LI7000 and cycle through them
    types = {configIn.Instrument(:).Type};
    instrumentNum = find(strcmp(types,'7000'));
    
    for j = 1:length(instrumentNum)
        [cal_values_temp,cal_values] = extract_LI7000_calibrations(dateIn(i),configIn,instrumentNum(j));
        if ~isempty(cal_values_temp)
            cal_values_new = [cal_values_new cal_values_temp];
        end
    end
end


disp([num2str(length(cal_values_new)) ' calibrations extracted']);