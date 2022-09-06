function [EngUnits,Header] = fr_read_TOA5(dateIn,configIn,instrumentNum)
% fr_read_TOA5 - reads data that is stored by CRBasic loggers
% 
%
% Inputs:
%   dateIn      - datenum (this is not a vector, only one file is read at the time)
%   configIn    - standard UBC ini file
%   instrumentNum - instrument number (see the ini file)
%
% Outputs:
%   EngUnits    - data matrix if file exists, empty if file is missing
%   Header      - file header
%
%
% (c) Zoran Nesic           File created:       Jan 29, 2012
%                           Last modification:  Jan 29, 2012

% Revisions:
%

    [fileName,dummy] = fr_find_data_file(dateIn,configIn,instrumentNum);

    if isempty(fileName)
        error(['File: ' dummy ' does not exist!'])
    end

    [EngUnits,Header,tv] = fr_read_TOA5_file(fileName);
    EngUnits = EngUnits(fr_round_time(tv) == fr_round_time(dateIn), ...
                        configIn.Instrument(instrumentNum).ChanNumbers);
   
    
