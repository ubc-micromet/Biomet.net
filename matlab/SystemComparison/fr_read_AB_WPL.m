function [EngUnits,Header] = fr_read_AB_WPL(dateIn,configIn,instrumentNum)
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

%    [fileName,dummy] = fr_find_data_file(dateIn,configIn,instrumentNum);

% Generate file name, eg. P1660330.SLT
[yy,dd,MM,hh,mm,ss] = datevec(fr_round_hhour(dateIn,1));
[yy,dd,MM,hh,mm,ss] = datevec(datenum(yy,dd,MM,hh,mm-30,ss));
doy = floor(datenum(yy,dd,MM,hh,mm,ss) - datenum(yy,1,0));
fileName = sprintf('P%03.0f%02.0f%02.0f.SLT',doy,hh,mm);
pthFileName = fullfile(configIn.path,fileName);
if exist(pthFileName) ~= 2
    error(['File: ' pthFileName ' does not exist!'])
else
    disp(['Reading ' fileName]);
end

[EngUnits,Header] = fr_read_AB_WPL_file(pthFileName);

return
