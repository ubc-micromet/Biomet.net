function zip_and_move_clean_db_backups(base_dir,pth_zip,fnzip);

pth_archive = '\\Annex001\clean_db_backups';

% run batch file to create zip archive and delete if no issues

dosCmdStr = ['zip_clean_db  ' fnzip ' ' ...
              base_dir ' ' pth_zip];
disp(dosCmdStr);
dos(dosCmdStr);
