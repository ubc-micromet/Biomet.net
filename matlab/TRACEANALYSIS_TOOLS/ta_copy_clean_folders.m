function ta_copy_clean_folders(yearIn,siteID,dbPathOut,dbPathIn)
% ta_copy_clean_folders(yearIn,siteID,dbPath) - make a copy of all clean database folders 
%
% yearIn    -   Year to copy
% siteID    -   Site ID
% dbPathIn  -   path to source data base (default:biomet_path="\\annex001\database")
% dbPathOut -   destination path for the copied data
%
% Example:      ta_copy_clean_folders(2021,'MPB1','d:\junk\database_backups')
% same as:      ta_copy_clean_folders(2021,'MPB1','d:\junk\database_backups','\\annex001\database')
%
% Zoran Nesic       File created:       Aug  1, 2022
%                   Last modification:  Aug  1, 2022

%
% Revisions:
%

if exist('biomet_database_default','file') == 2
   tmp = biomet_database_default;
else
   tmp = '\\annex001\DATABASE';
end
arg_default('dbPathIn',tmp);
outputPath = fullfile(dbPathIn,num2str(yearIn),siteID);

% get all folders that contain "Clean" in their names
s = fr_folder_search_recursive(outputPath,'Clean',1);

% Pick only the top "Clean" folders (remove "Clean\ThirdStage"...)
foldersToCopy = strings(length(s),1);
for cnt=1:length(s)
    if s(cnt).name=='.'
        foldersToCopy(cnt) = s(cnt).folder;
    else
        foldersToCopy(cnt) = fullfile(s(cnt).folder,s(cnt).name);
    end
end

% Backup the selected folders using robocopy
% fprintf('---------------------------------\n');
% fprintf('Status == 1 -> files copied OK.\n');
% fprintf('Status == 0 -> source empty, source files didn''t change or an error.\n\n');
for cnt = 1:length(foldersToCopy)
    outputPath = fullfile(dbPathOut,extractAfter(foldersToCopy(cnt),dbPathIn));
    cmdStr = sprintf('robocopy %s %s /R:3 /W:10 /REG /MIR /NDL /NFL /NJH',foldersToCopy(cnt),outputPath); 
    [status,result] = system(cmdStr); %#ok<ASGLU>
%    fprintf('Status: %d %s\n',status,cmdStr)
%     if status ==1
%         fprintf('OK! Copied folder: %s\n',foldersToCopy(cnt));
%     else
%         fprintf('Error copying folder: %s to folder: %s\n',foldersToCopy(cnt),outputPath);
%         disp(result);
%     end
end