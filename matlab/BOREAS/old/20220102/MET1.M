%==================================================================
%
%   MET1.m
%
%
%   This meta file loads a data file made by METxxx.BAS.
%
%==================================================================
format short e
if (exist('NumInt') ~= 1),
    dos('c:\biomet.net\matlab\boreas\InpFile');     % input the file name (EXE which writes 'loadNum')
    disp('working...')
    loadNum;         % load the file
end
%
% First set the constants 
%
met_head
%
