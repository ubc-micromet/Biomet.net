function numFiles = copy_FirstStage_files(siteID,yearsIn,pathOut)
% backs up only raw 1st stage files used in siteID_FirstStage 
%
% Note: the source directory is biomet_path()!
%
% Zoran Nesic           File created:       May 23, 2024
%                       Last modification:  May 25, 2024

% Revisions
%
% May 25, 2024 (Zoran)
%   - Added copying of TimeVector (in addition to clean_tv).

for cntYears = 1:length(yearsIn)
    tracesIn = readIniFileDirect(yearsIn(cntYears),siteID,1);
    for cntTraces=1:length(tracesIn)
        % make sure that inputFileNames are cells so we can later loop
        % through them
        if ischar((tracesIn(cntTraces).ini.inputFileName))
            inputFileNames = {tracesIn(cntTraces).ini.inputFileName};
        else
            inputFileNames = tracesIn(cntTraces).ini.inputFileName;
        end
        for cntFileNames=1:length(inputFileNames)
            varName = char(inputFileNames{cntFileNames});
            sourcePth = biomet_path(yearsIn(cntYears),siteID,tracesIn(cntTraces).ini.measurementType);
            sourceFileName = fullfile(sourcePth,varName);
            if ~exist(sourceFileName,"file")
                fprintf(2,'File: %s does not exist.\n',sourceFileName);
            else
                % Copy the trace to pathOut
                destFileName = fullfile(pathOut,sourcePth(length(db_pth_root)+1:end),varName);
                % Make sure that the destination folder exists
                destFolder = fileparts(destFileName);                
                if ~exist(destFolder,'dir')
                    % for each file that you copy confirm that the folder 
                    % containing the file has clean_tv in it too. If not
                    % copy it.                    
                    mkdir(destFolder);
                    if exist(fullfile(fileparts(sourceFileName),'clean_tv'),'file')
                        % copy clean_tv when creating the new folder
                        [status,msg] = copyfile(fullfile(fileparts(sourceFileName),'clean_tv'),...
                                                fullfile(destFolder,'clean_tv'),'f');
                        if status==0
                            fprintf(2,'Error copying %s => %s\n',fullfile(sourcePth,'clean_tv'),...
                                                                 fullfile(destFolder,'clean_tv'));
                            fprintf(2,'%s\n',msg);
                        end                    
                    end
                    if exist(fullfile(fileparts(sourceFileName),'TimeVector'),'file')
                        % copy clean_tv when creating the new folder
                        [status,msg] = copyfile(fullfile(fileparts(sourceFileName),'TimeVector'),...
                                                fullfile(destFolder,'TimeVector'),'f');
                        if status==0
                            fprintf(2,'Error copying %s => %s\n',fullfile(sourcePth,'TimeVector'),...
                                                                 fullfile(destFolder,'TimeVector'));
                            fprintf(2,'%s\n',msg);
                        end                    
                    end  
                    % Very old loggers (YF site) could also have time vectors stored
                    % in *_tv files. Find and copy those too
                    lstTv = dir(fullfile(fileparts(sourceFileName),'*_tv'));
                    for cntTv = 1:length(lstTv)
                        if ~lstTv(cntTv).isdir
                            % copy clean_tv when creating the new folder
                            [status,msg] = copyfile(fullfile(fileparts(sourceFileName),lstTv(cntTv).name), ...
                                                   fullfile(destFolder,lstTv(cntTv).name),'f');
                            if status==0
                                fprintf(2,'Error copying %s => %s\n',fullfile(sourcePth,lstTv(cntTv).name),...
                                                                     fullfile(destFolder,lstTv(cntTv).name));
                                fprintf(2,'%s\n',msg);
                            end     
                        end
                    end
                end
                % copy file
                [status,msg] = copyfile(sourceFileName,destFileName,'f');
                if status==0
                    fprintf(2,'Error copying %s => %s\n',sourceFileName,destFileName);
                    fprintf(2,'%s\n',msg);
                end
            end           
        end
    end
end