function [x,dummy] = fr_read_Digital1(dateIn,configIn,instrumentNum)
% fr_read_Digital1 - reads data that is stored as a matrix of 2-byte signed integers
% 
% This procedure supports all the old (<-2001) RS232 DAQ programs that didn't use
% any header structures (UBC_GillR2, UBC_GillR3 and such). Can be used on any
% matrix of 16-bit integers. Needs a standard UBC ini file. Reads only one data file.
%
% Inputs:
%   dateIn      - datenum (this is not a vector, only one file is read at the time)
%   configIn    - standard UBC ini file
              %   systemNum   - system number (see the ini file)
%   instrumentNum - instrument number (see the ini file)
%
% Outputs:
%   x           - data matrix if file exists, empty if file is missing
%   dummy       - file name without the path (see fr_find_data_file)
%
%
% (c) Zoran Nesic           File created:       Sep 26, 2001
%                           Last modification:  Jun 27, 2002

% Revisions
%
% Jun 27, 2002
%   - moved the polynomial calculations (eng.units) to fr_read_and_convert
%

    [fileName,dummy] = fr_find_data_file(dateIn(1),configIn,instrumentNum);
    if isempty(fileName)
        error(['File: ' dummy ' does not exist!'])
    end

    numOfChans = configIn.Instrument(instrumentNum).NumOfChans;
    x = FR_read_raw_data(fileName,numOfChans)';

% Moved out on Jun 27, 2002
%    for i=1:numOfChans
%        p = configIn.Instrument(instrumentNum).Poly(i,:);
%        x(:,i) = polyval(p,x(:,i));
%    end
    