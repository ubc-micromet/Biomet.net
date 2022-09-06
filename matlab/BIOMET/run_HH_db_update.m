function run_HH_db_update(yearIn)

dv=datevec(now);
arg_default('yearIn',dv(1));
sites = {'HH'};

db_update_HH_site(yearIn,sites);

exit