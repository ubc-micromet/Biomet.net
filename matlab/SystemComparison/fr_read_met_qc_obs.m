function [EngUnits,Header] = fr_read_met_on_epl(dateIn,configIn,instrumentNum)
% fr_read_met_on_epl - reads met data for ON_EPL site
% 
%
% Inputs:
%   dateIn      - datenum (this is not a vector, only one file is read at the time)
%   configIn    - standard UBC ini file
%   systemNum   - system number (see the ini file)
%   instrumentNum - instrument number (see the ini file)
%
% Outputs:
%   EngUnits    - data matrix if file exists, empty if file is missing [tv HMP_T Pair]
%
%
% (c) Zoran Nesic           File created:       July 6, 2004
%                           Last modification:  July 6, 2004

% Revisions
%
if isfield(configIn,'gmt_to_local')
    dateIn = dateIn+configIn.gmt_to_local;
end

dateFile = dateIn;
% dateFile = floor(dateIn - 1.25/24)+1/24;
% File conventions: 
% current day contains data from 1:30 AM to 1:00 AM
% files for floor(now-gmt_shift) has extension .dat otherwise YYMMDD

fileNameDate = FR_DateToFileName(dateFile);
fileName = [fileNameDate(1:6) 'HH.DAT'];

[fullFileName,dummy] = fr_find_data_file(dateFile,configIn,instrumentNum,fileName);
if isempty(fullFileName)
    error(['File: ' dummy ' does not exist!'])
end

[EngUnits,Header] = fcrn_read_csi_ascii(fullFileName,1,4);

tv = fr_round_hhour(fr_CSI_time(EngUnits(:,[2 3 4])));
ind = find(tv==fr_round_hhour(dateIn));
EngUnits = [tv(ind) EngUnits(ind,[16 20]-1)];

return
    
function line_cell = split_line(line_str)

ind = [-1 strfind(line_str,'","')];

for i = 1:length(ind)-1
    line_cell(i) = {line_str(ind(i)+3:ind(i+1)-1)};
end

function mat = split_data(line_str)

ind = [strfind(line_str,',')];

for i = 1:length(ind)-1
    mat(i) = str2num(line_str(ind(i)+1:ind(i+1)-1));
end


% Reading files Anne has given us
% Header = [];
% [EngUnits] = csvread(fullFileName,4,0);
% tv = fr_round_hhour(fr_CSI_time(EngUnits(:,[1 2 3])));
% ind = find(tv==fr_round_hhour(dateIn));
% EngUnits = [tv(ind) EngUnits(ind,[14 18])];



