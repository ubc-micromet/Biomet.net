function db_dir_ini(years,SiteId,base_dir,stages,dir)
% db_dir_ini - Generate empty clean database structure
% 
% db_dir_ini(years,SiteId,base_dir) Makes all necessary directories
% putting years into basedir if the directories exist in the biomet
% database. If a directory already exists its contents are deleted.
%
% db_dir_ini(years,SiteId,base_dir,stages), where stages can be a vector
% with elements 1 2 and 3, creates/deletes only the dir structure for the
% stages listed in the vector
%
% db_dir_ini(years,SiteId,base_dir,3,dir), where dir is a string containing
% a directory name, creates/deletes this directory in the database 
% structure as a third-stage output directory. The dir argument will be
% ignored for stages other than 3 

arg_default('stages',[1 2 3]);
arg_default('dir','');

db_pth = biomet_path('1111','xx');
ind = find(db_pth == filesep);
db_pth = db_pth(1:ind(end-2));

for i = years

    yyyy = num2str(i);

   if find(stages == 1)
       do_dir(db_pth,base_dir,fullfile(yyyy,SiteId,'Flux','Clean')); 
       do_dir(db_pth,base_dir,fullfile(yyyy,SiteId,'Climate','Clean')); 
       do_dir(db_pth,base_dir,fullfile(yyyy,SiteId,'Profile','Clean')); 
   end
   
   if find(stages == 2)
       do_dir(db_pth,base_dir,fullfile(yyyy,SiteId,'Clean','SecondStage')); 
   end
   
   if find(stages == 3)
       if isempty(dir)
           do_dir(db_pth,base_dir,fullfile(yyyy,SiteId,'Clean','ThirdStage')); 
       else
           do_dir([],base_dir,fullfile(yyyy,SiteId,'Clean',dir)); 
       end
   end
   
end

function do_dir(db_pth,base_dir,pth)
% db_pth   - input database (used to test existance of dir)
% base_dir - output database
% pth      - relative path in database to be initialized

% If input database has the pth OR if input and output are the same, initialize
% On paoa001 input is \\annex001\database, output is Y:\database
% On all other computers, default in and out is \\annex001, which is read-only and 
% won't work.

if base_dir(end) ~= '\'
    base_dir = [base_dir '\'];
end
if db_pth(end) ~= '\'
    db_pth = [db_pth '\'];
end

if isempty(db_pth) | exist(fullfile(db_pth,pth)) == 7 | strcmp(upper(db_pth),upper(base_dir))
    if exist(fullfile(base_dir,pth)) == 7
        warning off;
        delete(fullfile(base_dir,pth,'*'));
        warning on;
        disp(['Deleted contents of ' fullfile(base_dir,pth)]);
    else
        mkdir(base_dir,pth)
        disp(['Created ' fullfile(base_dir,pth)]);
    end
end

