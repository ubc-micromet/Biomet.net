function [x,tv,tv_dt] = read_bor_sparse(pathIn,traceName)
% read_bor_sparse - reads Biomet database sparse files
%
% Note: In the context of a Biomet database, sparse files are binary 
%       files that have TimeVector that only has values for which the 
%       the measurements have occured. Regular database files contain
%       data points for each time period (usually 30-min) for an entire year.
%
% Zoran Nesic               File created:       Sep 29, 2023
%                           Last modification:  Sep 29, 2023

% Revisions
%

tv = read_bor(fullfile(pathIn,'TimeVector'),8);
tv_dt = datetime(tv,'ConvertFrom','datenum');
if contains(traceName,'RecalcTime') ...
                        || contains(traceName,'TimeVector') ...
                        || contains(traceName,'sample_tv') ...
                        || contains(traceName,'clean_tv')
    data_type = 8;
else
    data_type = 1;
end
x = read_bor(fullfile(pathIn,traceName),data_type);
indGood = find(~isnan(x));
tv = tv(indGood);
tv_dt = tv_dt(indGood);
x = x(indGood);