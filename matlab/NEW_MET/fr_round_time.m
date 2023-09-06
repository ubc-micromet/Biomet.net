function dateOut = fr_round_time(dateIn,unitsIn,optionIn)
% fr_round_hhour - properly rounds a datenum 
%
% Inputs
%   dateIn      -   time vector 
%   unitsIn     -   units of time:
%                   'month',
%                   'day',
%                   'hour',
%                   '30min',   (default)
%                   'Xmin', (X - is a number: 30min, 1min, 5min)
%                   'sec'
%   optionIn    -   1 - round to the nearest unitsIn            (default)
%                   2 - round to the nearest end of unitsIn    
%                   3 - round to the nearest start of unitsIn
%
% (c) Zoran Nesic               File created:       Sep  4, 2005
%                               Last modification:  Sep  6, 2023

% Revisions:
%
% Sep 6, 2023 (Zoran)
%   - added 'Xmin' time unit. It replaced 'min','30min' with more generic
%     approach. 
%        - Use '5min' if you want the time to round to 5-min marks.
%        - '60min' is the same as 'hour' (but 'hour' is left for the legacy code)
%   - syntax cleanup.
%  Feb 15, 2007 (Z)
%       - fixed wrong defaults for optionIn in the comment lines

arg_default('optionIn',1);
arg_default('unitsIn','30MIN');

if isempty(dateIn)
    dateOut = [];
    return
end

[yearX,monthX,dayX,hourX,minuteX,secondX] = datevec(dateIn);

switch optionIn
    case 1
        roundType = 'round';
    case 2
        roundType = 'ceil';
    case 3
        roundType = 'floor';
    otherwise
        error 'Wrong optionIN'
end

if strcmpi(unitsIn(end-2:end),'MIN')
    if length(unitsIn)==3
        numOfMin = 1;
    else
        numOfMin = str2double(unitsIn(1:end-3));
    end
else
    numOfMin = [];
end

if strcmpi(unitsIn,'SEC')
    secondX = feval(roundType,secondX); %#ok<*FVAL>
elseif ~isempty(numOfMin)
    minuteX = minuteX + secondX / 60;
    secondX = 0;
    minuteX = numOfMin * feval(roundType,minuteX/numOfMin);
elseif strcmpi(unitsIn,'HOUR')
    minuteX = minuteX + secondX / 60;
    secondX = 0;
    hourX = hourX + minuteX / 60 ;
    minuteX = 0;    
    hourX = feval(roundType,hourX);    
elseif strcmpi(unitsIn,'DAY')
    minuteX = minuteX + secondX / 60;
    secondX = 0;
    hourX = hourX + minuteX / 60 ;
    minuteX = 0;    
    dayX = dayX + hourX / 24;    
    hourX = 0;
    dayX = feval(roundType,dayX);    
elseif strcmpi(unitsIn,'MONTH')
    minuteX = minuteX + secondX / 60;
    secondX = 0;
    hourX = hourX + minuteX / 60 ;
    minuteX = 0;    
    dayX = dayX + hourX / 24;        
    hourX = 0;
    monthX = monthX + dayX / 12;
    dayX = 0;
    monthX = feval(roundType,monthX);  
else
    error 'Wrong units!'
end        
        
dateOut = datenum(yearX,monthX,dayX,hourX,minuteX,secondX);

