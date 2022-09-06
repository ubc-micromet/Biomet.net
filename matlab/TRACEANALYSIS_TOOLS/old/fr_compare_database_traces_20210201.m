function fr_compare_database_traces(siteID,yearX,path_old,path_new,dataType)
%  fr_compare_database_traces - compare two UBC database folder
%
% This function is used to compare two database folders containing the same
% traces. Most often it's used to compare before and after folders after
% doing data recalculations or after changes in data cleaning procedures.
% Helpful when needed to assess how many traces and by what magnitude have
% been affected.
%
% Inputs:
%  siteID   - site ID
%  yearX    - year 
%  path_old - usually data base path ('//annex001/database/')
%  path_new - usually a local path ('D:/met-data/database/')
%  data_type - subfolder for the data:
%                       ('Clean/SecondStage','Climate/Clean',...)
%
% Example:
%   Start by cleaning MPB1 site for year 2015 and store the results locally (in d:\met-data\database\)
%     fr_automated_cleaning(2015,'MPB1', 1:3,'d:\met-data\database\')
%
%   Then compare the old and the new clean traces (first the second, then the third stage):
%     fr_compare_database_traces('MPB1',2019,'//annex001/database/',...
%                              'D:/met-data/database/','Clean/SecondStage')
%     fr_compare_database_traces('MPB1',2019,'//annex001/database/',...
%                              'D:/met-data/database/','Clean/ThirdStage')
%
%
%
% Zoran Nesic                   File created:       May 11, 2020
%                               Last modifications: Jun 22, 2020

% Revisions:
%
% Jun 22, 2020 (Zoran)
%   - fixed a bug where the Nans in New didn't show up if they didn't exist
%     in the Old data.
%


filePath_new = fullfile(path_new,...
                        sprintf('%d/%s',yearX,siteID),...
                        dataType);                      % Set path
filePath_old = fullfile(path_old,...
                        sprintf('%d/%s',yearX,siteID),...
                        dataType);                      % Set path
s_all_new_files = dir(filePath_old);                    % find all files in the old folder

% Create time vector (do not assume that it exists, assume 30min data)
tv = fr_round_time(datenum(yearX,1,1,0,30,0):1/48:datenum(yearX+1,1,1));
doy = tv-datenum(yearX,1,0)-8/24;

% Cycle through all files found in the OLD folder and compater with the
% files with same names in the NEW folder
allOK = false;
N = 0;
badN = 0;
for i=1:length(s_all_new_files)
    currentFile = fullfile(filePath_new,s_all_new_files(i).name);
    if ~exist(currentFile,'dir')
        N = N+1;
        x_new = read_bor(currentFile);
        currentFile_old = fullfile(filePath_old,s_all_new_files(i).name);
        x_old = read_bor(currentFile_old);
        nansInNew = isnan(x_new);
        nansInOld = isnan(x_old);
        % Test differences for:
        %   - Nans that exist in one trace but not another
        %   - Non-nan values that are not the same
        diffNans = xor(nansInNew,nansInOld);
        if any(diffNans) | ~all(x_new(~nansInNew)-x_old(~nansInNew)==0)  %#ok<*AND2>
            %---------------------
            % Differences found!
            %---------------------
            allOK = false;
            badN = badN+1;
            figure(1)
            indDiff = find(x_new - x_old ~= 0);
            plot(doy,[x_new x_old])
            hold on
            plot(doy(indDiff),x_new(indDiff),'or')
            % The above will not plot NaNs in x_new. So plot 'x' at 0 for
            % those
            x_new_isnan = find(isnan(x_new(indDiff))& ~isnan(x_old(indDiff)));
            plot(doy(indDiff(x_new_isnan)),zeros(size(indDiff(x_new_isnan))),'xr')
            hold off
            legend(['NEW data=>' path_new],['OLD data=>' path_old],'Different new points','NaNs only in NEW')
            title(sprintf('Year: %d       Trace: %s;      # of diff: %d ',yearX, s_all_new_files(i).name,length(indDiff)),'Interp','none')
            fprintf('%6d differences exist in the file: %s \n',length(indDiff), s_all_new_files(i).name);
            pause
        end
    end
end
if allOK
    fprintf('%d files checked and there are no differences\n',N);
else
    fprintf('%d files checked and there are %d files with differences\n',N,badN);
end