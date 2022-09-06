function [x_filled,ind_missing,ind_not_missing, x_all, a_fit, t_fit] = fr_fill_with_fitted(x_org,cyc_length, fun , linear_flag, param, options, varargin)
% fr_fill_with_fitted(x,cyc_length)
% 
% Filling with fitted in-line function to cyc_length
%
% Inputs:
% x 			- halfhourly data, length must be a multiple of 48
% cyc_lenth   - No. of days the average is taken over
% linear_flag - if = 0, use fr_fit_function otherwise use polyfit to the nth order (where linear_flag = n)
% Outputs:
% x_filled	- NaNs in variable x are filled with mean diurnal courses of over 
% 				  cyc_length days centered around the current day. 
% ind_filled		- indices of NaNs filled.
% ind__not filled	- indices of NaNs that could not be filled.

%	Sept 27, 2003  E.Humphreys			

if ~exist('options') | isempty(options);
   options = optimset('maxiter', 10^5, 'maxfunevals', 10^5, 'tolx', 10^-3);
end

len_x = length(x_org);

x_filled = x_org;
x_all    = NaN.*ones(size(x_org));

tv = [1:1:length(x_org)]'./48;

ind_not_missing = find(~isnan(x_org));
ind_missing = find(isnan(x_org));
%ind_missing_by_day = fix(ind_missing./48);
%ind_missing_by_day = unique(ind_missing_by_day);
ind_day = unique(fix(tv));

%make varargin into matrix for indexing (up to 4 variables at this point)
vars = zeros(length(x_org),4);
for j = 1:length(varargin);
   vars(:,j) = varargin{j};
end


for i = 1:length(ind_day);
   ind_good = find(tv >= ind_day(i) - cyc_length./2 & tv <= ind_day(i) + cyc_length./2 & ...
      ~isnan(x_org) & ~isnan(vars(:,1)) & ~isnan(vars(:,2)) & ~isnan(vars(:,3)) & ~isnan(vars(:,4)));
   
   if ~isempty(ind_good) ;
      
      for j = 1:length(varargin);  %ind y values
         tmp = varargin{j};
         tmp = tmp(ind_good);
         new_varargin(j) = {tmp};
      end      
      
      %fit model
      if linear_flag == 0; %use fr_function_fit for non-linear models
         [a_fit(i,:),fval,output,exitflag] = fr_function_fit(fun,param,x_org(ind_good),options, new_varargin{:});
      else %use polyfit for linear models 
         [a_fit(i,:)] = polyfit(x_orig(ind_good), new_varargin{:}, linear_flag);
      end      
      time_fit(i,:) = tv(ind_good(1));
      samples_fit(i, :) = length(ind_good);
      
      if exitflag == 1 %proceed if FR_FUNCTION_FIT converged with a solution PARAM
         
         %create trace with only modelled data
         ind_good_all = find(tv >= ind_day(i) & tv < ind_day(i)+1 & ...
            ~isnan(vars(:,1)) & ~isnan(vars(:,2)) & ~isnan(vars(:,3)) & ~isnan(vars(:,4)));            
         for j = 1:length(varargin);  %ind y values
            tmp = varargin{j};
            tmp = tmp(ind_good_all);
            new_varargin(j) = {tmp};
         end  
         if linear_flag == 0;
            x_all(ind_good_all) =fun(a_fit(i,:), new_varargin{:});
         else
            x_all(ind_good_all) =polyval(a_fit(i,:), new_varargin{:});
         end          
         
         %fill in missing values
         ind_to_fill = find(tv >= ind_day(i) & tv < ind_day(i)+1 & isnan(x_org));
         
         for j = 1:length(varargin);  %ind y values
            tmp = varargin{j};
            tmp = tmp(ind_to_fill);
            new_varargin(j) = {tmp};
         end      
         
         
         if ~isempty(ind_to_fill);
            if linear_flag == 0;
               x_filled(ind_to_fill) =fun(a_fit(i,:), new_varargin{:});
            else
               x_filled(ind_to_fill) =polyval(a_fit(i,:), new_varargin{:});
            end            
         end
         
      end
      
   end
   
   
end


