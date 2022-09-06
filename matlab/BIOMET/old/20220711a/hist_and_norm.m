function [x_mean,x_std,Nsum] = hist_and_norm(x,no_bars);
% HIST_AND_NORM Plots a histogram and a correspoing normal distribution
%    HIST_AND_NORM(X) plots a histogram of the data using 10 bins and 
%    on top of that plots a normal distribution with the same mean and 
%    standard devitation scaled to the number of observations in x.
% 
%    HIST_AND_NORM(X,M) uses M bins in the plot of the histogram.
%
%    [MEAN,STD,N] = HIST_AND_NORM(X,M) also returns the mean, standard 
%    deviation and the number of observations.
%
%    See also HIST

if ~exist('no_bars') | isempty(no_bars)
   no_bars = 10;
end

ind = find(~isnan(x));
x_mean = mean(x(ind));
x_std  = std(x(ind));

[N,X] = hist(x,no_bars);
dX = mean(diff(X));
Nsum = sum(N);
X = (x_mean - 5.*x_std):dX/5:(x_mean + 5.*x_std);

norm_dist_x = sum(N)./(x_std*sqrt(2*pi)) .* exp(- ((X-x_mean)./x_std).^2./2) .* dX;

% Plot
hist(x,no_bars);
hold on
plot(X,norm_dist_x,'r-');
axis([x_mean-5.*x_std x_mean+5.*x_std 0 1.25*max([max(norm_dist_x) N])]);

if nargout == 0
	text(x_mean+2.*x_std,    max([max(norm_dist_x) N]),['\mu = ' num2str(x_mean)]);
   text(x_mean+2.*x_std,0.8*max([max(norm_dist_x) N]),['\sigma = ' num2str(x_std)]);
end

hold off

