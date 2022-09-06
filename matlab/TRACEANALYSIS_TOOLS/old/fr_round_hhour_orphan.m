function dateOut = fr_round_hhour(dateIn,optionIn)
% fr_round_hhour - properly rounds a datenum 
%
% Inputs
%   dateIn      -   time vector 
%   optionIn    -   1 - round to the nearest hhour
%                   2 - round to the nearest end of hhour
%                   3 - round to the nearest start of hhour
%
% (c) Zoran Nesic               File created:       Sep 25, 2001
%                               Last modification:  Sep 25, 2001

% Revisions:
%

if exist('optionIn')~=1 | isempty(optionIn)
    optionIn = 1;
end

[yearX,monthX,dayX,hourX,minuteX,secondX] = datevec(dateIn);
minuteX = minuteX + secondX/60;

switch optionIn
    case 1,
        minuteX = 30 * round(minuteX/30);
    case 2,
        minuteX = 30 * ceil(minuteX/30);
    case 3,
        minuteX = 30 * floor(minuteX/30);
    otherwise,
        error 'Wrong optionIN'
end

dateOut = datenum(yearX,monthX,dayX,hourX,minuteX,0);

