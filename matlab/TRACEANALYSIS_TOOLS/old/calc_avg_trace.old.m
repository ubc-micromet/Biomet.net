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
% (C) Kai Morgenstern				File created:  14.08.00
%									Last modified: 13.09.04

% Revision: Feb 2, 2002 - added an optional regression between data_in and data_fill 
%           to ensure similarity of results (E. Humphreys)
%           April 3, 2002 - added ability to do above regression on all present 
%           data up front: type in -1 for avg_period(E. Humphreys)
%           Oct 23, 2003 - skip regression application on data_fill if regression results are NaN
%           Sep 12, 2004 - bypass regression localization if less then 2
%           data points are available.  In this case default to taking the
%           average of the good points. (crs)

data_out = NaN * zeros(length(tv),1);		
n_out    = zeros(length(tv),1);	

if ~exist('data_fill','var')
   data_fill = [];
end 

if nargin < 4;
    avg_period = 0;                                %set averaging period to 0 (ie no 'calibrating')
end

step       = tv(end)-tv(end-1);                   %get data interval length
step_data  = floor(avg_period./step./2);

[mm nn] = size(data_in);								%get size of input matrix
indf = find(mean(isfinite(data_in),2) == 1);		%find rows with all real numbers
data_out(indf,:) = mean(data_in(indf,:),2);		%calculate mean of each of these rows.
n_out(indf) =  nn;										%set flag to length of each row


%Get the rest of the indices that contains non-real numbers: NaN, inf, -inf:
indRest = find(mean(isfinite(data_in),2) < 1);   

if avg_period == -1
    indf = find(mean(isfinite(data_fill),2) == 1);		%find rows with all real numbers
    data_fill(indf,1) = mean(data_fill(indf,:),2);		%calculate mean of each of these rows.
    indf = find(sum(isfinite(data_fill),2) < size(data_fill,2) & sum(isfinite(data_fill),2) > 0);
    for i = 1:length(indf); %go through each row and average available NaN
        data_fill(indf(i),1) = mean(isfinite(data_fill(indf(i),:)),2);
    end
    data_fill = mean(data_fill,2); %determine 1 average fill column
    ind = find(~isnan(data_out) & ~isnan(data_fill));
    a = linreg(data_fill(ind),data_out(ind)); %'calibrate' fill column to incoming data
    if ~isnan(a(1));
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
           if avg_period ~= 0;
               % setup moving window or averaging period.  The window is
               % centered around the missing value if avg. period is less
               % than the distance the missing value is from the start or
               % end of indRest.  Otherwise the window is twice the avg.
               % period. Sep-21-2004 (crs)
               if indRest(i)-step_data < 1
                   right_side = min([2*step_data length(indRest)]);
                   left_side  = 1;
               elseif indRest(i)+step_data > length(indRest)
                   left_side = max([1 indRest(i)-2*step_data]);
                   right_side = length(indRest);
               else
                   left_side = indRest(i)-step_data;
                   right_side = indRest(i)+step_data;
               end
                   
%               ind_reg = max([1 indRest(i)-step_data]):min([indRest(i)+step_data length(data_fill)]);
%               This was the old original window from Elyn --replaced Sep-15-2004 (crs)

               ind_reg = [left_side:right_side];
               ind_nan = find(~isnan(data_out(ind_reg)) & ~isnan(sum(data_fill(ind_reg,ind),2)));
               % check to see if data_out(ind_reg) is all zeroes
               check = unique(data_out(ind_reg));
               if length(check) == 1 & check(1) == 0
                   ind_nan = 0; % this will turn off the regression (crs: Oct 7 2004)
               end
               if length(ind_nan)>2
                   a = linreg(mean(data_fill(ind_reg,ind),2),data_out(ind_reg));
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