function [newPath,oldPath] = change_path_to_BiometNet(newPathPat)
% Change the path to all Biomet.net subfolders to newPath
%
% newPathPat - new path pattern to "matlab" folder instead of the default: "\\PAOA001\matlab\"
%              newPathPat has to contain string "matlab" at the end!
%
% Program searches through the current path to find the occurance of "New_eddy".
% It then uses that as the reference point of the current path for Biomet.net functions.
% It replaces all the lines that contain "\matlab\New_eddy\" with <newPathPat>\New_eddy\.
% 
% Example:
%    If the original path is:
%       \\paoa001\matlab\New_eddy
%    and the newPath is:
%       D:\NZ\MATLAB\CurrentProjects\GitHub\Biomet.net
%    then all paths that contain:
%       \\paoa001\matlab\
%    will change to:
%       D:\NZ\MATLAB\CurrentProjects\GitHub\Biomet.net\matlab
%
% Zoran Nesic               File created:           Sep  5, 2022
%                           Last modification:      Sep 11, 2022

%
% Revisions:
%
% Sep 11, 2022 (Zoran)
%   - Edited a few comments.
%

% Store the current full path
oldPath = path;

% Make sure that the newPathPat uses proper folder separators
newPathPat = setFolderSeparator(char(newPathPat));
% Make sure that newPath ends with filesep
if ~strcmp(newPathPat(end),filesep)
    newPathPat(end+1) = filesep;
end

% at this point newPathPat has to end with matlab\ or matlab/
if ~strcmpi(newPathPat(end-6:end),['matlab' filesep])
    error('Input path: %s has to end with the string "matlab"\nMaybe you want: %s%s%s',newPathPat,newPathPat,'matlab',filesep)
end
% find the target folder (here we use the first occurance of 
%      "New_eddy" to find the folder that needs replacing
strInd = strfind(oldPath,'New_eddy');
indSep = strfind(oldPath,';');
indEnd = find(indSep >= strInd(1),1);
oldPathPat = oldPath(indSep(indEnd-1)+1: strInd(1)-1);  % pathPat = "\\paoa001\matlab\"

% Replace oldPathPat in oldBiometPath with newPathPat
newPath = replace(oldPath,oldPathPat,newPathPat);

% Set the new path
path(newPath);