function [EngUnits,Header] = fr_read_met(dateIn,configIn,instrumentNum)
% [EngUnits,Header] = fr_read_met(dateIn,configIn,instrumentNum) 
%             - reads  data for CR site
%
% Inputs:
%   dateIn      - datenum (this is not a vector, only one file is read at the time)
%   configIn    - standard UBC ini file
%   instrumentNum - instrument number (see the ini file)
%
% Outputs:
%   EngUnits    - data matrix if file exists, empty if file is missing [tv HMP_T Pair]
%
%
% (c) kai*           File created:       Apr 22, 2005
%                    Last modification:  Apr 22, 2005

% Revisions
%

dateFile = dateIn;
% dateFile = floor(dateIn - 1.25/24)+1/24;
% File conventions: 
% current day contains data from 1:30 AM to 1:00 AM
% files for floor(now-gmt_shift) has extension .dat otherwise *.DOY

% This is a temporary fix so we do not bother checking here
% fileName = [configIn.Instrument(instrumentNum).FileID,'.dat'];
% 
% [fullFileName,dummy] = fr_find_data_file(dateFile,configIn,instrumentNum,fileName);
% if isempty(fullFileName)
%     error(['File: ' dummy ' does not exist!'])
% end

fileName = [configIn.Instrument(instrumentNum).FileID,'.*'];
fullFileName = fullfile(configIn.database_path,fileName);
%commandStr = sprintf('[tv,EngUnits] = fr_read_csi(''%s'',''[]'',[
%[tv,EngUnits] = fr_read_csi(fullFileName,dateIn,configIn.Instrument(instrumentNum).ChanNumbers, ...
%                    configIn.Instrument(instrumentNum).TableID);

climateDataReadBy_FR_read_csi = evalin('base','climateDataReadBy_FR_read_csi','[]');

if isempty(climateDataReadBy_FR_read_csi)
%    evalin('base','[climateDataReadBy_FR_read_csi_tv, climateDataReadBy_FR_read_csi] = fr_read_csi(''d:\sites\cr\csi_net\fr_clim1.*'','''',[1:5],105);')
    cmdStr = sprintf('wildCard = ''%s'';',fullFileName);
    evalin('base',cmdStr)
%     cmdStr = ['dateIn = ['];
%     for i=1:length(dateIn)
%         cmdStr = [cmdStr sprintf('%s ',dateIn(i))];
%     end
%     cmdStr = [cmdStr ']'';'];
%     evalin('base',cmdStr)

    cmdStr = ['chanInd = ['];
    for i=1:length(configIn.Instrument(instrumentNum).ChanNumbers)
        cmdStr = [cmdStr sprintf('%d ',configIn.Instrument(instrumentNum).ChanNumbers(i))];
    end
    cmdStr = [cmdStr ']'';'];
    evalin('base',cmdStr)

    evalin('base',sprintf('tableID = %d;',configIn.Instrument(instrumentNum).TableID))

    evalin('base','[climateDataReadBy_FR_read_csi_tv, climateDataReadBy_FR_read_csi] = fr_read_csi(wildCard,[],chanInd,tableID);')
end

EngUnits = evalin('base','climateDataReadBy_FR_read_csi','[]');
tv = evalin('base','climateDataReadBy_FR_read_csi_tv','[]');

EngUnits = EngUnits(find(dateIn == tv),:);


[Header] = [];


return
    
