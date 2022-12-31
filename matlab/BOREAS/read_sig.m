function [plotY,plotX] = read_sig( pth, indTimeGMT,year, t, RemoveZeros )
% [plotY,plotX] = read_sig( pth, ind,year, t, RemoveZeros )
%
% This function reads a trace from the data base.
%
%   Input parameters:
%        pth         - path and data file name
%        indTimeGMT  - index of select datapoints in GMT time
%        year        - year
%        t           - time trace
%        RemoveZeros - 1 - removes trailing and leading zeros (default),
%                      0 - keeps the original signal.
%                      
% (c) Zoran Nesic               File created:       Jul  8, 1997
%                               Last modification:  Jan  7, 2022
%


% Revisions:
%   Jan 7, 2022 (Zoran)
%     - fixing it so it works with x-axis in datetime
%       Aug 17, 1997
%           - Added input parameter RemoveZeros
%       Jul  8, 1997
%           - created using plt_sig.m as a starting point
%             

arg_default('RemoveZeros',1);   % default is to remove zeros

try
% do some createive fixes to extract startDateIn and endDateIn as datetime
% vars.
tvIn = datetime(fr_round_time(datenum(year,1,t)),'convertfrom','datenum');
startDateIn = tvIn(1);
endDateIn = tvIn(end);

% round up the input dates (startDate to the begining of the day and
% endDate to the end of the day:
startDate = dateshift(startDateIn,'start','day');
[startYear,~,~,~,~,~] = datevec(startDate);

% make sure endDateIn does not fall on Dec 31, yyyy
[endYear,~,~,~,~,~] = datevec(endDateIn);
if endDateIn == datetime(endYear,1,1)
    endDate = endDateIn;
    endYear = endYear-1;
else
    endDate = dateshift(endDateIn,'end','day');
    [endYear,~,~,~,~,~] = datevec(endDate);
end

% in case that this is a multiyear trace
rangeYears = startYear:endYear;

% fullDTV = datetime(...
%                   fr_round_time(datenum(startYear,1,1,0,30,0):1/48:datenum(endYear,12,31,24,0,0)),...
%                   'convertfrom','datenum')';
% ind = find(startDate<= fullDTV & endDate >= fullDTV);
% t = fullDTV(ind);

filePathTemplate = deblank(pth);
plotX = []; %#ok<*NASGU>
filePath = filePathTemplate;
if length(rangeYears) > 1  
    % check if filePath contains 'yyyy' wildcard or if contains
    % a fixed year (endYear)
    strInd = strfind(filePath,'yyyy');
    if isempty(strInd)                                 %#ok<*STREMP>
        % check if there is a fixed year in the path that
        % matches input variable "year" 
        strInd = strfind(filePath,sprintf('%d',endYear));
        if ~isempty(strInd)
            filePath(strInd:strInd+3) = 'yyyy';
        else
            % if not, maybe the calling program inserted a
            % endYear-1 (this can happen due to rounding up)
            strInd = strfind(filePath,sprintf('%d',endYear-1));
            if ~isempty(strInd)
                filePath(strInd:strInd+3) = 'yyyy';
            end
        end
    end
end
try
    plotY = read_bor(filePath,1,[],rangeYears);     % get the data from the data base
    plotY = plotY(indTimeGMT);
    plotX = tvIn;
    if RemoveZeros == 1
        plotY = replace_zeros(plotY,NaN);           % replace with NaNs instead of removing zeros
%         [plotY,indx] = del_num(plotY,0,0);          % remove leading zeros from tmp
%         plotX = tvIn(indx);                            % match with tx
%         [plotY,indx] = del_num(plotY,0,1);          % find trailing zeros in tmp
%         plotX = plotX(indx);                        % match with tx
    end
catch
    % if the current trace does not exist 
    % plot NaNs (Zoran 20100105)
    plotX = tvIn;
    plotY = NaN * ones(length(tvIn),1);
end   
            
% convert plotX to DOY for rangeYears(end)
plotX = datenum(plotX) - datenum(rangeYears(end),1,0);
end

function y = replace_zeros(x_in,replacementNum)
% replace leading and trailing zeros with (usually) NaNs. 
% Useful when the data range is wider than the number of 
% non-zero numbers in the data base. Mainly useful because the
% leading and trailing zeros mess up the ylim auto-scaling
y = x_in;
ind = find(y~=0);
y([1:ind(1)-1 ind(end)+1:end]) = replacementNum;
end
