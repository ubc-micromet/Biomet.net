function recalc_cleaning_backup(SiteId,BASEDIR)
% recalc_cleaning_backup(SiteId,BASEDIR)
%
% Backup all cleaning tool information and biomet.net to a database in
% BASEDIR

if strcmp(upper(fr_get_pc_name),'PAOA001')
    arg_default('BASEDIR','y:');
else
    arg_default('BASEDIR','d:');
end    

today_str = datestr(now,'yyyy-mm-dd');
today_str = today_str([1:4 6:7 9:10]);

mkdir(BASEDIR,fullfile('Database\Calculation_Procedures\TraceAnalysis_ini',SiteId,'old',today_str));
pth_ta = fullfile(BASEDIR,'Database\Calculation_Procedures\TraceAnalysis_ini',SiteId,'old',today_str);

disp('Copying TraceAnalysis_ini ...');
copyfile(fullfile(biomet_path('Calculation_Procedures','TraceAnalysis_ini',SiteId),'*'),pth_ta);

disp('Copying biomet.net ...');
fr_copy_biomet_dot_net(pth_ta)

disp('Copying Site_specific ...');
mkdir(pth_ta,'UBC_PC_Setup\Site_specific');
fp = fopen(fullfile(pth_ta,'UBC_PC_Setup\Site_specific','fr_current_siteid.m'),'w');
fprintf(fp,'function SiteId = fr_current_siteid\n SiteId = upper(''%s'');',SiteId);
fclose(fp);

