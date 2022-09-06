function average = blockavg(criterion_array, x, step, upper_limit, lower_limit)

%==================================================================================
%
%   THIS FUNCTION IS TO DO THE BLOCK AVERAGE ACCORDING TO ANY CRITERION
%     WHICH IS DEFINED IN THE CRITERION_ARRAY FOR THE WHOLE DATASET
%
%   Syntex:
%       average = blockavg(criterion_array, x, step, upper_limit, lower_limit)
%
%   Input:
%        criterion_array:  The criterion data set for averaging (Sigma_w, u*, etc.)
%                      x:  The variable for averaging (Fc39 etc.)
%            upper_limit:  The upper_limit for good data of x (1000 w/m2 for Solar etc.)
%            lower_limit:  The lower_limit for good data of x (-100 w/m2 for Solar etc.)
%
%   Output:
%       average:  The average of x (col 1: mean_criterion; col 2: average; 
%                   col 3: sigma; col 4: n)
%       sigma:    The standard deviation of x:
%       
%   Note:
%       time array should start from 1 Jan, 1996 = 1;
%=======================================================================================

% Wrapper function for the old blockavg by Paul Yang

ind = find(x<=upper_limit & x>= lower_limit);
y = x(ind);
x = criterion_array(ind);
d_begin = floor(min(criterion_array)/step)*step;
d_end = max(criterion_array);
bin = d_begin:step:d_end;

% Stats defintion in bin_avg
% 1 = mean, 2 = std, 3 = se, 4 = sum, 5 = n, 6 = median, 7 = min, 
% 8 = max, 9 = x stats
[x_bin, y_bin] = bin_avg(x,y,bin,[1 2 5]);

average = [x_bin y_bin];

return