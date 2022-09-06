function sig_level = stat_difference(d1,d2)
% Check whether two datasets or two traces statistically significant differ
% by way of the student's t distribution (two-tailed). 
% as a null hypothesis suggest that the mean value of the difference equals 0.
% this null hypothesis is rejected if not true (providing the significance level
% at which it is rejected).
% important: - difference of corresponding data points must follow normal distribution
%            - corresponding datasets must be connected (e.g. via time trace)
%              and of same length
%
% sig_level = signif_difference(d1,d2)
% 
% Inputs:
% d1,d2: data-arrays
% 
% Output:
% sig_level: significance level of difference in dataset (%)
%
% natascha kljun, august 6, 2002

% remove NaN's from dataset
ind1    = find(isnan(d1));
ind2    = find(isnan(d2));
ind_nan = union(ind1,ind2);
ind     = setdiff(1:length(d1),ind_nan);

diff_d    = d1(ind)-d2(ind);
e_diff    = 0;
ttest     = (mean(diff_d) - e_diff)./ (std(diff_d)./sqrt(length(diff_d)));
sig_level = students_distribution(ttest,length(diff_d)-1)*100;

if sig_level >= 95.0 
   ['difference in dataset is statistically significant (', ...
     num2str(sig_level),'%-level)']
elseif sig_level < 95.0
   'difference in dataset is NOT statistically significant'
end

% example:
% 1.96 for 95%, 2.241 for 97.5%, 2.576 for 99%, 3.291 for 99.9%,(two-tailed), n>1000
% 1.962 for 95%, 2.581 for 99%, 3.300 for 99.9%, (two-tailed), n=1000
% 1.965 for 95%, 2.586 for 99%, 3.310 for 99.9%, (two-tailed), n=500

return