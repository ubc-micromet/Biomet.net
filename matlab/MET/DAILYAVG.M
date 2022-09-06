function average = average(time_array, x, upper_limit, lower_limit)

%================================================================
%
%   THIS FUNCTION IS TO DO THE DAILY AVERAGE 
%
%  First generated on:  19 Jan 1996 by Z. Nesic and P. Yang
%        Modified on:   27 May 1997 by P. Yang  
%
%  inputs:  time_array, x, upper and lower limits
%
%  outputs: daily mean
%
%  Syntax:
%     average = dailyavg(time_array, x, upper_limit, lower_limit)
%
%  Example:
%     average = dailyavg(time, Fc, 1, -1)
%
%  Revisions:
%   27 May 1997: Put the std to the output file
%================================================================

average = zeros(518,4);
%doy = zeros(518,1);

doy = -1;
ind = find(isnan(x)==0 & (x>lower_limit & x<upper_limit));
x = x(ind);
ta = ceil(time_array(ind));

st = 0;
ind = 1;
lenx = length(x);
for i = 1:518
        st = st + length(ind);
        stp = st + 50;
        if stp > lenx
            stp = lenx;
        end 
%        disp([ st st+50 ])
        ind = find( ta(st:stp) == i );
        if rem(i,500)==0            
            disp(i)
        end
        if length(ind)>0
            xx = mean(x(ind+st-1));
            xx1 = std(x(ind+st-1));
            n = length(ind);
        else
            xx = nan;
            xx1 = xx;
            n = xx;
        end        
        average(i,1) = i;
        average(i,2) = xx;
        average(i,3) = xx1;
        average(i,4) = n;
end        