function x = DB_create_profile(pth,year,SiteID)
% Function that creates database files for profile system
%
%   pth  - output path for the data base
%   year - selects the year 
%   SiteID
%
% Created by David Gaumont-Guay    Jun  8, 2001
%                           
% Last modification:  Jan 27, 2003
% 
% Revisions:
%   - Jan. 27, 2003 - kept only co2_avg for profile CR
%   - Nov. 30, 2001 - added SiteID    
%   - Jun. 22, 2001 - put an option on the startDate and endDate depending on the year     

hhours_per_hour = 2;

if year <= 2000
    st = datenum(year,1,1,0,0,0);
    ed = datenum(year,12,31,23,30,0);
else
    st = datenum(year,1,1,0.5,0,0);
    ed = datenum(year+1,1,1,0,0,0);
end

if upper(SiteID) == 'CR'
   maxFiles = 4;
   % co2 profile half-hour averages 4 levels 
   fileName = 'co2_avg';
   [DB_len] = DB_create(pth,fileName,st,ed,hhours_per_hour,maxFiles);
else 
   maxFiles = 8;
   % co2 profile half-hour averages, 8 levels (PA,BS and JP) 
   fileName = 'co2_avg';
   [DB_len] = DB_create(pth,fileName,st,ed,hhours_per_hour,maxFiles);

   % h2o profile half-hour averages, 8 levels (PA,BS and JP)
   fileName = 'h2o_avg';
   [DB_len] = DB_create(pth,fileName,st,ed,hhours_per_hour,maxFiles);

   % Tbench profile half-hour averages, 8 levels (PA,BS and JP)
   fileName = 'Tbench_avg';
   [DB_len] = DB_create(pth,fileName,st,ed,hhours_per_hour,maxFiles);

   % Plicor profile half-hour averages, 8 levels (PA,BS and JP)
   fileName = 'Plicor_avg';
   [DB_len] = DB_create(pth,fileName,st,ed,hhours_per_hour,maxFiles);

   % Pgauge profile half-hour averages, 8 levels (PA,BS and JP)
   fileName = 'Pgauge_avg';
   [DB_len] = DB_create(pth,fileName,st,ed,hhours_per_hour,maxFiles);
end

% Recalc time vector (DOUBLE!!)
ZeroFile = zeros(DB_len,1);                           % create a full size zero array
fileName = fullfile(pth,'reclc.1');                           % recalc time vector
fid = fopen(fileName,'w');                            % create time vector file
file_err_chk(fid)                                     % check if file opened properly
x = fwrite(fid,ZeroFile,'float64');                   % save TimeVector
fclose(fid);

% ================
% LOCAL FUNCTIONS
% ================

function x = file_err_chk(fid)
    if fid == -1
        error 'File opening error'
    end
