function DBASE_PATH = biomet_path(Year,SiteID,type_of_measurements)
% (Zoran's version of biomet_path.m, -> used in cases when writing into the dbase is needed)
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
% (c) Zoran Nesic               File created:             , 1998
%                               Last modification:  Jun 11, 2001
%

% Revisions:
%   
%   Jun 11, 2001
%       - added profile type and folder
%   Jan 10, 2000
%       - added an option of inserting a wildcard: yyyy. See the syntax of read_bor and
%         the tutorial file read_bor_primar for a proper usage.
%   Nov 24, 2000
%       - added 'highlevel' as possible type of measurement

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
if exist('type_of_measurements') ~= 1 | isempty(type_of_measurements)
    type_of_measurements = 'cl';        % if type_of_measurements is missing/empty assume
                                        % climate measurements
end

switch upper(type_of_measurements)
    case 'CL', folderName = 'Climate';
    case 'CH', folderName = 'Chambers';
    case 'FL', folderName = 'Flux';
    case 'PR', folderName = 'Profile';
    case 'MISC', folderName = 'Misc';
    case 'HIGH_LEVEL', folderName = 'Clean';
    otherwise, folderName = 'Climate';
end

DBASE_PATH = ['y:\DATABASE\' num2str(Year) '\' upper(SiteID) ...
              '\' folderName '\'];
                    


%function [BIOMET_CLIMATE_PATH,BIOMET_EDDY_OA_PTH, ...
%          BIOMET_EDDY_BS_PTH, BIOMET_EDDY_CR_PTH] = biomet_path
%DBASE_DISK = '\\annex001\DATABASE\';
%DBASE_CLIMATE_FOLDER = 'ClimateData\newdata\';
%DBASE_EDDY_FOLDER = 'DATA_BASE\';
%BIOMET_EDDY_OA_PTH = [DBASE_DISK 'PA_DBASE\'];
%BIOMET_EDDY_BS_PTH = [DBASE_DISK 'BS_DBASE\'];
%BIOMET_EDDY_CR_PTH = [DBASE_DISK 'CR_DBASE\'];
%BIOMET_CLIMATE_PATH =[DBASE_DISK DBASE_CLIMATE_FOLDER]; 