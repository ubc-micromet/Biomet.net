function gmt_shift = fr_gmt_shift(SiteID)
% Legacy function - DO NOT USE
%
% Instead use 
%               FR_get_offsetGMT(SiteID)

if ~exist('SiteID')
    SiteID = FR_current_siteID;
end
 
gmt_shift = FR_get_offsetGMT(SiteID)