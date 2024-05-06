function timestamp_csi_files(csiPath)
% timestamp_csi_files - rename all *.dat files in csiPath folder to *.yyyymmddThhmmss
%
% Input:
%   csiPath     - Folder containing *.dat files
%
% Zoran Nesic               File created:       May  6, 2024
%                           Last modification:  May  6, 2024

% Revisions
%

filePath = fullfile(csiPath,'*.dat');
fileNames = dir(filePath);
if isempty(fileNames)
    error('No *.dat file in folder: %s',csiPath);
end
for cntFiles = 1:length(fileNames)
    try
        srcFile = fullfile(fileNames(cntFiles).folder,fileNames(cntFiles).name);
        [~,cFileName] = fileparts(srcFile);
        destFile = fullfile(fileNames(cntFiles).folder,[cFileName '.' char(datetime("now","Format",'yyyyMMdd''T''HHmmss'))]);
        [status,cMessage] = movefile(srcFile,destFile);
        if status == 0
            fprintf(2,'Could not rename %s to %s\n',srcFile,destFile);
            fprintf(2,'Error: %s\n',cMessage);
        end
    catch ME
        rethrow ME
    end
end

    

