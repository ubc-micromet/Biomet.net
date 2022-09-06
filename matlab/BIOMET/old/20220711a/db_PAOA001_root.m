function pth = db_PAOA001_root
% pth = db_PAOA001_root
%
% Returns the root path (computer name) to the computer holding \Matlab and
% \Sites folders (usually PAOA001)

% Last modified: 
%  
%   Nov 29, 2016 (Zoran)
%       - function created

if exist('biomet_PAOA001_default') == 2
    pth = biomet_PAOA001_default;
else
    pth = '\\PAOA001\';
end

