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
%                               Last modification:  Sep  4, 2005

% Revisions:
% Sep 4, 2005 (Zoran)
%   - This function now uses fr_round_time
% Apr 25, 2005
%   - Added return of [] if input is an []  (z.)

arg_default('optionIn',1)

dateOut = fr_round_time(dateIn,'30min',optionIn);



%----------------- old version -----------------------------------------
% 
% if exist('optionIn')~=1 | isempty(optionIn)
%     optionIn = 1;
% end
% 
% if isempty(dateIn)
%     dateOut = [];
%     return
% end
% 
% [yearX,monthX,dayX,hourX,minuteX,secondX] = datevec(dateIn);
% minuteX = minuteX + secondX/60;
% 
% switch optionIn
%     case 1,
%         minuteX = 30 * round(minuteX/30);
%     case 2,
%         minuteX = 30 * ceil(minuteX/30);
%     case 3,
%         minuteX = 30 * floor(minuteX/30);
%     otherwise,
%         error 'Wrong optionIN'
% end
% 
% dateOut = datenum(yearX,monthX,dayX,hourX,minuteX,0);
% 
