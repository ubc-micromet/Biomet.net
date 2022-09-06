function run_YF_met_db_update(yearIn)

try
    fprintf('Started: %s\n',mfilename);
    
    dv=datevec(now);
    arg_default('yearIn',dv(1));
    sites = {'YF'};
    db_update_YF_met(yearIn,sites);
catch
    fprintf('*** Error in: %s ***\n',mfilename);
end
fprintf('Finished: %s\n',mfilename);