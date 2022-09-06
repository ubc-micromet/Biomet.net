function [x,ind] = del_num(y,num,flag)
%
%   [x,ind] = del_num(y,num,flag)
%
%   Remove leading and/or trailing consecutive elements of y that are equal to num 
%
%   inputs:
%       y       numerical vector
%       num     numerical value that should be removed (0 is default)
%       flag    0 - remove leading (default) , 1 - remove lagging num's,
%               2 - remove leading and trailing nums
%   outputs:
%       x       y without leading num's
%       ind     index of the first/last/middle non-num element of y
%
%
% (c) Zoran Nesic               File created:       Feb 25, 1997
%                               Last modification:  Jul  8, 1997
%

% Revisions:
%
%   Jul 8, 1997
%       
%
%   Jul 3, 1997
%       Changed a "x == []" statement to a "isempty(x)" statement
%

ni = nargin;
if ni < 3
    flag = 0;
elseif ni <2
    num = 0;
elseif ni < 1
    error 'Input parameter(s) missing!'
end
N = length(y);

ind_first = min(find( y ~= num ));            % find first y ~= num
if isempty(ind_first)
    ind_first = 1;
end

ind_last  = N - min(find(y(N:-1:1) ~= num ))+1;   % find last y ~= num
if isempty(ind_last)
    ind_last = N;
end

if flag == 0
    ind = ind_first:N;                      
elseif flag == 2
    ind = ind_first:ind_last;
elseif flag == 1
    ind = 1:ind_last;
end

x = y(ind);                             % remove leading/trailing num's
    