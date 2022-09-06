function run_OAT2_db_update(yearIn);

dv=datevec(now);
arg_default('yearIn',dv(1));

db_update_OAT2(yearIn,{'PA'});

exit