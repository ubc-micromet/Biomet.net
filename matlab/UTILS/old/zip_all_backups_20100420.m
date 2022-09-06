

lstfold = dir('D:\clean_db_backups');

xx= {lstfold.name}';
for i=1:length(xx)
    if length(char(xx{i})) == 8
        dbfldr = char(xx{i});
        dosCmdStr = ['"C:\Program Files\7-Zip\7z.exe" a -tzip d:\temp\'...
                      dbfldr '.zip D:\clean_db_backups\'  dbfldr '\ -r -wd:\temp'];
        disp(dosCmdStr);
        dos(dosCmdStr);
    end
end