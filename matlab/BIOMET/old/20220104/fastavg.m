function [y,y_nanFlag] = fastavg(x,periodToAvg)
% fastavg - creates averages over a period. Handles NaN's properly
%
% This function is used to quickly calculate averages over a uniform
% periods of time. Good for calculating 1-day, 2-day or n-day averages
% of half-hourly data (assuming that x is hhourly data):
%   y = fastavg(x,48);     daily averages
%   y = fastavg(x,48*5);   5-day averages
% 
% Inputs:
%   x           - data array N x 1
%   periodToAvg - period to average
% Outputs:
%   y           - output array floor(N/periodToAvg) x 1
%   y_nanFlag   - number of NON-NaN's in each period floor(N/periodToAvg) x 1
%
% (c) Zoran Nesic           File created:       May 29, 2002
%                           Last modification:  Aug 15, 2005


% Revisions
%   Aug 15, 2005 - 
%       - rounded lv to avoid warning messages
%   CRS 09.02.05 - y_nanFlag is number of NON-NaN's (corrected in help)
%                - for traces w/o NaNs y_nanFlag was undefined (now fixed)

x = x(:);
lv = round(length(x)/periodToAvg);
y_nanFlag = periodToAvg.*ones(lv,1);
x_nanFlag = isnan(x);
if ~any(x_nanFlag)
    xsum = cumsum(x);
    y = xsum(2*periodToAvg:periodToAvg:end)-xsum(periodToAvg:periodToAvg:end-periodToAvg);
    y = [xsum(periodToAvg); y]/periodToAvg;
else
    x(x_nanFlag) = 0;
    xsum = cumsum(x);
    y = xsum(2*periodToAvg:periodToAvg:end)-xsum(periodToAvg:periodToAvg:end-periodToAvg);
    y = [xsum(periodToAvg); y];
    x_nanFlag_sum = cumsum(x_nanFlag);
    y_nanFlag = x_nanFlag_sum(2*periodToAvg:periodToAvg:end)-x_nanFlag_sum(periodToAvg:periodToAvg:end-periodToAvg);
    y_nanFlag = periodToAvg-[x_nanFlag_sum(periodToAvg); y_nanFlag];
    y = y./y_nanFlag;
end
    
