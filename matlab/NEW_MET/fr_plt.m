function [avgs,stds,tmp]=fr_plt(dataIn,j,k)


if exist('k') ~= 1 | isempty(k)
    k = 1:length(dataIn);
end

if nargin < 2
    error('Not enough input parameters!');
end

tmp = dataIn(j,k)';
plot(k/21,tmp)
xlabel('(sec)')
zoom on
avgs = mean(tmp);
stds = std(tmp);
[avgs;stds]


