function [x,fileName] = fr_read_Database(dateIn,configIn,instrumentNum)
% fr_read_Database - reads data that is stored in the database (as binary data)
% 
% This procedure reads only one data file from the database.
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
% (c) E Humphreys           File created:       Oct 8, 2002
%                           Last modification:  
% Revisions
%

yr = datevec(dateIn(1));
pth = configIn.database_path;
if ~isempty(pth)
    fileName = fullfile(num2str(yr(1)), configIn.site,...
        configIn.Instrument(instrumentNum).FileID);
else
    pth = biomet_path(yr(1),configIn.site);
    fileName = configIn.Instrument(instrumentNum).FileID;
end

fullFileName = fullfile(pth, fileName);    

if exist(fullFileName)~= 2
    fullFileName = [];
end


if isempty(fullFileName)
    error(['File: ' fileName ' does not exist!'])
end

if isfield(configIn.Instrument(instrumentNum),'ConvertToLocal') ... 
        & configIn.Instrument(instrumentNum).ConvertToLocal == 1
    ind = (dateIn(1)-configIn.gmt_to_local-datenum(yr(1),1,1)).*48;
else
    ind = (dateIn(1)-datenum(yr(1),1,1)).*48;
end

ind = round(ind);
x = read_bor(fullFileName,[],[],[],ind);

    