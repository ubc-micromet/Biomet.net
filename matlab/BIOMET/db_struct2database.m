function [structIn,dbFileNames, dbFieldNames,errCode] = db_struct2database(structIn,pthOut,verbose_flag,excludeSubStructures,timeUnit,missingPointValue)
%
% eg. k = db_new_eddy('\\annex001\database\2000\cr\flux\raw\',
%                             '0001*.hp.mat','\\annex001\database\2000\cr\flux\');
%       would update the data base using all Jan 2000 files
%
%   This function updates eddy correlation (PC based) data base files.
%   It reads data from hhour files stored in the pthIn directory and
%   updates data base located in pthOut
%
%   If argument Arg1 is any structure with a field Arg1().TimeVector it
%   will be stored too as a set of data base files

%
% Inputs:
%       arg1        -   raw data path (*.mat files) or an actual data
%                       structure
%       wildcard    -   '*.hp.mat' or '*.hc.mat'
%       pthOut      -   data base location for the output data
%       verbose_flag - 1 -ON, otherwise OFF
%       excludeSubStructures - cell array or a string with names or a name
%       of the substructure within Stats or HHour that should not be
%       processed.  Setting excludeSubStructures to 'DataHF' will remove
%       the high frequency data from the ACS data set.
%       timeUnit    - minutes in the sample period (spacing between two
%                     consecutive data points. Default 30 (hhour)
% Outputs:
%       k           -   number of files processed
%
% (c) Zoran Nesic               File created:       Sep 28, 2023
%                               Last modification:  Nov 16, 2023

% Revisions:
% Nov 16, 2023 (Zoran)
%  - The previous bug "fix" wasn't complete. There were multiple issues
%    but the main one was that the program didn't properly handle 
%    cases with 8 byte storage (tv vectors) and 4 byte storage (data)
% Nov 10, 2023 (Zoran)
%  - Fixed a bug that crashed the processing if a new chamber was added
%    to the set. In that case the missing data (the data for that chamber
%    before it was introduced to the set) was not initiated properly. The fix assures
%    that the missing values are initiated as NaNs.
% Oct 4, 2023 (Zoran)
%  - added errCode as an output

    
    arg_default('verbose_flag',1);              % default 1 (ON)
    arg_default('excludeSubStructures',[]);     % default exclude none
    arg_default('timeUnit',30);                 % default is 30 minutes
    arg_default('missingPointValue',0);         % default is 0 (legacy Biomet value). Newer setups should use NaN
    
    pth_tmp = fr_valid_path_name(pthOut);          % check the path and create
    if isempty(pth_tmp)
        fprintf(1,'Directory %s does not exist!... ',pthOut);
        fprintf(1,'Creating new folder!... ');
        indDrive = find(pthOut == filesep);
        [successFlag] = mkdir(pthOut(1:indDrive(1)),pthOut(indDrive(1)+1:end));
        if successFlag
            fprintf(1,'New folder created!\n');
        else
            fprintf(1,'Error creating folder!\n');
            error('Error creating folder!');
        end
    else
        pthOut = pth_tmp;
    end
    
    % Remove any topmost fields that don't need to be converted to the data
    % base format:
    if ~isempty(excludeSubStructures)
        structIn = rmfield(structIn,excludeSubStructures);
    end
    
    %%
    % extract the time vector and round it to the nearest timeUnit
    %
    tic;
    new_tv = fr_round_time(get_stats_field_fast(structIn,'TimeVector'),timeUnit,1);
    %
    % Keep only tv that are numbers
    ind_finite = find(isfinite(new_tv));
    structIn = structIn(ind_finite);
    new_tv = new_tv(ind_finite);
    %
    % Remove all tv==0 values
    ind_not_zeros = find(new_tv~=0);
    structIn = structIn(ind_not_zeros);
    new_tv = new_tv(ind_not_zeros);
    
    % Make sure there are no duplicate entries.
    [new_tv,IA]=unique(new_tv);
    structIn = structIn(IA);
    
    % Sort the time vector and the structure
    [new_tv,ind] = sort(new_tv);
    structIn = structIn(ind);
    
    %%
    % - Make the function work for multiple years
    % - the function should work on sparse data (ONLY?!)
    %   (sparse data sets are sets that contain very few points
    %    measured with different sampling frequencies)
    %   That means:
    %     - time vector should be rounded to the nearest timeUnit
    %     - load the current content of the db folder
    %     - find where the new data fits in the existing traces
    %     - store the combined traces
    
    allYears = unique(year(new_tv));
    for currentYear = allYears
        % Load up the current timeVector if it exists
        tvFileName= fullfile(pthOut,'TimeVector');
        if exist(tvFileName,"file")
            currentTv = read_bor(tvFileName,8);
        else
            currentTv = [];
        end
     
        %--------------------------------------------------------------------------------
        % Find all field names in the structIn
        % (search recursivly for all field names)
        %--------------------------------------------------------------------------------
        dbFileNamesTmp = [];
        for cntStruct = 1:length(structIn)
            dbFileNamesTmp = unique([dbFileNamesTmp recursiveStrucFieldNames(structIn,cntStruct)]);
        end
        % Remove the cells that do not contain data
        % If there is a field .LR1 that also exists in .LR1.(another_field)
        % than .LR1 does not contain data (it contains cells) and it should be
        % ignored.
        delFields = [];
        cntDelFields = 0;
        for cntFields = 1:length(dbFileNamesTmp)
            currentField = [char(dbFileNamesTmp(cntFields)) '.'];
            for cntOtherFields = cntFields+1:length(dbFileNamesTmp)
                % if the currentField exists as a start of any other field
                % that means that it does not contain data. Erase
                if strfind(char(dbFileNamesTmp(cntOtherFields)),currentField)==1
                    cntDelFields = cntDelFields + 1;
                    delFields(cntDelFields) = cntFields;
                    break
                end
            end
        end
        % Erase selected names
        if cntFields > 0
            dbFileNamesTmp(delFields) = [];
        end
        nFiles = length(dbFileNamesTmp);
        dbFileNames = [];
        dbFieldNames = [];
        for i=1:nFiles
            % create file and field names
            fieldName = char(dbFileNamesTmp(i));
            [fileNameX] = replaceControlCodes(fieldName);
            dbFileNames{i}=fullfile(pthOut,fileNameX);
            dbFieldNames{i} = fieldName; %#ok<*AGROW>
        end
        % Save the data
        errCode = saveAll(structIn,dbFileNames,dbFieldNames,currentTv,new_tv,missingPointValue);
        % report time
        tm = toc;
        if errCode ~= 0
            fprintf('     ***  %d errors during processing. ***\n',errCode);
        else
            if verbose_flag,fprintf('     %i database entries generated in %4.1f seconds.\n',length(structIn), tm);end
        end
        
    end % cntYear


%===============================================================
%
% Save all files
%
%===============================================================
function errCode = saveAll(statsNew,fileNamesIn,fieldNamesIn,currentTv,inputTv,missingPointValue)
    try
        errCode = 0;
        % extract output path (pathOut) from fileNamesIn.
        strTemp = char(fileNamesIn(1));
        indSep = strfind(strTemp,filesep);
        pathOut = strTemp(1:indSep(end)-1); 
    
        % combine the two time vectors
        newTv = union(currentTv,inputTv);
        % find where new data (newDataInd) and old data (oldDataInd) fits in the newTv
        [~,newDataInd] = intersect(newTv,inputTv);
        [~,oldDataInd] = intersect(newTv,currentTv);
    
        %-------------------------------------------------------
        % First go through all the 
        % fields in the new data (fileNamesIn) and update them.
        % Warning: This will leave some database files that were
        %          not in the new data structure untouched.
        %          They are going to need to be updated too.
        %          
        for i=1:length(fileNamesIn)
            fileName = char(fileNamesIn(i));
            fieldName = char(fieldNamesIn(i));
            try
                dataIn = get_stats_field_fast(statsNew,fieldName);
                if ~isempty(dataIn)
                    if ~exist(fileName,'file')
                        % if the file doesn't exist
                        % create it (dbase initialization)
                        % special handling of TimeVector:
                        %   - it's double precision
                        %   - it's unique (if it doesn't exist than the database does not exist)
                        % If any of the other file names do not exist a special handling is needed
                        % because that means that a new chamber has been added to the set and that
                        % chamber needs to be aligned in time with the previous chambers. That means that
                        % the trace has to get the NaN-s for all the samples before its first measurement 
                        % happened.
                        if contains(fileName,'TimeVector')
                            save_bor(fileName,8,newTv);
                        else
                            % this chamber (fileName) was added to the set of measurements
                            % after the database was already initated. Find where the new data fits
                            % and initiate this database file properly
                            dataOut = missingPointValue * ones(size(newTv));
                            if ~isempty(newDataInd)
                                dataOut(newDataInd) = dataIn;
                            end                    
                            if contains(fileName,'RecalcTime')  || contains(fileName,'sample_tv')
                                save_bor(fileName,8,dataOut);
                            else
                                save_bor(fileName,1,dataOut);
                            end
                        end
                    else
                        % if file already exist open it up
                        % Remeber that it's aligned to currentTv
                        % add the new data in
                        % save it back
        
                        if contains(fileName,'RecalcTime') ...
                                || contains(fileName,'TimeVector') ...
                                || contains(fileName,'sample_tv')
                            oldTrace = read_bor(fileName,8);
                        else                    
                            oldTrace = read_bor(fileName);
                        end % findstr(fileName,'RecalcTime')
                        % combine new with old data
                        dataOut = missingPointValue * ones(size(newTv));
                        if ~isempty(oldDataInd)
                            dataOut(oldDataInd) = oldTrace;
                        end
                        if ~isempty(newDataInd)
                            dataOut(newDataInd) = dataIn;
                        end
                        % Save the new combined trace
                        if contains(fileName,'RecalcTime') ...
                                || contains(fileName,'TimeVector') ...
                                || contains(fileName,'sample_tv')
                            save_bor(fileName,8,dataOut);
                        else
                            save_bor(fileName,1,dataOut);
                        end
                       
                    end % ~exist(fileName,'file')
                end % ~isempty(dataIn)
            catch
                disp(['Error while processing: ' fieldName]);
                errCode = errCode + 1;
            end %try
        end % i=1:length(fileNamesIn)
        
        % Some functions expect clean_tv
        % create one by simply copying TimeVector to clean_tv
        try
            copyfile(fullfile(pathOut,'TimeVector'),fullfile(pathOut,'clean_tv'))
        catch
        end
        %end % of function
    
        %-------------------------------------------------------
        % At this point it's possible to have some database files
        % that were not updated (were not incremented in size) because
        % those chambers were not sampled (the field names are not existant)
        % in the current data set (statsNew)
        % Deal with them here:
    
        % Gather all file names in the database folder 
        allFiles = dir(pathOut);
        for cntAllFiles=1:length(allFiles)
            fileName = fullfile(allFiles(cntAllFiles).folder,allFiles(cntAllFiles).name);
            if ~allFiles(cntAllFiles).isdir ...
               && ~strcmpi(allFiles(cntAllFiles).name,'TimeVector') ...
               && ~contains(allFiles(cntAllFiles).name,'.mat','IgnoreCase',true) ...
               && ~strcmpi(allFiles(cntAllFiles).name,'clean_tv')
                foundFile = false;                      % Default: the file does not exist in fileNamesIn  
                % search for fileName in fileNamesIn
                for cntAllFields = 1:length(fileNamesIn)
                    newFileName = char(fileNamesIn(cntAllFields));
                    if strcmpi(fileName,newFileName)
                        % file found. Set the flag to true and exit
                        foundFile = true;
                        break
                    end
                end
                
                if ~foundFile
                    % if the fileName wasn't found in fileNamesIn
                    % it needs to be updated by adding missingPointValue to it.
                    % Start by loading the file up                  
                    if contains(fileName,'RecalcTime') ...
                            || contains(fileName,'TimeVector') ...
                            || contains(fileName,'sample_tv')
                        oldTrace = read_bor(fileName,8);
                    else
                        oldTrace = read_bor(fileName);
                    end                           
                    % combine new with the old data
                    dataOut = missingPointValue * ones(size(newTv));
                    if ~isempty(oldDataInd)
                        dataOut(oldDataInd) = oldTrace;
                    end
                    % Save the new combined trace
                    if contains(fileName,'RecalcTime') ...
                            || contains(fileName,'TimeVector') ...
                            || contains(fileName,'sample_tv')
                        save_bor(fileName,8,dataOut);
                    else
                        save_bor(fileName,1,dataOut);
                    end                    
                end
            end
        end
    catch ME
        disp(ME);
        error('\n\nUnhandled error in db_struct2database.m\n')
    end
      



%===============================================================
%
% replace control codes
%
%===============================================================

function [fileName] = replaceControlCodes(oldName)
% replace all the brackets and commas using the following table
% '('  -> '_'
% ','  -> '_'
% ')'  -> []
% '__' -> '.'
ind = strfind(oldName,'__' );
if length(ind)==1   % the special code of '__' works only if there is only one in the name
    oldName = [oldName(1:ind-1) '.' oldName(ind+2:end)];
end
ind = find(oldName == '(' | oldName == ',');
oldName(ind) = '_'; %#ok<*FNDSB>
ind = find(oldName == ')');
oldName(ind) = [];
fileName = oldName;

%end % of function


%===============================================================
%
% Load an existing database file into a structure
%
%===============================================================
function StatsOld = database2struct(pathIn)
    allFiles = dir(pathIn);
    StatsOld = struct([]);
    
    tvFileName = fullfile(pathIn,'TimeVector'); 
    if exist(tvFileName,'file')
        tvOld = read_bor(tvFileName,8); 
    else
        error('No TimeVector in %s\n',pathIn);
    end
    for cntSamples=1:length(tvOld)
        StatsOld(cntSamples).TimeVector = tvOld(cntSamples);
    end
    k=0;
    for cntFiles=1:length(allFiles)
        fileName = allFiles(cntFiles).name;
        fileNameParts = split(fileName,'.');
        if ~contains(fileName,'mat','IgnoreCase',true) && ... 
                ~strcmpi(fileName,'clean_tv') && ...
                ~strcmpi(fileName,'TimeVector') && ...
                ~allFiles(cntFiles).isdir
            if contains(fileName,'sample_tv','IgnoreCase',true)
                oldData = read_bor(fullfile(pathIn,fileName),8);
            else
                oldData = read_bor(fullfile(pathIn,fileName));
            end
            if length(oldData) ~= length(tvOld)
                fprintf('%s has wrong length: %d ~= %d\n',fileName,length(oldData),length(tvOld));
                k=k+1;
            end
            for cntSamples=1:length(oldData)
                StatsOld(cntSamples).(char(fileNameParts{1})).(char(fileNameParts{2})) = oldData(cntSamples);
            end
        else
            %fprintf('Skipping %s\n',fileName);
        end
    end


%===============================================================
%
% Recursive structure field name search
%
%===============================================================

function dbFileNames = recursiveStrucFieldNames(StatsAll,n_template)
arg_default('n_template',1);
dbFileNames = [];
nFiles = 0;
statsFieldNames = fieldnames(StatsAll);
for i = 1:length(statsFieldNames)
    fName = char(statsFieldNames(i));
    % load the first element of StatsAll to
    % examine the structure type
    fieldTmp = getfield(StatsAll,{n_template},fName);
    % skip fields 'Configuration', 'Spectra' and all character and cell fields
    if ~strcmp(fName,'Configuration') & ~ischar(fieldTmp) & ~iscell(fieldTmp) & ~strcmp(fName,'Spectra')
        % is it a vector or not
        nLen = length(fieldTmp);
        if nLen > 1
            [nCol, nRow] = size(fieldTmp);
            for j = 1:nCol
                for j1 = 1:nRow
                    nFiles = nFiles + 1;
                    if nCol == 1 | nRow == 1
                        % if it's a one dimensional vector use only one index
                        jj = max(j,j1);
                        dbFileNames{nFiles} = [fName '(' num2str(jj) ')' ];
                    else
                        % for two dimensional vectors use two
                        dbFileNames{nFiles} = [fName '(' num2str(j) ',' num2str(j1) ')' ];
                    end % if nCol == 1 or nRow == 1
                    % test if it's a structure and do a recursive call
                    if isstruct(fieldTmp)
                        %-------------------------
                        % recursive call goes here
                        %-------------------------
                        %                    fieldI = get_stats_field_fast(StatsAll,fName);
                        if nCol == 1 | nRow == 1
                            % if it's a one dimensional vector use only one index
                            jj = max(j,j1);
                            dbFileNamesTmp = recursiveStrucFieldNames(fieldTmp(jj));
                        else
                            % for two dimensional vectors use two
                            dbFileNamesTmp = recursiveStrucFieldNames(fieldTmp(j,j1));
                        end % if nCol == 1 or nRow == 1

                        mFiles = length(dbFileNamesTmp);
                        dbFileNamesBase = char(dbFileNames{nFiles});
                        % move the pointer back to overwrite the last entry
                        nFiles = nFiles - 1;
                        for k=1:mFiles
                            nFiles = nFiles + 1;
                            dbFileNames{nFiles}=[dbFileNamesBase '.' char(dbFileNamesTmp(k))];
                        end % i=1:nFiles
                    end % if isstruc(fieldTmp)
                end % for j1=1:nRow
            end % j = 1:nCol
        else
            % save new file name
            nFiles = nFiles + 1;
            dbFileNames{nFiles} = fName;
            % test if it's a structure and do a recursive call
            if isstruct(fieldTmp)
                %-------------------------
                % recursive call goes here
                %-------------------------
                %                    fieldI = get_stats_field_fast(StatsAll,fName);
                dbFileNamesTmp = recursiveStrucFieldNames(fieldTmp);
                mFiles = length(dbFileNamesTmp);
                dbFileNamesBase = char(dbFileNames{nFiles});
                % back out the index by one (over-write the last fName entry)
                nFiles = nFiles - 1;
                for k=1:mFiles
                    nFiles = nFiles + 1;
                    dbFileNames{nFiles}=[dbFileNamesBase '.' char(dbFileNamesTmp(k))];
                end % i=1:nFiles
            end % if isstruc(fieldTmp)
        end % nLen > 1
    end % fName ~= 'Configuration'
end % for i =

