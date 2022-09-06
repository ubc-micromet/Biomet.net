function [x,t] = read_sig( pth, ind,year, t, RemoveZeros )
% [x,t] = read_sig( pth, ind,year, t, RemoveZeros )
%
% This function reads a trace from the data base.
%
%   Input parameters:
%        pth         - path and data file name
%        ind         - index to select the data points
%        year        - year
%        t           - time trace
%        RemoveZeros - 1 - removes trailing and leading zeros (default),
%                      keeps the original signal.
%                      
% (c) Zoran Nesic               File created:       Jul  8, 1997
%                               Last modification:  Aug 17, 1997
%

% Revisions:
%       Aug 17, 1997
%           - Added input parameter RemoveZeros
%       Jul  8, 1997
%           - created using plt_sig.m as a starting point
%             

if nargin < 5
    RemoveZeros = 1;                % default is to remove zeros
end
x = read_bor(pth);                  % get the data from the data base
x = x(ind);                         % extract the requested period
if RemoveZeros == 1
    [x,indx] = del_num(x,0,2);      % remove leading and trailing zeros from x
else
    indx = 1:length(t);             % keep all values
end
t = t(indx);                        % match with t
