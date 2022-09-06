function [EngUnits,Header] = fr_read_BiometMat(dateIn,configIn,instrumentNum)
% fr_read_BiometMat - reads data that is stored as a matlab file 
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
% (c) Zoran Nesic           File created:       May  2, 2012
%                           Last modification:  May  2, 2012

% Revisions
%

    [fileName,dummy] = fr_find_data_file(dateIn,configIn,instrumentNum);

    if isempty(fileName)
        error(['File: ' dummy ' does not exist!'])
    end

    [EngUnits,Header] = fr_read_BiometMat_file(fileName);
