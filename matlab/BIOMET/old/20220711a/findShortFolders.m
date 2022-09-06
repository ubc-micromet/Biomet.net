function [numOfShortFolders,shortFolders]= findShortFolders(pth,minNumOfFiles)
%  findShortFolders - finds folders that have fewer files than expected
%  
% Inputs:
%   pth - path (with wild card) where the folders are
%   minNumOfFiles - the expected number of files in the folder
% Outputs:
%   numOfShortFolders - number of folders that have fewer files than expected
%   shortFolders      - structure with found folders' names
%
% Example:
%   [numOfShortFolders,shortFolders]= findShortFolders('\\137.82.254.91\mydisk_d$\Gesa_data\MPB1\met-data\data\18*',48);
%
% (c) Zoran Nesic                               File created:      Jan  8, 2020
%                                               Last modification: Jan  8, 2020
%                                               

% Revisions:
%
%

allSubFolders =dir(pth);
M = length(allSubFolders)-2;
numOfShortFolders = 0;
shortFolders = [];

if M > 0
    h = waitbar(0,'Please wait...');
    set(h,'name','Finding short folders. Please wait...');
    for i=1:M+2
        waitbar(i/M,h,{'Please wait...',sprintf('Processing folder #%d of %d',i,M),sprintf('Short folders found: %d',numOfShortFolders)});
        if ~strcmp(allSubFolders(i).name,'.') & ~strcmp(allSubFolders(i).name,'..') & allSubFolders(i).isdir == 1 %#ok<*AND2>
            % count files within folder
            pthCurrent = fullfile(allSubFolders(i).folder,allSubFolders(i).name);
            allFiles = dir(pthCurrent);
    %         N = 0;
    %         for j=1:length(allFiles)
    %              if allSubFolders(j).isdir == 0
    %                  N = N+1;
    %              end
    %         end
            N = length(allFiles)-2;
            if N < minNumOfFiles
                numOfShortFolders = numOfShortFolders +1;
                shortFolders(numOfShortFolders).name = pthCurrent; %#ok<*AGROW>
                shortFolders(numOfShortFolders).numOfFiles = N;
                %fprintf('(%d/%d) %s has %d files.\n',i,M,pthCurrent,N);
            end
        end
    end
    close(h)
    delete(h)
    fprintf('Number of folders that have fewer than %d files is %d of %d\n',minNumOfFiles,numOfShortFolders,M);
else
    fprintf('No folders found for: %s\n',pth);
end
