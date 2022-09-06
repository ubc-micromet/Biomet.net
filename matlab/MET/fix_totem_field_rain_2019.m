function fix_totem_field_rain_2019
% One time shot function to correct missing rain event in UBC_Totem using
% UBC_CG data. Zoran 20191023
tv_c = read_bor('\\annex001\DATABASE\2019\UBC_CG\Climate\CG\cg_dt');
tv_t = read_bor('\\annex001\DATABASE\2019\UBC_TOTEM\Climate\Totem1\ubc_dt',[],8);
rain_c = read_bor('\\annex001\DATABASE\2019\UBC_CG\Climate\CG\cg.7');
rain_t = read_bor('\\annex001\DATABASE\2019\UBC_TOTEM\Climate\Totem1\ubc.26');
rain_t_corr = rain_t;
ind = find(tv_t>=254 & tv_t<=261.8);
rain_t_corr(ind) = rain_c(ind-16);
plot(tv_t,rain_t,tv_c,rain_c,tv_t,rain_t_corr,'o')
% This backs up the original trace. It should be done only once and then
% commented out otherwise the successive runs would delete the original
% data.
%save_bor('\\annex001\DATABASE\2019\UBC_TOTEM\Climate\Totem1\ubc.26_bak',1,rain_t);
save_bor('\\annex001\DATABASE\2019\UBC_TOTEM\Climate\Totem1\ubc.26',1,rain_t_corr);

