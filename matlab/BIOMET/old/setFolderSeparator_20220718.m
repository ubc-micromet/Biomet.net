function pathOut = setFolderSeparator(pathIn)
% pathOut = setFolderSeparator(pathIn)
%
% This function sets all the incorrect file separators in the string pathIn
% to the OS appropriate file separator (Windown: '\', MacOS: '/'
%
% Zoran Nesic                   File created:       Apr 11, 2022
%                               Last modification:  Apr 11, 2022

% Revisions:
%

pathOut = pathIn;
if filesep == '\'
    ind_file_sep = strfind(pathOut,'/');
else
    ind_file_sep = strfind(pathOut,'\');
end
pathOut(ind_file_sep) = filesep;