function [x1,y1,N] = fr_remove_delay(x, y,del_1,del_2)
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
%       -   added two new input parameters: del_1 and del_2
%       -   removed delay_samples from the input parameter list
%       -   changed algorithm so the data gets shifted (delay removed) by
%           del_1 samples and then the "streched" data set gets abs(del_2-del_1)
%           of its points removed. At the end, the data sets get croped to the
%           same size

n1 = length(x);
n2 = length(y);

if del_1 > 0
    x1 = x(:,1:n1-del_1);
    y1 = y(:,del_1+1:n2);
else
    y1 = y(:,1:n2-abs(del_1));
    x1 = x(:,abs(del_1)+1:n1);
end
n1 = n1 - abs(del_1);
n2 = n2 - abs(del_1);

if del_1 < del_2
    del_diff = del_2 - del_1;
    nn = floor(linspace(1,n2,del_diff+2));
    y1(:,nn(2:del_diff+1)) = [];
    n2 = n2 - del_diff;
elseif del_1 > del_2
    del_diff = del_1 - del_2;
    nn = floor(linspace(1,n1,del_diff+2));
    x1(:,nn(2:del_diff+1)) = [];
    n1 = n1 - del_diff;
end

N = min(n1,n2);
x1 = x1(:,1:N);
y1 = y1(:,1:N);

    