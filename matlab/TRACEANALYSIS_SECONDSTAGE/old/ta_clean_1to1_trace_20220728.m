function [x_filtered,y_filtered, p1, p2, slopeCoeff,thresholdFilter]= ta_clean_1to1_trace(x_org,y_org,stdMultiplier,slopeGuess,flagVerbose)
%
% For given 1:1 traces (two traces that are known to be linearly dependand)
% this program will find the outliers that are more than stdMultiplier
% times further away from the 1:1 line than the standard deviation of the
% 1:1 fit residuals. 
%
% NOTE:
%     - The program is designed to work assuming that both traces are being 
%       continuously and that the only thing that matters for this cleaning 
%       is whether they agree or not.  The most important consenquence is that, 
%       if one traces is missing (full of Nans or zeros), the other trace 
%       *will be wiped* too!
%     - Given the above a robust way to clean data using this program would
%       be to:
%           - run this program only if both traces have more than 90% of
%             not-nan values (data coverage> 90%)
%           - first do the regular cleaning (remove bad data and interpolate the small
%             gaps).
%           - then, if there are redundant sensors, do the data averaging
%           - then run this program
%     - if there are two complete (low data loss) data sets (like when measuring climate 
%       variables like PPFD vs Solar) then just running this program will
%       remove all questionable points while leaving small(ish) gaps that can easily 
%       be interpolated over.
%     - Another application of this program is to run it to find the best linear fit
%       coefficients. Then the coefficents can be used for gapp filling as needed.
%
%
% Inputs:
%  x_org            - first trace
%  y_org            - second trace
%  stdMultiplier    - the sigma(resudues) multiplier
%  slopeGuess       - the expected 1:1 slope (if known, otherwise use the actual slope for
%                     x_org:y_org
%  flagVerbose      - ==0 when no screen printout is desired
%
% Outputs:
%   x_filtered      - same as x_org with the filtered points replaced with NaNs
%   y_filtered      - same as y_org with the filtered points replaced with NaNs
%   p1              - original line fit coeffs
%   p2              - new line fit coeffs
%   slopeCoeff      - same as p2(1)
%   thresholdFilter - threshold used to remove the outliers
%
%
% Zoran Nesic                       File created:       May 6, 2020
%                                   Last modification:  May13, 2020

%
% Revisions:
%
% May 13, 2020 (Zoran)
%      - cosmetic changes (moved printing to the end of the functions)

arg_default('stdMultiplier',1);   % remove residuals that are > stdMultipliers * sigma (error)
arg_default('slopeGuess',0);      % if slopeGuess does not exist or unknown, use the "raw-data" slope
arg_default('flagVerbose',0);     % by default don't print the results

indNotNaN = find(~isnan(x_org) & ~isnan(y_org));
x = x_org(indNotNaN);               % for linear fits use only not-nans
y = y_org(indNotNaN);               % for linear fits use only not-nans

% Calculate the fit using the original data to use it as reference;
p1=polyfit(x,y,1);

if slopeGuess == 0
    slopeCoeff = p1(1);                                 % Use the current slope as the best fit 
else
    slopeCoeff = slopeGuess;                            % or use the user's best guess
end

residualError = abs((x*slopeCoeff-y) ) ;                % calculate residual error of fit (asume 1.9 gain)
thresholdFilter = stdMultiplier * std(residualError);   % calculate the filter threshold 
ind =  abs((x*slopeCoeff-y))< thresholdFilter;          % find index of "good" points
p2 = polyfit(x(ind),y(ind),1);                          % find linear fit to the good data

    
% prepare the output data
x_filtered = NaN(size(x_org));
y_filtered = NaN(size(y_org));
x_filtered(indNotNaN(ind)) = x(ind);
y_filtered(indNotNaN(ind)) = y(ind);


if flagVerbose > 0
    fprintf('Using initial slope fit = %6.2f\n',slopeCoeff);
    fprintf('Filtering residual errors larger than %6.2f (%d * sigma(residual_err))\n',thresholdFilter,stdMultiplier);
    fprintf('Fits before y = %6.2f*x + %6.2f\n',p1)
    fprintf('Fits after  y = %6.2f*x + %6.2f\n',p2');
    fprintf('Good points N = %d (of %d; %3.1f%%)\n',sum(ind),length(ind),sum(ind)/length(ind)*100);
end



