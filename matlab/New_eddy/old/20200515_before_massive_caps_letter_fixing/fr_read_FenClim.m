function [EngUnits,Header] = fr_read_FenClim(dateIn,configIn,instrumentNum)
% fr_read_TurkeyPointClim - reads Altaf's climate data
% 
%
% Inputs:
%   dateIn        - datenum (this is not a vector, only one file is read at the time)
%   configIn      - standard UBC ini file
%   instrumentNum - instrument number (see the ini file)
%
% Outputs:
%   EngUnits    - data matrix if file exists, empty if file is missing
%   Header      - file header
%
%
% (c) Zoran Nesic           File created:       Jan 28, 2004
%                           Last modification:  Jan 28, 2004

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

Header = {'Ta_18m','Pressure'};

dv = datevec(dateIn);

pth_in = configIn.database_path;
EngUnits = dlmread(fullfile(pth_in,['FEN23x2.' num2str(dateIn-datenum(dv(3),1,0),'%03i')]),'\t',1,0);
tv = datenum(EngUnits(:,1),EngUnits(:,2),EngUnits(:,3),...
             EngUnits(:,5),EngUnits(:,6),EngUnits(:,7));
% Find the right entry
ind_tv = find(tv == dateIn);
if isempty(ind_tv) 
    EngUnits = dlmread(fullfile(pth_in,'FEN23x2.dat'),'\t',1,0);
    tv = datenum(EngUnits(:,1),EngUnits(:,2),EngUnits(:,3),...
                 EngUnits(:,5),EngUnits(:,6),EngUnits(:,7));
    % Find the right entry
    ind_tv = find(tv == dateIn);
    if isempty(ind_tv)
        Ta = NaN * ones(size(dateIn));
    else
        Ta = EngUnits(ind_tv,[10]);
    end
end
