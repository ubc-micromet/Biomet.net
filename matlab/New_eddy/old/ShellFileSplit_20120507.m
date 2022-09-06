function ShellFileSplit(dailyFileName,dataPath)
% ShellFileSplit - splits ShellQuest daily file into 30-minute IRGA and 30-minute Sonic files
%
% Files are storred into daily subfolders (YYMMDD) under "dataPath" folder.
%
%
% Usage:
%    ShellFileSplit('d:\ShellQuest\RawData\ShellQuest_20120430.csv','d:\met-data\data\')
%
% Inputs:
%   dailyFileName   - full path to ShellQuest csv daily file
%   dataPath        - root path to HF data folder (usually d:\met-data\data)
%
% Outputs:
%   none
%
%
% (c) Zoran Nesic           File created:       May  2, 2012
%                           Last modification:  May  2, 2012

% Revisions
%

warning('OFF','MATLAB:MKDIR:DirectoryExists')
k=0;
numOfChannelsIRGA = 10;
numOfChannelsSonic = 5;
%irgaLine = 0;
kmax=5000000;
tic;
fid=fopen(dailyFileName);
oldTempTVstringIRGA = [];
currentTimeStringIRGA = [];
fileNameExtensionIRGA = '.dSQT2';
oldTempTVstringSonic = [];
currentTimeStringSonic = [];
fileNameExtensionSonic = '.dSQT1';
colHeaderIRGA = {'CO2', 'H2O', 'Tcell','Tin', 'Tout','Pcell','Phead', 'IRGA_diag','CoolerV','FlowRate'};
colHeaderSonic = {'u', 'v', 'w', 'Tsonic',  'cup3d'};
while 1, 
    tline=fgetl(fid);
    k=k+1;
    if ~ischar(tline) || k > kmax,
        % Time to save the files and leave the loop     
        mkdir(fullfile(dataPath,newTimeStringIRGA(3:8)))
        save_data(fileNameIRGA,irgaLine,dataOutIRGA,colHeaderIRGA)
        save_data(fileNameSonic,sonicLine,dataOutSonic,colHeaderSonic)
        fprintf('Extracted in %6.2f seconds.\n',toc)
        break,
    end
    % Find if it's IRGA file
    % Check for the marker: $LCDTA
    if strfind(tline,'$LCDTA,') > 0
        %this is an IRGA line.  Extract time from it:
        tempTVstringIRGA = tline(8:26);
        % to reduce the number of time datenum is called
        % first test if the time string has changed at all
        % compare *minutes* only
        if isempty(oldTempTVstringIRGA) || ~strcmp(oldTempTVstringIRGA(15:16),tempTVstringIRGA(15:16))
            oldTempTVstringIRGA = tempTVstringIRGA;
            tv = datenum(tempTVstringIRGA);          % the original data does not have miliseconds.  Add one second to time to put data in the correct hhour 
            newTimeStringIRGA = datestr(fr_round_time(tv+1/24/60/60,'30min',2),30);
        end
        if isempty(currentTimeStringIRGA) 
            % first file creation.  Set all variables
            fileNameIRGA = make_file_name(dataPath,newTimeStringIRGA,fileNameExtensionIRGA);
            dataOutIRGA = zeros(36100,numOfChannelsIRGA);
            irgaLine = 0;   % reset the line counter
            currentTimeStringIRGA = newTimeStringIRGA;   % set the currentTimeStringIRGA
        end    
        if ~strcmp(currentTimeStringIRGA, newTimeStringIRGA)
            % time to close the old file and open the new one (end of
            % half-hour)
            save_data(fileNameIRGA,irgaLine,dataOutIRGA,colHeaderIRGA)
            % reset dataOutIRGA
            dataOutIRGA = zeros(36100,numOfChannelsIRGA);
            fileNameIRGA = make_file_name(dataPath,newTimeStringIRGA,fileNameExtensionIRGA);
            irgaLine = 0;   % reset the line counter
            currentTimeStringIRGA = newTimeStringIRGA;   % set the currentTimeStringIRGA
        end
        try
            irgaLine = irgaLine+1;
            c = textscan(tline(28:end-1),'%f%f%f%f%f%f%f%f%f%f','delimiter',',');
            for i = 1:length(c)
                if isempty(c{i})
                    c{i} = NaN;
                end
            end
            [IRGA_diag,Pcell,Phead, CoolerV, CO2, H2O, Tcell,Tin, Tout, FlowRate]=deal(c{:});
            dataOutIRGA(irgaLine,1:numOfChannelsIRGA) = [ CO2, H2O, Tcell,Tin, Tout,Pcell,Phead, IRGA_diag,CoolerV,FlowRate];
        catch
            fprintf('Error reading line %d from %s\n',k,dailyFileName);
        end
    elseif strfind(tline,'$USDTA,') > 0
        %this is a Sonic line.  Extract time from it:
        tempTVstringSonic = tline(8:26);
        % to reduce the number of time datenum is called
        % first test if the time string has changed at all   
        if isempty(oldTempTVstringSonic) || ~strcmp(oldTempTVstringSonic(15:16),tempTVstringSonic(15:16))  
            oldTempTVstringSonic = tempTVstringSonic;
            tv = datenum(tline(8:26));          % the original data does not have miliseconds.  Add one second to time to put data in the correct hhour
            newTimeStringSonic = datestr(fr_round_time(tv+1/24/60/60,'30min',2),30);
        end
        if isempty(currentTimeStringSonic) 
            % first file creation.  Set all variables
            fileNameSonic = make_file_name(dataPath,newTimeStringSonic,fileNameExtensionSonic);
            dataOutSonic = zeros(36100,numOfChannelsSonic);
            sonicLine = 0;   % reset the line counter
            currentTimeStringSonic = newTimeStringSonic;   % set the currentTimeStringIRGA
        end    
        if ~strcmp(currentTimeStringSonic, newTimeStringSonic)
            % time to close the old file and open the new one (end of
            % half-hour)

            save_data(fileNameSonic,sonicLine,dataOutSonic,colHeaderSonic)
            fprintf('Extracted in %6.2f seconds.\n',toc)
            tic
            % reset dataOutSonic
            fileNameSonic = make_file_name(dataPath,newTimeStringSonic,fileNameExtensionSonic);
            dataOutSonic = zeros(36100,numOfChannelsSonic);
            sonicLine = 0;   % reset the line counter
            currentTimeStringSonic = newTimeStringSonic;   % set the currentTimeStringIRGA
        end
        try
            sonicLine = sonicLine+1;
            c = textscan(tline(28:end-1),'%f%f%f%f%f','delimiter',',');
            for i = 1:length(c)
                if isempty(c{i})
                    c{i} = NaN;
                end
            end        
            [u v w cup3d Tsonic]=deal(c{:});
            dataOutSonic(sonicLine,1:numOfChannelsSonic) = [u v w Tsonic  cup3d];        
        catch
            fprintf('Error reading line %d from %s\n',k,dailyFileName);
        end
    end    
end;
fclose('all');

warning('ON','MATLAB:MKDIR:DirectoryExists')
end

function fileName = make_file_name(dataPath,fileString,fileNameExtension)

    QQ = num2str(str2double(fileString(10:11))*4 + str2double(fileString(12:13))/30 * 2,'%02d');
    if strcmp(QQ(end-1:end),'00')
        % for the last half hour in the day use code 96 
        % instead of 00.  Also, move the date one day back (96 belongs to
        % the previous day)
        QQ(end-1:end) = '96';
        fileString = datestr(datenum([fileString(1:4) '-' fileString(5:6) '-' fileString(7:8)])-1,30);
    end
    mkdir(fullfile(dataPath,fileString(3:8)))
    fileName = fullfile(dataPath,fileString(3:8), [fileString(3:8) QQ fileNameExtension]);
end

function save_data(fileName,totalLines,EngUnits,Header) %#ok<INUSD>
    EngUnits = EngUnits(1:totalLines,:);
    save(fileName,'EngUnits','Header');
    fprintf('Saved: %s (%d lines)\n',fileName,totalLines)        
end        