function mergeSmartFluxUSBdata(siteName,inputFolder)
%% Merging SmartFlux data
%
% Cycle through all subfolders of inputFolder and robocopy 
% data to the mergedDataFolder.

baseSourceFolder = '\\137.82.254.70\data-dump';
baseMergedDataFolder = '\\137.82.254.70\highfreq';
% siteName = 'DSM';
% inputFolder = '2021_Flux';

sourceFolder = fullfile(baseSourceFolder,siteName,inputFolder);
mergedDataFolder = fullfile(baseMergedDataFolder,siteName);

s = dir(sourceFolder);
for cntFolders = 1:length(s)
    if ~strcmp(s(cntFolders).name,'.') && ~strcmp(s(cntFolders).name,'..') && ...
            s(cntFolders).isdir 
        folderToCopy = fullfile(s(cntFolders).folder,s(cntFolders).name);
        fprintf('(%d/%d) Merging: %s with %s\n',cntFolders,length(s),folderToCopy,mergedDataFolder);        
        cmdStr = sprintf('robocopy %s %s /R:3 /W:3 /E /REG /NDL /NFL /NJH',folderToCopy,mergedDataFolder);
        system(cmdStr);
    end
    
end