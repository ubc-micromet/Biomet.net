% Correct the file lengths 
% 
% In Jan 2023 there was a bug that created extra entries 
%  and appended them to db files for DSM and BB2 MET folder.
% Zoran used this script to correct the bad data files
% after they were found by search_for_bad_files.m


% folder with the bad files
yearIn = 2021;
siteID = 'BB2';
dataType = 'MET';

pathIn = fullfile(biomet_database_default,num2str(yearIn),siteID,dataType,'*');
s=dir(pathIn);
tv = fr_round_time(datenum(yearIn,1,1,0,30,0):1/48:datenum(yearIn+1,1,1,0,0,0));
correctFileSize = length(tv)*4;

for cntFile = 1:length(s)
    if ~s(cntFile).isdir && ...
       ~strcmpi(s(cntFile).name,'clean_tv') && ...
       ~strcmpi(s(cntFile).name,'TimeVector') && ...
       ~strcmpi(s(cntFile).name,'.DS_Store') && ...
       ~strcmpi(s(cntFile).name,'.Rhistory')
       
        x = read_bor(fullfile(s(cntFile).folder,s(cntFile).name));
        fprintf('%2d %10d %s',cntFile,length(x),s(cntFile).name);
        if length(x) ~= correctFileSize/4
%             figure(1)
%             plot(x)
%             title(s(cntFile).name)
%             pause     
            x = x(1:correctFileSize/4);
            save_bor(fullfile(s(cntFile).folder,s(cntFile).name),[],x);
            fprintf('File shortened to: %d\n',length(x));
        else
            fprintf('\n');
        end
    end
end