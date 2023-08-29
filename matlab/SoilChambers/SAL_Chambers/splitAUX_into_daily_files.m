% Program to split a long TOA5 file into daily files
% Program reads and saves the header
% Then reads one line at the time and, for each day
% it stores the header and all the lines (without altering them) that belong
% to that day. 
% the file names are in the format: OriginalName.YYYYMMDD
originalPath = 'E:\Site_DATA\WL\2021_AUX_ClimateData';
targetPath = 'E:\Site_DATA\WL\2021_AUX_ClimateData\csi_net';
fileName = 'AUX_CR1000XSeries_TVC_ACAux_slow';
CRLF = [char(13) char(10)]; %#ok<CHARTEN>

tic

% Open the original file
originalFile = fullfile(originalPath,[fileName '.dat']);
fid = fopen(originalFile);
if fid < 0
    error ('Cannot open file:%s',originalFile);
end
% read and store header
headerLines = [];
for lineCnt = 1:4
    headerLines = [headerLines fgetl(fid) CRLF]; %#ok<*AGROW>
end

% Read the rest of the lines, one line at the time
% Check the timestamp for each line and save the file every time
% the end of the current day is reached. Stop when the end of file is reached

% read one line to get the first date
oneLine = fgetl(fid);
currentDate = datenum(oneLine(2:20))-0.0000001;
sFullDay = [headerLines oneLine CRLF];
fileCount = 0;
while 1
    oneLine = fgetl(fid);
    if ~ischar(oneLine)
        % no more lines. Save the current data and quit
        saveFile(targetPath,fileName,currentDate,sFullDay)
        fileCount = fileCount+1;
        break
    end
    newDate = datenum(oneLine(2:20))-0.0000001;
    if floor(newDate) == floor(currentDate)
        sFullDay = [sFullDay oneLine CRLF];
    else
        % save the current data and start a new file
        saveFile(targetPath,fileName,currentDate,sFullDay);
        fileCount = fileCount+1;
        % initate the next day's file
        currentDate = newDate;
        sFullDay = [headerLines oneLine CRLF];
    end
end    
fprintf('Created %d daily files in %6.1f seconds.\n',fileCount,toc);
fclose(fid); 
return


function saveFile(targetPath,fileName,currentDate,sFullDay)
    outputFileName = fullfile(targetPath,...
                             sprintf('%s.%s',fileName,datestr(currentDate+1,'yyyymmdd')));
    fidOut = fopen(outputFileName,'w');
    if fidOut < 0
        error('Cannot write into file: %s',outputFileName);
    end
    fprintf(fidOut,'%s', sFullDay);
    fclose(fidOut);
    fprintf('Saved: %s\n',outputFileName);
end


        