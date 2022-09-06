function stats = fr_save_hhour(SiteFlag,new_stats,pth)
%
% This function updates (saves) the new_stats into the 
% daily hhour stats file yymmdd.hp (h - hhour stats, p - site
% flag for PA).
%
%
% (c) Zoran Nesic           File created:       Feb 22, 1998
%                           Last modification:  Jun 20, 2001
%

%
% Revisions:
%
%   Jan 31, 2005
%       - added stats before rotation to shortfile (kai*)
%   Feb 14, 2002
%       - added chambers stuff (David)
%   Jun 20, 2001
%       - added Profile stuff
%   Apr 20, 1998
%       -   changed if ~exist('pth')
%           to      if ~exist('pth') | isempty(pth)
%           so more optional input parameters can be used after 'pth'
%       -   added saving of another data set that is the same as the 
%           original 'new_stats' and 'stats' but without the following data
%                   stats.Configuration = [];
%                   stats.BeforeRot = [];
%                   stats.AfterRot.Cov.AvgDtr = [];
%                   stats.RawData.AvgMinMax.Voltages = [];
%           The old file name   format: YYMMDD.xxx.mat
%           The added file name format: YYMMDDs.xxx.mat <- 's' stands for short
%           This data set (the short one) is the only stats file that is going to 
%           to be transfered to UBC on a regular basis.
%
%	Apr  9, 1998
%		- minor changes: elseif ~strcmp(pth(length(pth)),'\')
%
%   Apr  6, 1998
%       -   added one more input parameter: pth (path). If this variable exists
%           then it overwrites the default path!
%   Apr  1, 1998
%       -   simplified the program by saving the new_stats without 
%           looking at the existing data sets. This will be OK for
%           the time being. Chech if the function needs that functionality
%

% get the time and date for the first hhour in new_stats
currentDate	    = new_stats.TimeVector(1);
c               = fr_get_init(SiteFlag,currentDate);
if ~exist('pth') | isempty(pth)
    pth             = fr_valid_path_name(c.hhour_path);
    if isempty(pth)
       error(sprintf('Path: %s does not exist!', c.hhour_path))
    end
elseif ~strcmp(pth(length(pth)),'\')
    pth             = [pth '\'];
end
FileName_p      = FR_DateToFileName(currentDate);
FileName        = [pth FileName_p(1:6) c.hhour_ext];    % File name for the full set of stats
FileName_short  = [pth FileName_p(1:6) 's' c.hhour_ext];% File name for the short set of stats


stats = new_stats;

%% see if a file for the same date already exists
%if exist(FileName) == 2
%    load(FileName);
%else
%    stats = [];
%end
%
% join the new_stats with the rest of the file
%if isempty(stats)
%    hhours = 48;
%    stats.BeforeRot = zeros(1,1,hhours);
%    stats.AfterRot  = zeros(1,1,hhours);
%    stats.RawData   = zeros(1,1,hhours);
%    stats.Fluxes    = zeros(hhours,1);
%    stats.Misc      = zeros(hhours,1);
%    stats.Angles    = zeros(hhours,1);
%    stats.TimeVector= zeros(hhours,1);
%    stats.DecDOY    = zeros(hhours,1);
%    stats.Year      = zeros(hhours,1);
%end
%
%TimeVector      = new_stats.TimeVector;
%d1              = round( ( TimeVector - min(floor(TimeVector)) ) ...
%                         / (1/48) );
%                      
%if d1 == 0
%   d1 = 48;
%end
%                         
%if  max(d1) > 48
%    error 'More than one day of data cannot be handled by fr_save_hhour.m'
%end

%[j1,j2,j3]      = size(new_stats.BeforeRot);
%stats.BeforeRot(1:j1,1:j2,d1) ...
%                = new_stats.BeforeRot;
%stats.AfterRot (1:j1,1:j2,d1) ...
%                = new_stats.AfterRot;
%[j1,j2,j3]      = size(new_stats.RawData);
%stats.RawData(1:j1,1:j2,d1) ...
%                = new_stats.RawData;
%[j1,j2]         = size(new_stats.Fluxes);
%stats.Fluxes(d1,1:j2) ...
%                = new_stats.Fluxes;
%[j1,j2]         = size(new_stats.Misc);
%stats.Misc(d1,1:j2) ...
%                = new_stats.Misc;
%[j1,j2]         = size(new_stats.Angles);
%stats.Angles(d1,1:j2) ...
%                = new_stats.Angles;
%stats.TimeVector(d1,1) ...
%                = new_stats.TimeVector;
%stats.DecDOY(d1,1) ...
%                = new_stats.DecDOY;
%stats.Year(d1,1)= new_stats.Year;        
%

% save the new files
save(FileName,'stats');

%
% save the short version of the 'stats'. This version is going to be 
% transferd to UBC over the phone
%
stats.Configuration = [];
% stats.BeforeRot = [];
stats.BeforeRot.Cov.AvgDtr = [];
stats.AfterRot.Cov.AvgDtr = [];
stats.RawData.AvgMinMax.Voltages = [];

% Remove the extra profile data
%
if isfield(stats,'Profile')
    stats.Profile.co2.CycleAvg = [];
    stats.Profile.co2.CycleMin = [];
    stats.Profile.co2.CycleMax = [];
    stats.Profile.co2.CycleStd = [];

    stats.Profile.h2o.CycleAvg = [];
    stats.Profile.h2o.CycleMin = [];
    stats.Profile.h2o.CycleMax = [];
    stats.Profile.h2o.CycleStd = [];

    stats.Profile.Tbench.CycleAvg = [];
    stats.Profile.Tbench.CycleMin = [];
    stats.Profile.Tbench.CycleMax = [];
    stats.Profile.Tbench.CycleStd = [];

    stats.Profile.Plicor.CycleAvg = [];
    stats.Profile.Plicor.CycleMin = [];
    stats.Profile.Plicor.CycleMax = [];
    stats.Profile.Plicor.CycleStd = [];

    stats.Profile.Pgauge.CycleAvg = [];
    stats.Profile.Pgauge.CycleMin = [];
    stats.Profile.Pgauge.CycleMax = [];
    stats.Profile.Pgauge.CycleStd = [];
end

% remove some chamber stuff

if isfield(stats,'Chambers')
    stats.Chambers.CO2_HF = [];
    stats.Chambers.H2O_HF = [];
    stats.Chambers.Time_vector_HF = [];
end

save(FileName_short,'stats');


