function recalc_setup(BASEDIR,Years,SiteId)
% recalc_setup(BASEDIR,Years,SiteId)
%
% Recalc setup:
% BASEDIR is the directory that contains the high frequency data in a
% subdirectory data, i.e. the recalculation results are stored on the same
% hard drive as the high frequency data.
% 
% This function creates the all directories and files necessary to
% recalculate fluxes for a site year in a directory 
% BASEDIR\recalc_YYYYMMDD
% After running this function a recalculation can be initiated by
% 1) cd-ing into BASEDIR\recalc_YYYYMMDD
% 2) running recalc_set_path
% 3) running recalc_siteyear(SiteID,tv_recalc)
%
% The setup consists of the following steps:
%
% - Create directory BASEDIR\recalc_YYYYMMDD
% - Create directory BASEDIR\recalc_YYYYMMDD\hhour
% - Copy \\paoa001\sites\SITEID\hhour\calibrations* to 
%   BASEDIR\recalc_YYYYMMDD\hhour
% 
% - Create directoy BASEDIR\recalc_YYYYMMDD\site_specific
% - Copy \\paoa001\sites\SITEID\Site_specific\*.m to 
%   BASEDIR\recalc_YYYYMMDD\site_specific
% - Copy \\paoa001\matlab\biomet\recalc\fr_get_local_path.m to
%   BASEDIR\recalc_YYYYMMDD\site_specific
% 
% - Create directoy BASEDIR\recalc_YYYYMMDD\PC_specific
% - Copy C:\UBC_PC_Setup\PC_specific\fr_get_pc_name.m to
%   BASEDIR\recalc_YYYYMMDD\PC_specific
% 
% - Create directoy BASEDIR\recalc_YYYYMMDD\biomet.net\matlab
% - Copy \\paoa001\matlab to 
%   BASEDIR\recalc_YYYYMMDD\biomet.net\matlab
% 
% - Copy required part of \\annex001\database to
%   BASEDIR\recalc_YYYYMMDD\database
% 
% - Copy \\paoa001\matlab\biomet\recalc\recalc_set_path.m to
%   BASEDIR\recalc_YYYYMMDD
% 

today_str = datestr(now,'yyyy-mm-dd');
today_str = today_str([1:4 6:7 9:10]);
pth_recalc = ['recalc_' today_str];
mkdir(BASEDIR,fullfile(pth_recalc,'hhour'));

% Generate new database in BASEDIR
recalc_cleaning(fullfile(BASEDIR,pth_recalc),Years,SiteId)

pth_hhour = fullfile(BASEDIR,pth_recalc,'hhour');
copyfile(['\\paoa001\sites\' SiteId '\hhour\calibrations*'],pth_hhour);

mkdir(BASEDIR,fullfile(pth_recalc,'site_specific'));
pth_sitespec = fullfile(BASEDIR,pth_recalc,'site_specific');
copyfile(['\\paoa001\sites\' SiteId '\UBC_PC_Setup\Site_specific\*.m'],pth_sitespec); 
copyfile('\\paoa001\matlab\biomet\recalc\fr_get_local_path.m',pth_sitespec); 
 
mkdir(BASEDIR,fullfile(pth_recalc,'PC_specific'));
pth_pcspec = fullfile(BASEDIR,pth_recalc,'PC_specific');
try
    copyfile('C:\UBC_PC_Setup\PC_specific\fr_get_pc_name.m',pth_pcspec); 
catch
    copyfile('\\paoa001\matlab\biomet\recalc\fr_get_pc_name.m',pth_pcspec); 
end

fr_copy_biomet_dot_net(fullfile(BASEDIR,pth_recalc));

fp = fopen(fullfile(BASEDIR,pth_recalc,'biomet.net\matlab\biomet\biomet_database_default.m'),'w');
fprintf(fp,'function DBASE_DISK = biomet_database_default\n DBASE_DISK = ''%s\\Database'';',fullfile(BASEDIR,pth_recalc));
fclose(fp);

copyfile('\\paoa001\matlab\biomet\recalc\recalc_set_path.m',fullfile(BASEDIR,pth_recalc)); 
