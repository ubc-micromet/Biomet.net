function [EngUnits,Header] = fr_read_Digital2(dateIn,configIn,instrumentNum)
% fr_read_Digital2 - reads data that is stored as a matrix of 2-byte signed integers with a header
% 
% This procedure supports all the new (2001->)UBC DAQ programs that use
% header structures. Needs a standard UBC ini file. Reads only one data file.
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
% (c) Zoran Nesic           File created:       Sep 26, 2001
%                           Last modification:  Aug 13, 2002

% Revisions
%
% Aug 13, 2002
%   - created sub-function EngUnits = fr_read_Digital2_file(fileName) that can be used
%     without loading in the entire configuration file

    [fileName,dummy] = fr_find_data_file(dateIn,configIn,instrumentNum);

    if isempty(fileName)
        error(['File: ' dummy ' does not exist!'])
    end

    [EngUnits,Header] = fr_read_Digital2_file(fileName);
