function [data_out, flag] = calc_avg_trace(tv, data_in, data_fill, avg_period)
% Second level data processing function
%
% [data_out, flag] = calc_avg_traces(tv, data_in, data_fill, avg_period)
%
% Computes the averages of multiple input traces and fills where no input is
% available
%
% The average is taken across non-NaN elements in the rows of the matrix 
% data_in which contains  the traces in its columns
%
% flag: no of traces used in average
%
% (C) Kai Morgenstern				File created:  Aug 14, 2000
%									Last modified: Apr  1, 2023

% Revision: 
% 
% Apr 1, 2023 (Zoran)
%   - Fixed a bug that could happen when working with data_fill that had more 
%     than one trace (multi-trace input in data_fill).
%     A row of data_fill would not be properly averaged 
%     when avg_period==-1 and the row contained a NaN. If, at the same
%     time, the input data had a NaN in the same row, it would not get gap 
%     filled even if there were some good alternative measurements in the 
%     same data_fill row.
%     Example: 
%       x = [1 2 NaN 4 5]';
%       y = [1.1 2.1 3.1 4.1 5.1;0.9 NaN 2.9 3.9 4.9]'; 
%       calc_avg_trace(0:4, x, y, -1)
%     would return [1 NaN 3 4 5]' instead of [1 2.1 3 4 5] 
%   
% April 30, 2009
%   - Nick fixed indexing errors in the moving window
%     calibration of fill data to input (primary trace) data.
%     Beginning of gap indexes incorrectly referenced as 1;
%     should be indRest(1); end of gap indexes referenced as
%     length(indRest), should be indRest(end).
% Jan 07, 2005 
%   - Removed div by zero errors and made regression easier to follow (crs)
% Sep 12, 2004 
%   - bypass regression localization if less then 2
%     data points are available.  In this case default to taking the
%     average of the good points. (crs)
% Oct 23, 2003 
%   - skip regression application on data_fill if regression results are NaN
% Apr 3, 2002 
%   - added ability to do above regression on all present 
%     data up front: type in -1 for avg_period(E. Humphreys)
% Feb 2, 2002 
%   - added an optional regression between data_in and data_fill 
%     to ensure similarity of results (E. Humphreys)


data_out = NaN * zeros(length(tv),1);		
n_out    = zeros(length(tv),1);	

if ~exist('data_fill','var')
   data_fill = [];
end 

if nargin < 4
    avg_period = 0;                         %set averaging period to 0 (ie no 'calibrating')
end

step       = tv(end)-tv(end-1);             %get data interval length
step_data  = floor(avg_period./step./2);

[~,nn] = size(data_in);					%get size of input matrix
indf = find(mean(isfinite(data_in),2) == 1);%find rows with all real numbers
data_out(indf,:) = mean(data_in(indf,:),2);	%calculate mean of each of these rows.
n_out(indf) =  nn;							%set flag to length of each row

%Get the rest of the indices that contains non-real numbers: NaN, inf, -inf:
indRest = find(mean(isfinite(data_in),2) < 1);   
junk = data_fill;
if avg_period == -1
    indf = find(mean(isfinite(data_fill),2) == 1);		%find rows with all real numbers
    data_fill(indf,1) = mean(data_fill(indf,:),2);		%calculate mean of each of these rows.
    indf = find(sum(isfinite(data_fill),2) < size(data_fill,2) & sum(isfinite(data_fill),2) > 0);
    for i = 1:length(indf)          %go through each row and average available not-NaN data
        goodDataInRow = data_fill(indf(i),:);
        goodDataInRow = mean(goodDataInRow(isfinite(goodDataInRow)));
        data_fill(indf(i),1) = goodDataInRow;   %mean(isfinite(data_fill(indf(i),:)),2);
    end
    data_fill = data_fill(:,1); % extract all averages from the column #1
    ind = find(~isnan(data_out) & ~isnan(data_fill));
    a = linreg(data_fill(ind),data_out(ind)); %'calibrate' fill column to incoming data
    if ~isnan(a(1))
       data_fill = a(2) + a(1) .* data_fill;
    end           
       
    avg_period = 0; %will avoid running through looped calibrations
end
   
%loop through each row of the in data which is "missing"
for i = 1:length(indRest)  
   %find indices of real numbers in each row of the in data to be averaged:
   ind = find(isfinite(data_in(indRest(i),:)));
   
   if ~isempty(ind)                                          %if there is some in data that is good,
       data_out(indRest(i)) = mean(data_in(indRest(i),ind)); %average it
       n_out(indRest(i))    = length(ind); 
   elseif ~isempty(data_fill)                                %if no in data is good,
       ind = find(isfinite(data_fill(indRest(i),:)));        %select fill data in that row which is not missing
       if ~isempty(ind)                                      %if there is some fill data that is good,
           %'calibrate' fill data to the in data
           if avg_period ~= 0
               % setup moving window or averaging period.  The window is
               % centered around the missing value if avg. period is less
               % than the distance the missing value is from the start or
               % end of indRest.  Otherwise the window is twice the avg.
               % period. Sep-21-2004 (crs)
               
%                if indRest(i)-step_data < 1
%                    right_side = min([2*step_data length(indRest)]);
%                    left_side  = 1;
%                elseif indRest(i)+step_data > length(indRest)
%                    left_side = max([1 indRest(i)-2*step_data]);
%                    right_side = length(indRest);
%                else
%                    left_side = indRest(i)-step_data;
%                    right_side = indRest(i)+step_data;
%                end
              
               
                %April 30, 2009---- Nick fixed bugs in the above code -------------
               if indRest(i)-step_data < indRest(1) % should be indRest(1) not 1
                   right_side = min([2*step_data indRest(end)]); % should be indRest(end) not 1
                   left_side  = indRest(1); % should be indRest(1) not 1
               elseif indRest(i)+step_data > indRest(end) % should be indRest(end) not length(indRest)
                   left_side = max([indRest(1) indRest(i)-2*step_data]); % should be indRest(1) not 1
                   right_side = indRest(end);    % should be indRest(end) not length(indRest)
               else
                   left_side = indRest(i)-step_data;
                   right_side = indRest(i)+step_data;
               end
               % ---------------------------------------------------------
               
               
               ind_reg = left_side:right_side;
               ind_nan = find(~isnan(data_out(ind_reg)) & ~isnan(sum(data_fill(ind_reg,ind),2)));
               
               % set up for regression imputation
               X = mean(data_fill(ind_reg,ind),2);
               Y = data_out(ind_reg);
               ind_good = find(~isnan(X) & ~isnan(Y));
               X = X(ind_good);
               Y = Y(ind_good);
               
               % check to see if X and/or Y is all zeroes
               check_data_out = unique(X);
               check_data_fill = unique(Y);
               if length(check_data_out) == 1 & check_data_out(1) == 0 %#ok<*AND2>
                   ind_nan = 0; % this will turn off the regression
               end
               if length(check_data_fill) == 1 & check_data_fill(1) == 0
                   ind_nan = 0; % this will turn off the regression
               end

               if length(ind_nan)>2
                   a = linreg(X,Y);
                   data_out(indRest(i)) = a(2) + a(1) .* mean(data_fill(indRest(i),ind),2);
               elseif length(ind_nan) <= 2
                   data_out(indRest(i)) = mean(data_fill(indRest(i),ind));
               end
           else
               data_out(indRest(i)) = mean(data_fill(indRest(i),ind)); 
           end
      else                                                   %if no fill data is good for that row,
         data_out(indRest(i)) = NaN;                         %then fill with NaN
      end
      n_out(indRest(i)) = -1;       
   end        
end
flag = n_out;