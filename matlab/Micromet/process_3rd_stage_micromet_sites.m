function process_3rd_stage_micromet_sites(all_sites)
% process_3rd_stage_micromet_sites(all_sites)
%
% This function runs from a scheduler (LoggerNet on vinimet)
% and does the third stage processing and Ameriflux data exporting
% for all Micromet sites. 
%
% Zoran Nesic           File created:       Sep 23, 2023
%                       Last modification:  Sep 23, 2023

% Revisions
%

arg_default('all_sites',{'BB','BB2','DSM','RBM','Young','Hogg','OHM','BBS'});

currentYear = year(datetime("now"));
for cntSite = 1:length(all_sites)
    try
        fr_automated_cleaning(currentYear,all_sites(cntSite),[7 8]);
    catch
    end
end