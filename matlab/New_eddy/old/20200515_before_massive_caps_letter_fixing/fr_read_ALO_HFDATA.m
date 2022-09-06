function [EngUnits,Header] = fr_read_ALO_HFDATA(dateIn,configIn,instrumentNum)
% fr_read_ALO_HFDATA - reads data that is stored as a set of Matlab variables.
%                       Most likely works only on Alberto's data (Brian Amiro)
% 
%
% Inputs:
%   dateIn      - datenum (this is not a vector, only one file is read at the time)
%   configIn    - standard UBC ini file
              %   systemNum   - system number (see the ini file)
%   instrumentNum - instrument number (see the ini file)
%
% Outputs:
%   EngUnits    - data matrix if file exists, empty if file is missing
%   Header      - file header
%
%
% (c) Zoran Nesic           File created:       Nov  7, 2003
%                           Last modification:  Nov  7, 2003

% Revisions
%
    configIn.Instrument(instrumentNum).FileID = [ configIn.Instrument(instrumentNum).FileID '.mat'];
    [fileName,dummy] = fr_find_data_file(dateIn,configIn,instrumentNum);

    if isempty(fileName)
        error(['File: ' dummy ' does not exist!'])
    end

    load(fileName);
    EngUnits = Eddy_HF_data;
    Header = [];
