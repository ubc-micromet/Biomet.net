function [numFiles] = fr_moveHFtoDailyFolders(inPath,numOfChars)
% fr_moveHFtoDailyFolders(inPath) - files with matching first numOfChars
% characters in their name get moved into a subfolder inPath\abcdef where
% abcdef are the first numOfChars in the file name.
% 
% Example:
%    [numFiles] = fr_moveHFtoDailyFolders('d:\met-data\data',6)
%   If folder d:\met-data\data contains 3 files:
%   08031002.bin
%   08031092.txt
%   08031156.bin
%   Program will move files 08031002.bin and 08031092.txt into
%   d:\met-data\data\080310 folder. File 08031156.bin will go into
%   d:\met-data\data\080311 folder
% 
% (c) Zoran Nesic                   File created:       Mar 12, 2008
%                                   Last modification:  Mar 12, 2008


% Revisions:
%

numFiles = 0;

if ~exist(inPath,'dir')
    error ('Folder: %s does not exist!',inPath)
end

s = dir(inPath);

if isempty(s) 
    disp(sprintf('Directory %s is empty! No files were moved!',inPath));
end

for i=1:length(s)
    fileName = char(s(i).name);
    % check if it's a file
    if exist(fullfile(inPath,fileName),'file')~=7 && length(fileName) > numOfChars
        % if it is, check if there is already a folder with the right name
        if ~exist(fullfile(inPath,fileName(1:numOfChars)),'dir')
            mkdir(inPath,fileName(1:numOfChars))
        end
        % now move the file to that folder
        [ret,errMsg] = movefile(fullfile(inPath,fileName),fullfile(inPath,fileName(1:numOfChars)));
        if ret == 1
            numFiles = numFiles + 1;
        else
            disp(errMsg)
        end
    end
end
