function pth = db_HFREQ_root
% pth = db_HFREQ_root
%
% Returns the root path (computer name) to High Frequency data

% Last modified: 
%  
%   Nov 29, 2016 (Zoran)
%       - function created

if exist('biomet_HFREQ_default') == 2
    pth = biomet_HFREQ_default;
else
    pth = '\\Biomet02\';
end

