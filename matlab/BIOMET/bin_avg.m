function [x_bin,y_bin] = bin_avg(x, y, bin, stats)
%BIN_AVG   Calculate averages and other stats for binned data
%   BIN_AVG(X,Y,BIN) returns averages of Y after binning the data into bins 
%   containing BIN number of points if BIN is a scalar. If BIN is a vector 
%   it is assumed to contain the bin margins to be used in the binning.
%
%   [X_BIN,Y_BIN] = BIN_AVG(X,Y,BIN) returns X as well as Y averages 
%
%   [X_BIN,Y_BIN] = BIN_AVG(X,Y,BIN,STAT) returns statistics as requested in
%   STAT (1 = mean, 2 = std, 3 = se, 4 = sum, 5 = n, 6 = median, 7 = min, 
%   8 = max, 9 = x stats), e.g. for [X_BIN,Y_BIN] = BIN_AVG(X,Y,BIN,[1 2 3 5])
%   returns mean, standard deviation, standard error, and the number of 
%   elements in each bin for in Y_BIN([1 2 3 4],:) and averages in X_BIN. 
%   [X_BIN,Y_BIN] = BIN_AVG(X,Y,BIN,[1 2 3 8 9]) also returns the same stats 
%   for X in X_BIN.
%

% (c) kai* Dec 12, 2002
% Revisions: 

if nargin<3
   error('Not enough input arguments');   
end

arg_default('stats',1);

ind_notnan = find(~isnan(x) & ~isnan(y));

if length(ind_notnan) < bin
   bin_old = bin;
   bin = floor(length(ind_notnan)/(length(x)/bin));
   disp(sprintf('Not enough non-nan points to use BIN = %i',bin_old));
   disp(sprintf('Using BIN = %i instead',bin));
end 

x = x(ind_notnan);
y = y(ind_notnan);

[x_sorted,ind_sort] = sort(x);

%---------------------------------------------------------------------------------
% Determine transition between bins
%---------------------------------------------------------------------------------
if length(bin) == 1;
   %bin by groups of data of length bin
   bin_no  = floor(length(x_sorted)/bin);
   bin_beg = 1:bin:(bin_no+1)*bin;
else
   %bin by limits on x data
   bin_no = length(bin)-1;
   for i = 1:bin_no;
      bin_ind = find(x_sorted >= bin(i) & x_sorted < bin(i+1));
      if ~isempty(bin_ind)
         bin_beg(i) = min(bin_ind);
      else
         if i ~= 1
             bin_beg(i) = bin_beg(i-1);
         else
             bin_beg(i) = 1;
         end    
      end
   end
   bin_ind = min(find(x_sorted>=bin(i+1)));
   if ~isempty(bin_ind)
      bin_beg(i+1) = min(bin_ind);
   else
      bin_beg(i+1) = bin_beg(i);
   end
end
n = bin_beg(end) - bin_beg(1);
bin_len = bin_beg(2:end)-bin_beg(1:end-1);
bin_len_dim = [bin_len' bin_len'] ;

%---------------------------------------------------------------------------------
% Do statistics from cumulated variables
%---------------------------------------------------------------------------------
data = [x_sorted y(ind_sort)];

% Mean
data_sum = [[0 0]; cumsum(data)];
data_bin(1,:,:) = (data_sum(bin_beg(2:end),:) - data_sum(bin_beg(1:end-1),:))./bin_len_dim;

% Std
data2_sum = [[0 0];  cumsum(data.^2)];
data_bin(2,:,:) = (data2_sum(bin_beg(2:end),:) - data2_sum(bin_beg(1:end-1),:))./bin_len_dim;
data_bin(2,:,:) = sqrt(bin_len_dim./(bin_len_dim-1).*squeeze(data_bin(2,:,:) - data_bin(1,:,:).^2));

% SE
data_bin(3,:,:) = squeeze(data_bin(2,:,:))./sqrt(bin_len_dim);

% Sum
data_bin(4,:,:) = data_sum(bin_beg(2:end),:)-data_sum(bin_beg(1:end-1),:);

%N
data_bin(5,:,:) = bin_len_dim;

%---------------------------------------------------------------------------------
% Sort y data for Median and Min/Max
%---------------------------------------------------------------------------------
if ~isempty(find(stats>5))
   
   for i = 1:bin_no;
      data(bin_beg(i):bin_beg(i+1)-1,2) = sort(data(bin_beg(i):bin_beg(i+1)-1,2));
   end
   
   % Median
   ind_odd  = find(rem(bin_len,2) == 1);
   ind_even = find(rem(bin_len,2) == 0);
   if ~isempty(ind_odd)
      data_bin(6,ind_odd,:)  =  data( bin_beg(ind_odd)  + (bin_len(ind_odd)-1)./2 ,:);
   end
   if ~isempty(ind_even)
      data_bin(6,ind_even,:) = (data( bin_beg(ind_even) + bin_len(ind_even)./2,:) ...
         + data( bin_beg(ind_even) + bin_len(ind_even)./2 - 1,:))./ 2;
   end
   
   % Min
   data_bin(7,:,:) = data(bin_beg(1:end-1),:);
   % Max
   data_bin(8,:,:) = data(bin_beg(2:end)-1,:);
end

%---------------------------------------------------------------------------------
% Take care of zero length bins
%---------------------------------------------------------------------------------
ind = find(bin_len == 0);
data_bin([1:4 6:8],ind,:)=NaN;

%---------------------------------------------------------------------------------
% Arrange output as requested
%---------------------------------------------------------------------------------
no_x_stats = isempty(find(stats==9));
stats_y = stats(find(stats~=9));

y_bin = squeeze(data_bin(stats_y,:,2))';
if nargout == 1
   x_bin     = y_bin;
else
   if no_x_stats
	   x_bin = squeeze(data_bin(1,:,1))';
   else
	   x_bin = squeeze(data_bin(stats_y,:,1))';
   end
end

