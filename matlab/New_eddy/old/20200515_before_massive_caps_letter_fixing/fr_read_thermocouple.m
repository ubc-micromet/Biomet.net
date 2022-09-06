function [EngUnits,Header] = fr_read_thermocouple(dateIn,configIn,instrumentNum)
% fr_read_thermocouple - reads data that is stored as two colum thermocouple data
% 
% (c) Zoran Nesic           File created:       Mar 17, 2004
%                           Last modification:  Mar 17, 2004

% Revisions

% Filenames are non-standard
fileNameDate = FR_DateToFileName(dateIn);

if isfield(configIn.Instrument(instrumentNum),'FileTag')
    fileName = [configIn.Instrument(instrumentNum).FileTag fileNameDate '.bin'];
    [fullFileName] = fr_find_data_file(dateIn,configIn,instrumentNum,fileName);
    
    if isempty(fullFileName)
        EngUnits = zeros(21.32*1800,1);
    else
        [n,EngUnits] = textread(fullFileName,'%d,%f','headerlines',1);
    end
    Header.ChanNames = {'Tc'};
    Header.ChanUnits = {'degC'};
elseif strcmp(configIn.Instrument(instrumentNum).Type,'TcOn23X')
    [fileName,dummy] = fr_find_data_file(dateIn,configIn,instrumentNum);
    if isempty(fileName)
        
        EngUnits = NaN.*zeros(configIn.Instrument(instrumentNum).Fs*1800,length(configIn.Instrument(instrumentNum).ChanNames));
        Header.ChanNames = configIn.Instrument(instrumentNum).ChanNames;
        Header.ChanUnits = configIn.Instrument(instrumentNum).ChanUnits;
    else
        [EngUnits,Header] = fr_read_Digital2_file(fileName);
    end
else
    fileName = ['TC' FR_DateToFileName(dateIn) '.bin'];
    [fullFileName] = fr_find_data_file(dateIn,configIn,instrumentNum,fileName);
    if isempty(fullFileName)
        EngUnits = zeros(21.32*1800,1);
    else
        [n,EngUnits] = textread(fullFileName,'%d,%f','headerlines',1);
    end
    Header.ChanNames = {'Tc'};
    Header.ChanUnits = {'degC'};
end


% EngUnits(:,1) = filtfilt(fir1(200,0.2),1,EngUnits(:,1));

