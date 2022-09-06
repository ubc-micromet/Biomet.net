function run_MPB_db_update(yearIn);

dv=datevec(now);
arg_default('yearIn',dv(1));
sites = { '11'};

db_update_HP_sites(yearIn,sites);

exit