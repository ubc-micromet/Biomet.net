function trace_str = readIniFileDirect(yearIn,SiteID,stageNum)
% Reads a TraceAnalysis ini file
%
% trace_str = readIniFileDirect(year,SiteID,stageNum)
%
% Arguments
%
%   yearIn      - the year that requires processing
%   siteID      - site name (like 'DSM')
%   stageNum    - a number (1-3) of the cleaning stage number
%
%   trace_str   - a structure read from the ini file
%
%
% Zoran Nesic               File created:       Jan 25, 2023
%                           Last modification:  Jan 25, 2023

% Revisions
%


arg_default('stageNum',1)
switch stageNum
    case 1
        fileName = [SiteID '_FirstStage.ini'];
    case 2
        fileName = [SiteID '_SecondStage.ini'];
    case 3
        fileName = [SiteID '_ThirdStage.ini'];
end
iniFileName = fullfile(db_pth_root,'Calculation_Procedures','TraceAnalysis_ini',SiteID,fileName);

%Open initialization file if it is present:
if exist(iniFileName,'file')
   fid = fopen(iniFileName,'rt');						%open text file for reading only.   
   if (fid < 0)
      disp(['File, ' iniFileName ', is invalid']);
      trace_str = [];
      return
   end
else
    fprintf('Could not open file: %s\n', iniFileName);
    return
end

% Added by June Skeeter to alow reading from updated ini files
% Must be updated here and in read_data.m < could be approached
% differently, just a quick solution for now
updated_sites = {'BB','BB2','BBS'};
if sum(strcmp(updated_sites,SiteID)) == 0
    trace_str = read_ini_file(fid,yearIn);  
else
    trace_str = read_ini_file_update(fid,yearIn);  
end
fclose(fid);
