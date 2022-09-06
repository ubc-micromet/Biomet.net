%
% This script converts all the files from dataFolderMain that are in 
% TOA5 format to BiometMat format (matlab files with EngUnits and Header
% variables).  This is used for CR1000 EC datalogger from YF site that
% was running CSAT3 and LI7500 between Aug 2017 and present on the new
% scaffold tower.
%
% The original TOA5 files are moved into subfolder .\TOA_original\yymmdd
% and binary files into .\data\yymmdd
%
dataFolderMain = 'D:\temp\YF_CR1000_EC_DATA';
dataFolderOut = fullfile(dataFolderMain,'data');
rawDataFolderOut = fullfile(dataFolderMain,'TOA_original');
fileNameWildCard = 'YF_CR1000_1_TUR.*';
fileNameExtension = '.dyTUR';
s = dir(fullfile(dataFolderMain,fileNameWildCard));
%%

i = 1; %for i=1:size(s,1)
    % load the first file and extract the time stamp
    [EngUnits,Header,tv]=fr_read_TOA5_file(fullfile(dataFolderMain,s(i).name),1,4,'NaN');
 %%   
    dateExt = s(i).name(length(fileNameWildCard)+9:end);
    YearX = str2double(dateExt(1:4));
    MonthX = str2double(dateExt(6:7));
    DayX = str2double(dateExt(9:10));    
    HourX = str2double(dateExt(12:13));    
    MinuteX = str2double(dateExt(14:15))+30;            % LoggerNet time stamps files with the start time
                                                        % We use end time.
                                                        % Add 30 minutes.
    newTimeString = datestr(fr_round_time(datenum(YearX,MonthX,DayX,HourX,MinuteX,0),'30min',2),30);
    
    QQ = num2str(str2double(newTimeString(10:11))*4 + str2double(newTimeString(12:13))/30 * 2,'%02d');
    if strcmp(QQ(end-1:end),'00')
        % for the last half hour in the day use code 96 
        % instead of 00.  Also, move the date one day back (96 belongs to
        % the previous day)
        QQ(end-1:end) = '96';
        newTimeString = datestr(datenum([newTimeString(1:4) '-' newTimeString(5:6) '-' newTimeString(7:8)])-1,30);
    end
    fileName = fullfile(dataFolderOut,newTimeString(3:8), [newTimeString(3:8) QQ fileNameExtension]);
    
    % Create .\data\yymmdd folder for the 30-minute files in BiometMat
    % format
    if isempty(dir(fullfile(dataFolderOut,newTimeString(3:8))))        
        mkdir(fullfile(dataFolderOut,newTimeString(3:8)))    
    end
    % Create .\TOA_original\yymmdd folder for raw data that has been
    % processed
    if isempty(dir(fullfile(rawDataFolderOut,newTimeString(3:8))))        
        mkdir(fullfile(rawDataFolderOut,newTimeString(3:8)))    
    end
    fprintf('%s %s %s\n',datestr(datenum(YearX,MonthX,DayX,HourX,MinuteX,0)),fileName,newTimeString)
    % Read raw data file
    [EngUnits,Header,tv] = fr_read_TOA5_file(fullfile(dataFolderMain,s(i).name),0,4,'NaN',0,30000);
    % Save the data file to .\data\yymmdd folder
    save(fileName,'EngUnits','Header');
    % Move the original TOA file into a .\TOA_original\yymmdd folder
    movefile(fullfile(dataFolderMain,s(i).name),fullfile(rawDataFolderOut,newTimeString(3:8),s(i).name))
%end
