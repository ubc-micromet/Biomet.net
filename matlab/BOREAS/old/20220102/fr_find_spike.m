function [spike_ind] = fr_find_spike(x,N,threshold_coef, threshold_const)

if (~exist('threshold_const') | isempty(threshold_const)) & ...
    (~exist('threshold_coef') | isempty(threshold_coef))
    threshold_coef = 3;
    threshold_const = 0;
elseif (~exist('threshold_const') | isempty(threshold_const))
    threshold_const = 0;
elseif     (~exist('threshold_coef') | isempty(threshold_coef))    
    threshold_coef = 0;
end




%x1 = [mean(x(2)) x mean(x(end-1))];%
%N=1;
%q = [ones(1,N) -ones(1,N)]/2/N;          % haar wavelet
q = [ones(1,N) -ones(1,N)]/N;             % haar wavelet

diff1 = filter(q,1,x);                   % input data filtering
plot(diff1)
%diff1 = diff(x1);                       %find differences
sigma = std(diff1);                      %find total STD of differences
th = threshold_const + threshold_coef*sigma;
ind1 = find(abs(diff1)>= th);
if (abs(diff1(end)) >= th) & ...
        abs(diff1(end-1)) < th
    ind1 = [ind1 length(diff1)+1];
end
                                        %find indexes of all diff. that exceed threshold * STD
ind2 = find((diff(ind1) - N)==0);       % find indexes of all consecutive diff1 that esceed the treshold
spike_ind= ind1(ind2) - N +1;

