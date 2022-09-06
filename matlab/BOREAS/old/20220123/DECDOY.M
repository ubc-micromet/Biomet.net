function x = decDOY(d,t)
%
%   x = decDOY(d,t)
%
%
%   This function returns decimal DOY for the give time and date. Date should
% be in format: mm-dd-yyyy. Decimal DOY starts with Jan-01, 12am being 0.00.
%
%   inputs:
%            d       date (mm-dd-yyyy)
%            t       time (hh:mm:ss)
%   outputs
%            x       decDOY
%
%   NOTE: This function will NOT work over the end of a year. If year
%         changes in (d) then (d) and (t) have to be split into two
%         separate arrays for each year. If this becomes a big problem
%         it can be fixed.
%
% (c) Zoran Nesic                   File created:       Jun 16, 1996
%                                   Last modification:  Dec  2, 1996
%

mnth = [31 28 31 30 31 30 31 31 30 31 30 31];
[n1,m1]=size(d);
[n2,m2] = size(t);
if n1 ~= n2
    error 'Time and date arrays must have same dimensions!'
end
x = zeros(n1,1);

[dd,mm,yy] = date2num(d);
ly = leapyear(yy);
tn = time2num(t);
for i=1:n1    
    mn_sum(i) = sum(mnth(1:mm(i)-1));
    if mm(i) > 2 & ly(i) ~= 0
        mn_sum(i) = mn_sum(i) + ly(i);    
    end
end
x = mn_sum' + dd + tn;

