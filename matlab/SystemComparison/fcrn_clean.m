function [tv_exclude,h,varOut,textResults] = fcrn_clean(Stats_all,system_names,config_plot,tv_exclude_in,flag_load_tv_exclude,f_sys,flag_autoclean)
% tv_exclude = fcrn_clean(Stats_all,system_names,config_plot,tv_exclude)
%

close all

arg_default('system_names',{'XSITE_CP','XSITE_OP'});
arg_default('config_plot','report_var');
arg_default('flag_load_tv_exclude',1);
arg_default('f_sys',[20 20]);
arg_default('flag_autoclean',1);

%if ~exist('tv_exclude') | flag_load_tv_exclude 
if ~exist('flag_load_tv_exclude') | flag_load_tv_exclude 
    tv_exclude_load = fcrn_load_tv_exclude(Stats_all,system_names,config_plot);
else
    tv_exclude_load = [];
end

if exist('tv_exclude_in')
    tv_exclude = unique([tv_exclude_load; tv_exclude_in]);
else
    tv_exclude = tv_exclude_load;
end

%----------------------------------------------------
% General exclusion criteria
%----------------------------------------------------
% Find broken records
[N1,tv] = get_stats_field(Stats_all,[char(system_names(1)) '.MiscVariables.NumOfSamples']);
if flag_autoclean == 1
    tv_exclude = fcrn_auto_clean(Stats_all,system_names,tv_exclude);
end

%----------------------------------------------------
% Manual cleaning
%----------------------------------------------------
ButtonName = 'Yes';
while strcmp(ButtonName,'Yes')
    close all
    [h,varOut,textResults] = fcrn_plot_comp(Stats_all,system_names,config_plot,tv_exclude);

    h_bx = msgbox('Click to continue cleaning','Continue');
    waitfor(h_bx)

    ButtonName = questdlg('Repeat cleaning?','Cleaning','Yes','No','Yes');

    ind_manual = find_selected(h,Stats_all);
    tv_exclude = unique([tv(ind_manual); tv_exclude]);
end

ButtonName = questdlg('Save tv_exclude?','Save cleaning results','Yes','No','Yes');
if strcmp(ButtonName,'Yes')
    tv_exclude_pth  = Stats_all(1).Configuration.pth_tv_exclude;
    tv_exclude_name = ['tv_exclude_' char(system_names(1)) '_' char(system_names(2)) '_' config_plot];
    eval([tv_exclude_name ' = tv_exclude;']);
    disp([' ']);
    disp(['Saving ' tv_exclude_name ' to ' tv_exclude_pth]);
    save(fullfile(tv_exclude_pth,tv_exclude_name),tv_exclude_name);
end

return
