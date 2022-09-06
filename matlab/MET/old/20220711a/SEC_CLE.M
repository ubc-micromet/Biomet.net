function second_clean = sec_cle(data,k);
%-------------------------------------------------------------------------------%
% SECOND-ORDER CLEANING PROCEDURE TO REMOVE NOT SO OBVIOUS ERRONEOUS DATA       %
% DATA IS INTERPOLATED DURING PERIODS WHEN DATA ARE REJECTED                    %
% DATA IS REJECTED BASED ON THE DERVIATIVE OF THE PLOT EXCEEDING +/- K TIMES    %
% THE STANDARD DEVIATION OF THE DERVATIVE                                       %
% (see clean_data for first-order cleaning - suggest this routine is run first) %
%                                                                               %
%   function second_clean = sec_cle(data,k)                                %
%   INPUT                                  %
%         data - data to be cleaned                                             %
%         k - remove k times the standard deviation (suggest k = 2)             %
%-------------------------------------------------------------------------------%                                                                               

ind = find(~isnan(data));
mu = mean(data(ind));
sigma = std(data(ind));

e = ones(1,length(data(ind)))';
outliers = abs(data(ind) - e*mu) > k*e*sigma;
data(any(outliers'),:) = [];
second_clean = data;
