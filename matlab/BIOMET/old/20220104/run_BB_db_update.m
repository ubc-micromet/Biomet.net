function run_BB_db_update(yearIn)

dv=datevec(now);
arg_default('yearIn',dv(1));
sites = {'BB'};

db_update_BB_site(yearIn,sites);

exit