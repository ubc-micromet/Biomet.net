function pth_out = fr_valid_path_name(pth)
%
%
% Check if this is valid path name. Return the path name plus an optional
% '\' at the end if path is OK, else return an empty matrix
%
% (c) Zoran Nesic       File created:       Feb 22, 1998
%				        Last modification:	Feb 22, 1998
%

%
% Revisions:
%

if pth(length(pth)) ~= '\'          % path name must end with a '\'
    pth = [pth '\'];
end

if exist(pth) == 7                  % check if the path exists (must be a
    pth_out = pth;                  % directory not a file!)
else
    pth_out = [];
end 

