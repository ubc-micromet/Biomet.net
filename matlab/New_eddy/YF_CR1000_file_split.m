function YF_CR1000_file_split(srcFilePath,baseOutputPath, fileWildcard,outputFileExt)
%
% It splits daily CR1000 files collected at YF site using Geography EC
% system consisting of CSAT3 and LI7500, into hhourly files. The files are
% separated into daily folders (YYMMDD) and stored in BiometMat format (can
% be read with fr_read_BiometMat.m function). Currently this kind of data
% has been collected only between Aug 2017 and May 2018.  
%
% Example: YF_CR1000_file_split('e:\junk\YF_CR1000_EC_DATA\','e:\junk\YF_CR1000_EC_DATA\Met-data\', 'YF_CR1000_1_TUR.*','.dy111')
%
%
% (c) Zoran Nesic               Last modification:  Jan 25, 2019
%
%

%srcFilePath        = 'e:\junk\YF_CR1000_EC_DATA\';
%fileWildcard       = 'YF_CR1000_1_TUR.*';
%baseOutputPath     = 'e:\junk\YF_CR1000_EC_DATA\';
%outputFileExt       = '.dy111';

if ~exist(fullfile(baseOutputPath,'data'),'dir')
    mkdir (baseOutputPath,'data');
end
fileOutputPath     = fullfile(baseOutputPath,'data');

if ~exist(fullfile(baseOutputPath,'processedTOA5files'),'dir')
    mkdir (baseOutputPath,'processedTOA5files');
end
processedFilesPath = fullfile(baseOutputPath,'processedTOA5files');

firstTime = 1;

s=dir(fullfile(srcFilePath,fileWildcard));
numOfFiles = length(s);
fprintf('The number of files to process: %d\n',numOfFiles);

for k=1:length(s)
    if ~strcmpi(s(k).name(end-2:end),'dat')
        try
            currentFile        = s(k).name;
            fileName           = fullfile(srcFilePath,currentFile);
            fprintf('Processing file: %s (%d of %d)\n',fileName,k,numOfFiles);
            totalLines = 0;
            filesSaved = 0;

            % first just read the header and store it for future use
            % (it will be added to each of the children files)
            [junk,Header,tv] = fr_read_TOA5_file(fileName,1,4,'NaN',[],[],4); %#ok<NASGU>
            N=size(junk,2);
            %%
            % The file has N variables and a time stamp:

            fileFormat = '%q';
            for i=1:N
                fileFormat= [fileFormat ' %f'];
            end
            %%
            fid = fopen(fileName,'r');

            % Skip the header lines (4)
            for i=1:4
                currentLine = fgets(fid); %#ok<NASGU>
            end

            % line counter for the current file
            outputLineCounter = 0;

            % repeat the loop until the end of the input file is reached
            tic;
            timeStart = now;
            while 1

                % Read 1000 lines at one time and then go one line at the time to
                % figure out where the 30-minute breaks are.  I did it first one line
                % at the time using fgets() but that ran at 20s/30min file
                % The actual speed improvement was in the fr_DateToFileName
                dataTemp = textscan(fid,fileFormat,1000,'delimiter',',');
                dataTempMatrix = [];
                if isempty(dataTemp{1})
                    % the end of the file is reached
                    % quit the while loop
                    break
                end
                for i=1:N
                    dataTempMatrix(:,i) = dataTemp{i+1};
                end
                tv_char = char(dataTemp{1});
                tv = datenum(tv_char);
                %     tv = datenum(str2num(tv_char(:,1:4)),str2num(tv_char(:,6:7)),str2num(tv_char(:,9:10)),...
                %         str2num(tv_char(:,12:13)),str2num(tv_char(:,15:16)),str2num(tv_char(:,18:end)));
                fileNamesArray = fr_DateToFileName(fr_round_time(tv,[],2));

                % now go one line at the time
                for counter = 1:size(tv,1)
                    % find out if this line belongs to a new file or to the current file
                    % On the first run, initiate the file name
                    if firstTime == 1
                        oldFileName = fileNamesArray(counter,:);
                        firstTime =0;
                    end
                    %%
                    % the new line should go into this file:
                    currentFileName = fileNamesArray(counter,:);

                    % if the current line belongs to the new file then
                    % save old file and reset the EngUnits
                    if ~strcmp(oldFileName,currentFileName)
                        % save file now
                        filesSaved = filesSaved + 1;
                        fprintf('Saving file #%d: %s (%d lines processed in %d seconds)\n', filesSaved,oldFileName, outputLineCounter, round(toc));
                        if ~exist(fullfile(fileOutputPath,oldFileName(1:6)),'dir')
                            mkdir (fileOutputPath,oldFileName(1:6));
                        end
                        save(fullfile(fileOutputPath,oldFileName(1:6),[oldFileName outputFileExt]),'EngUnits','Header');
                        oldFileName = currentFileName;
                        outputLineCounter = 0;
                        EngUnits = [];
                        tic
                    end

                    % Add new line to EngUnits
                    outputLineCounter = outputLineCounter + 1;
                    totalLines = totalLines + 1;

                    % replace record number with time info (could be useful for future
                    % resampling
                    EngUnits(outputLineCounter,1) = tv(counter); %#ok<*AGROW>
                    for i=2:N
                        EngUnits(outputLineCounter,i) = dataTempMatrix(counter,i);
                    end % i
                end % counter

            end % while

            % if there is still data in EngUnits save it into oldFileName
            if outputLineCounter > 0
                save(fullfile(fileOutputPath,[oldFileName outputFileExt] ),'EngUnits','Header');
                filesSaved = filesSaved + 1;
                fprintf('Saving file #%d: %s (%d lines processed in %d seconds)\n', filesSaved,oldFileName, outputLineCounter, round(toc));
            end

            fclose(fid);
            fprintf('Saved total of %d files.\n',filesSaved);
            fprintf('Total lines processed: %d in %s \n',totalLines, datestr(now-timeStart,13));

            % now move the file into the "processed_files" folder
            movefile(fileName,fullfile(processedFilesPath,currentFile))
        catch %#ok<CTCH>
            fclose all;
            fprintf('***Error while processing file: %s (%d of %d)\n',fileName,k,numOfFiles);
        end
    else
        fprintf('Skipping file: %s\n',s(k).name);
    end %~strcmpi
end %k




