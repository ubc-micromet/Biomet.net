function tn = time2num(t)
%
%
%
%   For a give time string (t) this function returns a numerical array
%   that represents decimal time (0..1)
%
%   inputs:
%       t       time string array (hh:mm:ss)
%   outputs:
%       tn      decimal time
%
%   (c) Zoran Nesic                 File created:           Jun 16, 1996
%                                   Last modification:      Jun 16, 1996
%
[n1,m1] = size(t);
hh_all = abs(t(:,1:2))-48;
hh = hh_all(:,1)*10 + hh_all(:,2);
hh = hh(:)/24;

mm_all = abs(t(:,4:5))-48;
mm = mm_all(:,1)*10 + mm_all(:,2);
mm = mm(:)/(60*24);

tn = hh+mm;


