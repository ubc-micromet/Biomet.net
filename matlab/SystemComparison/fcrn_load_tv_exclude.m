function tv_exclude = fcrn_load_tv_exclude(Stats_all,system_names,config_plot)

i1 = 1;
while isempty(Stats_all(i1).Configuration)
    i1 = i1+1;
end

tv_exclude_pth  = Stats_all(i1).Configuration.pth_tv_exclude;
tv_exclude_name = ['tv_exclude_' char(system_names(1)) '_' char(system_names(2)) '_' config_plot];
tv_exclude_name = strrep(tv_exclude_name,'(','_');
tv_exclude_name = strrep(tv_exclude_name,')','');

if 2 == exist(fullfile(tv_exclude_pth,[tv_exclude_name '.mat']))
    load(fullfile(tv_exclude_pth,tv_exclude_name));
    eval(['tv_exclude = ' tv_exclude_name ';']);
    disp(' ')
    disp(['Loading ' tv_exclude_name ' from ' tv_exclude_pth]);
else
    tv_exclude = [];
    disp('No tv_exclude file found');
end
