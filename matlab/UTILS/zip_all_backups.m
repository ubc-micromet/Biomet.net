function zip_all_backups(pth_zip);

% zips all database folders in pth_zip then removes uncompressed files if
% successful

lstfold = dir(pth_zip);
n=[lstfold.isdir]';
ind=find(n==1);
xx= {lstfold(ind).name}';


for i=1:length(xx)
    if length(char(xx{i})) == 8
        dbfldr = char(xx{i});
        %dosCmdStr = ['"C:\Program Files\7-Zip\7z.exe" a -tzip ' fullfile(pth_zip,...
        %              [dbfldr '.zip']) ' '  fullfile(pth_zip,dbfldr) '\ -r -w' pth_zip];
        dosCmdStr = ['zip_clean_db  ' fullfile(pth_zip,[dbfldr '.zip']) ' ' fullfile(pth_zip,dbfldr) ' ' pth_zip];
        disp(dosCmdStr);
        dos(dosCmdStr);
    end
end