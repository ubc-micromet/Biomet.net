function [LE] = calc_LE_response_time_corr(LE, detrend_type, siteID, years);

% detrend_type = 1 for block average
%              = 2 for linear detrend

% E. Humphreys Dec 7, 2001 (based on my old permanent_fluxes.m routine)
%
% Revisions:
% Feb 13, 2004 kai* - Inserted a retunr and disp when correction is not available
%                     so the function does not crash

if upper(siteID) ~= 'CR'
    disp('Response time corretion for LE is only implemented for CR!');
    return
end

if years > 2000; %correction not yet available for years greater than 2000
   disp('No response time corretion for LE is applied as it is only available for 2000 and earlier!');
   return
end

pth   = biomet_path(years,siteID,'fl');
pthc  = [pth(1:end-1) '_errors\'];

if detrend_type == 2;%linear
    cf_deg = read_db(years,siteID,'flux_errors','cffluxes.9'); %lin detrend
else
    cf_deg = read_db(years,siteID,'flux_errors','cffluxes.10'); %avg detrend
end

%remove extreme values| negative values | values < 1 (so as not to reduce flux further)
bad      = find(cf_deg ==0 | cf_deg >2 | cf_deg < 1);  

cf_deg(bad) = NaN;


ind      = find(~isnan(cf_deg));
if ~isempty(ind);
    LE(ind)= LE(ind).*cf_deg(ind);
end


