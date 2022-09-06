function recalc_cleaning(BASEDIR,Years,SiteId,old_dir)
% recalc_cleaning(BASEDIR,Years,SiteId,old_dir)
%
% Copy all data and files necessary for automated cleaning into a copy of the database.
% 'old_dir' is a string containing the date of the backup to be recalculated

arg_default('old_dir')

if ~isempty(old_dir)
    old_dir = fullfile('old',old_dir);
end

disp('Copying TraceAnalysis_ini and biomet.net ...')
mkdir(BASEDIR,fullfile('Database\Calculation_Procedures\TraceAnalysis_ini',SiteId));
pth_ta = fullfile(BASEDIR,'Database\Calculation_Procedures\TraceAnalysis_ini',SiteId);
copyfile(fullfile(biomet_path('Calculation_Procedures','TraceAnalysis_ini',SiteId),old_dir),pth_ta);

disp('Setting the path ...')
if ~isempty(old_dir)
    recalc_set_path(pth_ta);
end

if exist(biomet_path(Years(1),SiteId,'BERMS'))
   disp('Getting BERMS database ...')
   for i = 1:length(Years)
      if exist(biomet_path(Years(i),SiteId,'BERMS'))
         copyfile(biomet_path(Years(i),SiteId,'BERMS'),fullfile(BASEDIR,'Database',num2str(Years(i)),SiteId,'BERMS'));
      end
   end
end

% The cleaning log is written into the current directory and so we must have write access to it
disp('Firststage cleaning using the original database ...')
cd(pth_ta);

fr_automated_cleaning(Years,SiteId,[1],...
    fullfile(BASEDIR,'Database'),fullfile(BASEDIR,'Database'));

disp('Second and Thirdstage cleaning using the the recreated database ...')

fp = fopen(fullfile(pth_ta,'biomet_database_default.m'),'w');
fprintf(fp,'function DBASE_DISK = biomet_database_default\n DBASE_DISK = ''%s\\'';',fullfile(BASEDIR,'Database'));
fclose(fp);

fr_automated_cleaning(Years,SiteId,[2:3],...
    fullfile(BASEDIR,'Database'),fullfile(BASEDIR,'Database'));

