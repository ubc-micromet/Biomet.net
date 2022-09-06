function DBASE_PATH = biomet_path(Year,SiteID,type_of_measurements)
%
% Create paths for different sites/years/types of measurements.
%
% inputs
%       Year            =1999   ' for 1996->1999 period
%                       =xxxx   ' for years >=2000, default is the current year
%                       =yyyy   ' for a wildcard (it will return 'yyyy' while a year 
%                               ' would otherwise go)
%       SiteID          'XX'    where xx stands for 'CR', 'JP', 'BS', 'PA' sites
%                               default is obtained by running FR_current_site_id.m
%       type_of_measurements    = 'fl' for flux, 'cl' for climate, 'ch' for chambers
%
% If a function biomet_database_default exists in the path that returns the localtion
% of the database it will be used, otherwise it is assumed that the database it in
% '\\annex001\database'
%
% (c) Zoran Nesic               File created:             , 1998
%                               Last modification:  Feb  2, 2004
%

% Revisions:
%   Feb 2, 2004
%       - added use of biomet_database_default
%   Feb 7, 2002
%       - added option to call any folder name eg. biomet_path(2002,'cr','Clean\SecondStage')
%   Jun 11, 2001
%       - added profile type and folder
%   Jan 10, 2000
%       - added an option of inserting a wildcard: yyyy. See the syntax of read_bor and
%         the tutorial file read_bor_primar for a proper usage.
%   Nov 24, 2000
%       - added 'highlevel' as possible type of measurement

if exist('type_of_measurements') ~= 1 | isempty(type_of_measurements)
   type_of_measurements = ''; 
end

if exist('Year') ~= 1 | isempty(Year) 
    Year = datevec(now);                % if Year is missing/empty assume current year
    Year = Year(1);
elseif isstr(Year)
                                        % if year is string assume that user is adding "yyyy"
                                       
elseif Year < 1996
    error 'Wrong input: (year<1996)'
elseif Year <= 1999 & strcmp(upper(type_of_measurements),'HIGH_LEVEL') == 0
    Year = 1999;                        % for non high level and years 1997 -> 1999 use year 1999
end

if exist('SiteID') ~= 1 | isempty(SiteID)
    SiteID = fr_current_siteID;         % if SiteID is missing/empty assume siteID
end


if exist('biomet_database_default') == 2
   DBASE_DISK = biomet_database_default;
else
   DBASE_DISK = '\\annex001\DATABASE';
end

switch upper(type_of_measurements)
    case 'CL', folderName = 'Climate';
    case 'CH', folderName = 'Chambers';
    case 'FL', folderName = 'Flux';
    case 'PR', folderName = 'Profile';
    case 'MISC', folderName = 'Misc';
    case 'HIGH_LEVEL', folderName = 'Clean\ThirdStage';
    otherwise, folderName = type_of_measurements;
end

DBASE_PATH = fullfile(DBASE_DISK, num2str(Year), upper(SiteID), folderName, filesep);
