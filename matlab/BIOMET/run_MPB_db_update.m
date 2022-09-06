function run_MPB_db_update(yearIn)

try
    fprintf('Started: %s\n',mfilename);
    sites = 1;
    dv=datevec(now);
    arg_default('yearIn',dv(1));

    % program runs from BIOMET.NET exclusively as of 2010/06/02 (Nick)
    % programs formerly used can be found in
    % C:\Ubc_flux\Matlab\MPB_Network\20100602

    %cd('C:\Ubc_flux\Matlab\MPB_Network');
    db_update_MPB_sites(yearIn,sites);
catch
    fprintf('*** Error in: %s ***\n',mfilename);
end
fprintf('Finished: %s\n',mfilename);    
