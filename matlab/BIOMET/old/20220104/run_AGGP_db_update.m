function run_AGGP_db_update(yearIn)

try
    fprintf('Started: %s\n',mfilename);
    
    dv=datevec(now);
    arg_default('yearIn',dv(1));
    sites = {'LGR1','LGR2'};

    db_update_AGGP_sites(yearIn,sites);
catch
    fprintf('*** Error in: %s ***\n',mfilename);
end
fprintf('Finished: %s\n',mfilename);
