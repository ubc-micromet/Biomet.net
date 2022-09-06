pthBackupRoot = 'D:\Biomet.net_DailyBackups';
%pthBackupRoot = 'c:\Biomet.Net';

s = fr_folder_search_recursive(fullfile(pthBackupRoot,'\2022-08-10'),'*.m');
%s = fr_folder_search_recursive(pthBackupRoot,'*.m');

%s1 = fr_folder_search_recursive(fullfile(pthBackupRoot,'\2022-07-19'),'*.m');
s1 = s;
diffCounter = 0;
for cntFile=1:length(s)
    fileName = s(cntFile).name;
    fileP = s(cntFile).folder;
    fileD = s(cntFile).datenum;
    for cntFile1=1:length(s1)
        fileName1 = s1(cntFile1).name;        
        if strcmpi(fileName,fileName1)
            fileP1 = s1(cntFile1).folder;
            fileD1 = s1(cntFile1).datenum;
            indSubFolder = length(pthBackupRoot)+1;
            samePath = strcmpi(fileP(indSubFolder:end),fileP1(indSubFolder:end));
            sameDate = fileD==fileD1;
            if ~samePath & ~sameDate
                diffCounter = diffCounter+1;
                fprintf('File %s is different (%s)\n',fileName,fileP);
                if ~samePath
                    fprintf('   Path:  %s\n',fileP);
                    fprintf('   Path1: %s\n',fileP1);
                end
                if ~sameDate
                    fprintf('   Date:  %s\n',datestr(fileD));
                    fprintf('   Date1: %s\n',datestr(fileD1));
                end
            end
        end
    end
end
fprintf('Checked: %d files. Found %d differences\n',length(s),diffCounter);
