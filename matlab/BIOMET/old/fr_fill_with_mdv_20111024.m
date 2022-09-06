function [x_filled,x_avg,x_std,mdv,ind_filled,ind_not_filled] = fr_fill_with_mdv(x_org,cyc_length)
% [x_filled,x_avg,x_std,mdv,ind_filled] = fr_fill_with_mdv(x,cyc_length)
% 
% Filling with mean diurnal variation
%
% Inputs:
% x 			- halfhourly data, length must be a multiple of 48
% cyc_lenth - No. of days the average is taken over
% Outputs:
% x_filled	- NaNs in variable x are filled with mean diurnal courses of over 
% 				  cyc_length days centered around the current day. 
% x_avg 		- Averages used to fill x_filled.
% x_std		- Standard variation of x_avg, i.e. the std of the corresponding
% 				  half hour of cyc_length days arround the current day.
% mdv			- mean dirunal variation. size(mdv) = [floor(length(x)/48),48]
% ind_filled		- indices of NaNs filled.
% ind__not filled	- indices of NaNs that could not be filled.

% Revisions:  
% May 22, 2003 - Repeat 5 days at beginning and end of trace to cover periods without data at endpoints, E.Humphreys
%				

len_x = length(x_org);
x = x_org(1:48*floor(len_x/48)); % Here the end is shaved off x
x_cyc = reshape(x,48,floor(len_x/48))';
x_cyc = [x_cyc(1:5,:); x_cyc; x_cyc(end-5:end,:)];  %We add on 5 days to front and end of cycle to cover end-periods
[x_avg, ind_avg, x_std]= runmean(x_cyc,cyc_length,1);

%remove extra days
x_avg = x_avg(6:end-6,:);
x_std = x_std(6:end-6,:);

mdv = x_avg(floor(cyc_length/2):cyc_length:end,:);

x_avg = x_avg';
x_avg = x_avg(:);

x_std = x_std';
x_std = x_std(:);

x_filled = x_org;
ind_filled = find(isnan(x) & ~isnan(x_avg));
x_filled(ind_filled) = x_avg(ind_filled);

ind_not_filled = [find(isnan(x) & isnan(x_avg)); find(isnan(x_org(48*floor(len_x/48)+1:end)))];

% Return the shaved off end
missing_in_avg = NaN.*zeros(length(x_org)-length(x_avg),1);
x_avg = [x_avg; missing_in_avg];
x_std = [x_std; missing_in_avg];

return
