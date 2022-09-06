% run_all_chamber_functions

% run chamber data file rename, cal extraction and flux calculation from
% one MATLAB function

% move and rename files
try
    run_chamber_rename(now-[7:-1:1]);
catch
    disp(lasterr);
end

% extract calibrations
try
    ach_get_licor_cal(datenum(floor(now-1)));
catch
    disp(lasterr);
end

% run flux calculations
try
    ach_calc_and_save(datenum(floor(now-1)),'BS');
catch
    disp(lasterr);
end