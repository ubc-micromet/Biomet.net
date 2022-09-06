function [EngUnits, Header] = fr_read_CRBasic(dateIn,configIn,instrumentNum)
% fr_read_CRBasic - reads ascii data created by Campbell Sci. dataloggers using CRBasic
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
% (c) Zoran Nesic           File created:       July  , 2004
%                           Last modification:  May 1, 2007

% Revisions
% March 10, 2010
%   - added Header to the fr_read_CRBasic_file output
% May 1, 2007
%   - created a generic CRBasic data-file reading program using
%   fr_read_MPB1 as the starting point
% Jan 8, 2007
%   - Fixed up the reading of "NAN"-s and separted fr_read_MPB1_file out of
%   here
% Aug 16, 2004
%   - made it work for '-1.#IND'
%

Header = [];

[fileName,dummy] = fr_find_data_file(dateIn,configIn,instrumentNum);

if isempty(fileName)
    error(['File: ' dummy ' does not exist!'])
end

[EngUnits,Header]= fr_read_CRBasic_file(fileName,[configIn.Instrument(1).JunkColumns length(configIn.Instrument(1).ChanNumbers)]);

