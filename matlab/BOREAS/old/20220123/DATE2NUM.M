function [dd,mm,yy] = date2num(d)
%
%
%
%   For a give date string (d) this function returns 3 numerical arrays
%   days: (dd), months: (mm) and years: (yy)
%
%   inputs:
%       d       date string array (mm-dd-yyyy or mm-dd-yy)
%   outputs:
%       dd      array of days
%       mm      array of months
%       yy      array of years
%
%   (c) Zoran Nesic                 File created:           Jun 16, 1996
%                                   Last modification:      Jun 16, 1996
%
[n1,m1] = size(d);
mm_all = abs(d(:,1:2))-48;
mm = mm_all(:,1)*10 + mm_all(:,2);
mm = mm(:);
yy_all = abs(d(:,7:m1))-48;
if m1 == 10
    yy = yy_all(:,1)*1000 + yy_all(:,2)*100 + yy_all(:,3)*10 + yy_all(:,4);
else
    yy = yy_all(:,3)*10 + yy_all(:,4);
end    
yy = yy(:);
dd_all = abs(d(:,4:5))-48;
dd = dd_all(:,1)*10 + dd_all(:,2);
dd = dd(:);


