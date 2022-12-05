function x = LeapYear (y)
%
%
%  This function returns 1 if y is a leap year, else it returns 0.
%
%    inputs
%           y   year (yy or yyyy)
%    outputs
%           x   1 for leap year, 0 otherwise
%
%  (c) Zoran Nesic                  File created:       Jun 16, 1996
%                                   Last modification:  Dec 15, 2000
%
% Revisions:
%
%   Dec 15, 2000
%       - better handling of 2-digit years: y < 50 => year = 2000+y
%                                          80 < y < 100 => year = 1900 + y
if y < 50
    y = y + 2000;
elseif y >80 & y < 100
    y = y + 1900;
end
x = (mod(y,4) == 0 & mod( y,100) ~= 0) | (mod(y,400))==0;

