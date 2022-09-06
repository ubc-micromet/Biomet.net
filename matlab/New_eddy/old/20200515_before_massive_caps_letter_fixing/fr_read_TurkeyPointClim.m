function [EngUnits,Header] = fr_read_TurkeyPointClim(dateIn,configIn,instrumentNum)
% fr_read_TurkeyPointClim - reads Altaf's climate data
% 
%
% Inputs:
%   dateIn        - datenum (this is not a vector, only one file is read at the time)
%   configIn      - standard UBC ini file
%   systemNum     - system number (see the ini file)
%   instrumentNum - instrument number (see the ini file)
%
% Outputs:
%   EngUnits    - data matrix if file exists, empty if file is missing
%   Header      - file header
%
%
% (c) kai                   File created:       Nov 28, 2003
%                           Last modification:  Nov 28, 2003

% Revisions
%

% Ignore missing arguments so the function can be used stand alone
% if exist('configIn') & ~isempty(configIn) & exist('configIn') & ~isempty(configIn)
% At this point we do not need this...
if 0
   configIn.Instrument(instrumentNum).FileID = [ configIn.Instrument(instrumentNum).FileID '.mat'];
   [fileName,dummy] = fr_find_data_file(dateIn,configIn,instrumentNum);
   
   if isempty(fileName)
      error(['File: ' dummy ' does not exist!'])
   end
end

Header = {'Ta_28m','Pressure'};

dv = datevec(dateIn);

pth_in = configIn.database_path;
EngUnits = dlmread(fullfile(pth_in,['meteo' num2str(dv(3),'%02i') num2str(dv(2),'%02i') num2str(dv(1)-2000,'%02i') '.dat']),'\t',1,0);
tv = datenum(EngUnits(:,1),EngUnits(:,2),EngUnits(:,3),...
             EngUnits(:,5),EngUnits(:,6),EngUnits(:,7));
% Find the right entry
ind_tv = find(tv == dateIn);

EngUnits = EngUnits(ind_tv,[9,37]);

