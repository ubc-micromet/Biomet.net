function run_FAIP_db_update(yearIn)

dv=datevec(now);
arg_default('yearIn',dv(1));
sites = {'FAIP_MC', 'FAIP_UBC_FARM'};

db_update_FAIP_sites(yearIn,sites);

exit