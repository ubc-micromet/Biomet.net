function [ErrorStatus] = ShellFileSplit(dailyFileName,dataPath)
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
%                           Last modification:  May  9, 2012

% Revisions
%
% May 9, 2012 (Zoran)
% - added parsing of the Weather Station data
% - added parsing of the GasFinder data
%

warning('OFF','MATLAB:MKDIR:DirectoryExists')
ErrorStatus = 0;
k=0;
numOfChannelsIRGA = 10;
numOfChannelsSonic = 5;
kmax=5000000;
tic;
fid=fopen(dailyFileName);
if fid == -1 % if file doesn't exist or can't be opened, exit with error flag set to 1
    ErrorStatus = 1;
    return
end

%IRGA parameters
numOfChannelsIRGA = 10;
oldTempTVstringIRGA = [];
currentTimeStringIRGA = [];
fileNameExtensionIRGA = '.dSQT2';
colHeaderIRGA = {'CO2', 'H2O', 'Tcell','Tin', 'Tout','Pcell','Phead', 'IRGA_diag','CoolerV','FlowRate'};

%Sonic parameters
numOfChannelsSonic = 5;
oldTempTVstringSonic = [];
currentTimeStringSonic = [];
fileNameExtensionSonic = '.dSQT1';
colHeaderSonic = {'u', 'v', 'w', 'Tsonic',  'cup3d'};

%Weather station parameters
numOfChannelsWS = 9;
oldTempTVstringWS = [];
currentTimeStringWS = [];
fileNameExtensionWS = '.dSQT3';
colHeaderWS = {'cup2d', 'Rain', 'Pair', 'Tair', 'RH', 'windDir', 'solarRad', 'windChill', 'dewPoint'};

%GasFinder data
numOfChannelsGF = 3;
oldTempTVstringGF = [];
currentTimeStringGF = [];
fileNameExtensionGF = '.dSQT4';
colHeaderGF = {'co2', 'R2', 'PathLength'};


while 1, 
    tline=fgetl(fid);
    k=k+1;
    if ~ischar(tline) || k > kmax,
        % Time to save the files and leave the loop     
        mkdir(fullfile(dataPath,newTimeStringIRGA(3:8)))
        save_data(fileNameIRGA,irgaLine,dataOutIRGA,colHeaderIRGA)
        save_data(fileNameSonic,sonicLine,dataOutSonic,colHeaderSonic)
        save_data(fileNameWS,WSLine,dataOutWS,colHeaderWS)
        save_data(fileNameGF,GFLine,dataOutGF,colHeaderGF)
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
            ErrorStatus = 1;
        end
    elseif strfind(tline,'$USDTA,') > 0
        %this is a Sonic line.  Extract time from it:
        tempTVstringSonic = tline(8:26);
        % to reduce the number of time datenum is called
        % first test if the time string has changed at all   
        if isempty(oldTempTVstringSonic) || ~strcmp(oldTempTVstringSonic(15:16),tempTVstringSonic(15:16))  
            oldTempTVstringSonic = tempTVstringSonic;
            tv = datenum(tempTVstringSonic);          % the original data does not have miliseconds.  Add one second to time to put data in the correct hhour
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
            ErrorStatus = 1;
        end
    elseif strfind(tline,'$WSDTA,') > 0
        %this is a Weather station line.  Extract time from it:
        tempTVstringWS = tline(8:26);
        % to reduce the number of time datenum is called
        % first test if the time string has changed at all   
        if isempty(oldTempTVstringWS) || ~strcmp(oldTempTVstringWS(15:16),tempTVstringWS(15:16))  
            oldTempTVstringWS = tempTVstringWS;
            tv = datenum(tempTVstringWS);          % the original data does not have miliseconds.  Add one second to time to put data in the correct hhour
            newTimeStringWS = datestr(fr_round_time(tv+1/24/60/60,'30min',2),30);
        end
        if isempty(currentTimeStringWS) 
            % first file creation.  Set all variables
            fileNameWS = make_file_name(dataPath,newTimeStringWS,fileNameExtensionWS);
            dataOutWS = zeros(36100,numOfChannelsWS);
            WSLine = 0;   % reset the line counter
            currentTimeStringWS = newTimeStringWS;   % set the currentTimeStringIRGA
        end    
        if ~strcmp(currentTimeStringWS, newTimeStringWS)
            % time to close the old file and open the new one (end of
            % half-hour)

            save_data(fileNameWS,WSLine,dataOutWS,colHeaderWS)

            % reset dataOutWS
            fileNameWS = make_file_name(dataPath,newTimeStringWS,fileNameExtensionWS);
            dataOutWS = zeros(36100,numOfChannelsWS);
            WSLine = 0;   % reset the line counter
            currentTimeStringWS = newTimeStringWS;   % set the currentTimeStringIRGA
        end
        try
            WSLine = WSLine+1;
            c = textscan(tline(49:end-1),'%f%f%f%f%f%f%f%f%f','delimiter',',');
            for i = 1:length(c)
                if isempty(c{i})
                    c{i} = NaN;
                end
            end        
            [cup2d Rain Pair Tair RH windDir solarRad windChill dewPoint]=deal(c{:});
            dataOutWS(WSLine,1:numOfChannelsWS) = [cup2d Rain Pair/10 Tair RH windDir solarRad windChill dewPoint];        
        catch
            fprintf('Error reading line %d from %s\n',k,dailyFileName);
            ErrorStatus = 1;
        end
    elseif strfind(tline,'$GFDTA,') > 0
        %this is a GasFinder line.  Extract time from it:
        % Find the time string (not at the beginning as for all other
        % lines.
        ind=find(tline == ',');
        tempTVstringGF = tline(ind(5)+[1:19]);
        % to reduce the number of time datenum is called
        % first test if the time string has changed at all   
        if isempty(oldTempTVstringGF) || ~strcmp(oldTempTVstringGF(15:16),tempTVstringGF(15:16))  
            oldTempTVstringGF = tempTVstringGF;
            tv = datenum(tempTVstringGF);          % the original data does not have miliseconds.  Add one second to time to put data in the correct hhour
            newTimeStringGF = datestr(fr_round_time(tv+1/24/60/60,'30min',2),30);
        end
        if isempty(currentTimeStringGF) 
            % first file creation.  Set all variables
            fileNameGF = make_file_name(dataPath,newTimeStringGF,fileNameExtensionGF);
            dataOutGF = zeros(36100,numOfChannelsGF);
            GFLine = 0;   % reset the line counter
            currentTimeStringGF = newTimeStringGF;   % set the currentTimeStringIRGA
        end    
        if ~strcmp(currentTimeStringGF, newTimeStringGF)
            % time to close the old file and open the new one (end of
            % half-hour)

            save_data(fileNameGF,GFLine,dataOutGF,colHeaderGF)
            
            % reset dataOutGF
            fileNameGF = make_file_name(dataPath,newTimeStringGF,fileNameExtensionGF);
            dataOutGF = zeros(36100,numOfChannelsGF);
            GFLine = 0;   % reset the line counter
            currentTimeStringGF = newTimeStringGF;   % set the currentTimeStringIRGA
        end
        try
            GFLine = GFLine+1;
            c = textscan(tline(9:end-1),'%f%f%f%f%f','delimiter',',');
            for i = 1:length(c)
                if isempty(c{i})
                    c{i} = NaN;
                end
            end        
            [co2 R2 pathLength junk junk]=deal(c{:});
            dataOutGF(GFLine,1:numOfChannelsGF) = [co2/100 R2 pathLength];        
        catch
            fprintf('Error reading line %d from %s\n',k,dailyFileName);
            ErrorStatus = 1;
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