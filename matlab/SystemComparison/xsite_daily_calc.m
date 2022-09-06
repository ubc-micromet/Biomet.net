function xsite_daily_calc(tv_exp)

arg_default('tv_exp',[now-1 now])

cd(fullfile(xsite_base_path,'NB_NL','Setup'));

new_calc_and_save(tv_exp);

if strcmp(fr_get_pc_name,'XSITE01')
    cd('c:\ubc_pc_setup\site_specific');
else
    cd(fullfile(xsite_base_path,'NB_NL','ubc_pc_setup\site_specific'));
end

new_calc_and_save(tv_exp);

cd(fullfile(xsite_base_path,'NB_NL','Setup'));
