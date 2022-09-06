function zip_and_move_clean_db_backups(pth_zip,flag_sync);

lstfold = dir(pth_zip);
n=[lstfold.isdir]';
ind=find(n==1);
xx= {lstfold(ind).name}';

pth_archive = '\\Annex001\clean_db_backups';

for i=1:length(xx)
    if length(char(xx{i})) == 8
        dbfldr = char(xx{i});
       % dosCmdStr = ['"C:\Program Files\7-Zip\7z.exe" a -tzip ' fullfile(pth_zip,...
       %               [dbfldr '.zip']) ' '  fullfile(pth_zip,dbfldr) '\ -r -w' pth_zip];
       
       % run batch file to create zip archive and delete if no issues
       fnzip = fullfile(pth_zip,['CR_' dbfldr '.zip']);
       dosCmdStr = ['zip_clean_db  ' fnzip ' ' ...
                     fullfile(pth_zip,dbfldr) ' ' pth_zip];
       disp(dosCmdStr);
       dos(dosCmdStr);
    end
end

if flag_sync
% sync local zip archive with that on Annex001
   disp(['robocopy ' pth_zip ' ' pth_archive ' '  '/COPYALL /E /NP /R:0']);
   dos(['robocopy ' pth_zip ' ' pth_archive ' '  '/COPYALL /E /NP /R:0']);
end