function [del_1, del_2] = find_delay(x,y,chan,n,del_span)
%
%
%
%
%
%
% (c) Zoran Nesic               File created:       Oct 19, 1997
%                               Last modification:  Jan  1, 1998

%
% Revisions:
%
%   Jan 1, 1998
%       -   assigned two new outputs (del_1 and del_2)
%       -   removed delay_sample [=(del_1+del_2)/2] from the calculation/output
%

N = min(length(x),length(y));
if N > n
    del_1 = delay(x(chan(1),1:n),y(chan(2),1:n),del_span);
    del_2 = delay(x(chan(1),N-n+1:N),y(chan(2),N-n+1:N),del_span);
else
    del_1 = 0;
    del_2 = 0;
end
%disp([del_1 del_2]);