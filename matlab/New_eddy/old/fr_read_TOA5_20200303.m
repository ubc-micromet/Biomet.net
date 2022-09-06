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
% Sept 11, 2014 (Nick)
%   -fixed bug in rounding of tv: fr_round_time rounds to the nearest units
%   in (30min) by default and was rounding half the HF data to the beginning of the
%   half hour and half to the end of half hour which cut the number of
%   samples returned in half when tested against dateIn! 
%   Changed to explicity round the end of the half-hour--works now! 

    [fileName,dummy] = fr_find_data_file(dateIn,configIn,instrumentNum);

    if isempty(fileName)
        error(['File: ' dummy ' does not exist!'])
    end

    [EngUnits,Header,tv] = fr_read_TOA5_file(fileName);
%     EngUnits = EngUnits(fr_round_time(tv) == fr_round_time(dateIn), ...
%                         configIn.Instrument(instrumentNum).ChanNumbers);
%  must round all HF data to the end of the half-hour!! Sept 11, 2014
    EngUnits = EngUnits(fr_round_time(tv,[],2) == fr_round_time(dateIn), ...
                        configIn.Instrument(instrumentNum).ChanNumbers);
   
    
