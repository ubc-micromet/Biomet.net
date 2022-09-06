function [tv,climateData] = fr_read_csi(wildCard,dateIn,chanInd,tableID,verbose_flag,timeUnit,roundType,tv_input_format)
% fr_read_sci_net(wildCard,dateIn,chanInd)
%                      - extract all or selected data from a csi file
% 
% [tv,climateData] = fr_read_csi(wildCard,dateIn,chanInd)
%
% Inputs:
%       wildCard - full file name including path. Wild cards accepted
%       dateIn   - time vector to extract.  [] extracts all data
%       chanInd  - channels to extract. [] extracts all
%       tableID  - Table to be extracted
%       verbose_flag - 1 -ON, otherwise OFF
%       timeUnit        - nearest time unit that time will be rouned to (see
%                         fr_round_time). When rounding on the seconds function
%                         will assume that the time is in columns 2-5 otherwise
%                         2-4 (YEAR, DOY, HHMM, SECONDS)
%       roundType       - 1,2,3 -> see fr_round_type for details
%       tv_input_format -               [type arg1    arg2       arg3   ]
%                           21x files:  [1    yearCol DOYcol     timeCol]
%                           DecDOY:     [2    year    0.0-364.99 NA     ] not implemented                         
%                           DecDOY:     [3    year    1.0-365.99 NA     ] not implemented
%                           no yearCol: [4    year    DOYcol     timeCol] not implemented
%
% Zoran Nesic           File Created:      Apr 21, 2005
%                       Last modification: Jul 26, 2022

% Revisions
%
% July 26, 2022 (Zoran)
%   - added parameter tv_input_format to provide the same functionality
%     that dbase_updata ini file had. This is from an original ini file
% '--------------------------------------------------
% '     1. 21x (Year, DOY and time column num.)"
% '
% '           This format needs
% '               1. Year column number
% '               2. DOY column number
% '               3. Time column number
% '
% '     2. DecDOY [0.0 - 364.99]"
% '
% '           This format needs:
% '               1. Year
% '               2. Decimal DOY column number
% '
% '     3. DecDOY [1.0 - 365.99]"
% '
% '           This format needs:
% '               1. Year
% '               2. Decimal DOY column number
% '
% '     4. 21x w/o year col.#"
% '           This format needs
% '               1. Year
% '               2. DOY column number
% '               3. Time column number
% '---------------------------------------------------
% Sep 4, 2005 (Z)
%   - added arg_default
%   - added new inputs: timeUnit and roundType to provide better handling
%     of a wider range csi files with different sampling times (down to 1
%     second samples)
%   - made it compatible with dir statement from Matlab 5.3.1 (it will
%     remove the extra path info from dir.name record
%   - If input file is empty it returns empty matrices

% Default arguments
arg_default('verbose_flag',0);          % verbose off
arg_default('timeUnit','30min');        % rounding to half hour
arg_default('roundType',2);             % rounding to the end of timeUnit
arg_default('tv_input_format',[1 2 3 4])% default is regular 21x format

switch tv_input_format(1)
    case 1
        timeChans = tv_input_format(2:end);
    case {2,3,4}
        error('fr_read_csi.m: type not implemented!')
    otherwise
        error('fr_read_csi.m: type not implemented!')
end

tv = [];
climateData = [];

x = findstr('\',wildCard);
pth = wildCard(1:x(end));
h = dir(wildCard);
% remove path from h.name if necessery
for i=1:length(h)
    s1 = strfind(h(i).name,pth)    ;
    if s1 > 0
        h(i).name = h(i).name(length(pth)+1:end);
    end
end
dateIn = fr_round_hhour(dateIn);

climateData = [];
for i=1:length(h)
    if verbose_flag,fprintf(1,'Loading: %s. ', [pth h(i).name]);end
    dataInNew = csvread([pth h(i).name]);
    ind = find(dataInNew(:,1) == tableID);
    dataInNew = dataInNew(ind,:);
    if verbose_flag,fprintf(1,'  Length = %f\n',size(dataInNew,1));end
    climateData = [climateData ; dataInNew];
end

% exit if there is no data to process
if isempty(climateData)
    return
end

if ~exist('chanInd') | isempty(chanInd)
    chanInd = 1:size(climateData,2);
end

switch upper(timeUnit)
    case 'SEC'
        tv = fr_csi_to_timevector(climateData(:,[timeChans timeChans(end)+1]));      % if rounding on the seconds 
    otherwise
        tv = fr_csi_to_timevector(climateData(:,timeChans));
end

tv = fr_round_time(tv,timeUnit,roundType);
[tv,indSort] = sort(tv);
climateData = [climateData(indSort,chanInd)];

if exist('dateIn') & ~isempty(dateIn)
    dateIn = fr_round_time(dateIn,timeUnit,roundType);
    [junk,junk,indExtract] = intersect(dateIn,tv );
else
    indExtract = 1:size(tv,1);
end
   
tv = tv(indExtract);
climateData = climateData(indExtract,:);


function tv = fr_csi_to_timevector(csiTimeMatrix)

if size(csiTimeMatrix,2) == 4
    secondX = csiTimeMatrix(:,4);
else
    secondX = 0;
end

tv = datenum( csiTimeMatrix(:,1),1 , csiTimeMatrix(:,2),...
              fix(csiTimeMatrix(:,3)/100),...
              (csiTimeMatrix(:,3)/100 - fix(csiTimeMatrix(:,3)/100))*100,secondX);
