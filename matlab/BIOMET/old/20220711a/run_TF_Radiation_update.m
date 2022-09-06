function run_TF_Radiation_update(yearIn)

dv=datevec(now);
arg_default('yearIn',dv(1));

db_update_TF_Radiation_met(yearIn);

