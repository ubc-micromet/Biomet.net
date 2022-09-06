function label_month(h,ypos,label_flag,dir_flag, skip, opts)

%**********************************************************************************
%label_month(h,ypos,label_flag,dir_flag, skip, opts)
%  This program adds XTickLabels to a graph in form of the months in a full year.
%  Units of x-axis must be DOYs, XLimits must be 0 and 365.
%
%	INPUTS:     h	 			- x-axis handle
%				ypos   			- position of labels with respect to y-axis (in units of y-axis)
%				label_flag 		- add XTicks and XTickLabels (if label == 1) 
%							  		   or just XTicks (else) to x-axis
%				dir_flag       - 'in' or 'out'
%							created on:  June 21, 1998    by:  Eva Jork
%							    (based on program mid_labl.m created by Paul Yang)
%							modified on: June 28, 1998   by:  Eva Jork
%                                 October 17, 1998
%                                   corrected error for xlim >= 365
%                    May 22, 2000 - can now do multiyears not starting at 0
%
%**********************************************************************************

if ~exist('dir_flag') |isempty(dir_flag);
   dir_flag = 'in';
end

if nargin > 5;
   if ~isfield(opts,'lastlabel');
      lastlabel = 0;
   else
      lastlabel = 1;
   end
   
   if isfield(opts,'mthstyle');
      switch getfield(opts,'mthstyle');
      case 1;month =  ['J' 'F' 'M' 'A' 'M' 'J' 'J' 'A' 'S' 'O' 'N' 'D'];
      case 3;month =  {'Jan' 'Feb' 'Mar' 'Apr' 'May' 'Jun' 'Jul' 'Aug' 'Sep' 'Oct' 'Nov' 'Dec'};
      end
   else
      month =  ['J' 'F' 'M' 'A' 'M' 'J' 'J' 'A' 'S' 'O' 'N' 'D'];
   end
else
   lastlabel = 0;
   month =  ['J' 'F' 'M' 'A' 'M' 'J' 'J' 'A' 'S' 'O' 'N' 'D'];
end




xlim = get(h, 'XLim');
timeVector =  [xlim(1):0.5:xlim(2)];
[y,m,d] = datevec(timeVector);

mth = [NaN diff(m)];
mth_tick = find(mth  == 1 | mth == -11);
mth_tick = mth_tick -1;

if lastlabel == 1;
   mth_tick(end+1) = length(m);
end
   
st = timeVector(1);
[st_y, st_m] = datevec(st);

tickpos = [datenum(st_y,st_m,1) timeVector(mth_tick)];

set(h, 'XTickLabel', '| | |');
set(h, 'XTick', tickpos,'TickDir', dir_flag);

if lastlabel == 1;
   set(h, 'XTick', tickpos(1:end-1),'TickDir', dir_flag);
end
   
pos = get(h, 'Position');
month = [month month month month month month];
for i= 1:length(tickpos)-1;
    if label_flag == 1
        name = month(m(mth_tick(i)));
    else
        name = '';
    end
    xpos = (tickpos(i)+tickpos(i+1))/2;
    if exist('skip') & ~isempty(skip);
        if rem(i,skip) == 0
            name = '';
        end
    end
   tx = text(xpos, ypos, name);
   set(tx, 'VerticalAlignment', 'cap', 'HorizontalAlignment', 'center');
end