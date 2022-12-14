function [nAllFiles,nBadFiles, s] = find_db_files_with_wrong_length(siteID,yearIn,dataType,verbose)
% Function that finds database traces that are of a wrong size
%
% Zoran Nesic               File created:       Jan 9, 2023
%                           Last modification:  Jan 9, 2023

% Revisions
%

% siteID = 'BB2';
% yearIn = 2018;
% dataType = 'MET';
arg_default('verbose',0);

pathIn = fullfile(biomet_database_default,num2str(yearIn),siteID,dataType);
tv = fr_round_time(datenum(yearIn,1,1,0,30,0):1/48:datenum(yearIn+1,1,1,0,0,0));

correctFileSize = length(tv)*4;
s=dir(pathIn);
if verbose >= 0
    fprintf('Year: %d, siteID: %s dataType: %s,Found %d files\n',yearIn,siteID,dataType,length(s));
end
nAllFiles = 0;
nBadFiles = 0;
for cntFile = 1:length(s)
    if ~s(cntFile).isdir && ...
       ~strcmpi(s(cntFile).name,'clean_tv') && ...
       ~strcmpi(s(cntFile).name,'TimeVector') && ...
       ~strcmpi(s(cntFile).name,'.DS_Store') && ...
       ~strcmpi(s(cntFile).name,'.Rhistory')
        
        %x = read_bor(fullfile(s(cntFile).folder,s(cntFile).name));
        %fprintf('%2d %10d %s',cntFile,length(x),s(cntFile).name);
        nAllFiles = nAllFiles+1;
        
        if s(cntFile).bytes ~= correctFileSize
            nBadFiles = nBadFiles+1;
            % x = x(1:17520);
            %save_bor(fullfile(s(cntFile).folder,s(cntFile).name),[],[],x);
            if verbose==1
                fprintf('%2d %10d %s',cntFile,s(cntFile).bytes/4,s(cntFile).name);
                if s(cntFile).bytes > correctFileSize
                    fprintf(' <=== too long!\n');
                else
                    fprintf(' <=== too short!\n');
                end
            end
        else
            %fprintf('\n');
        end
    end
end
if nBadFiles > 0
    fprintf('\n*** Year: %d, siteID: %s, dataType: %s. Found % d bad files out of %d files.  ***\n\n',yearIn,siteID,dataType,nBadFiles,nAllFiles);
elseif verbose >= 0
    fprintf('All files have correct size.\n');
end