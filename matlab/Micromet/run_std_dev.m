function [data, mov_avg, upper_lim, lower_lim]=run_std_dev(data,clean_tv,wlen,thres,verbose)

% This function is designed for removing spikes in the time series.

% Parameters
% data: time series to be checked
% wlen: window length. The value represents the amount used for calcualtion
%       of std and mean.
% thres: threshold for rejecting outlier. 

% Revision: 
% 
% Jun 5, 2024 (Paul)
% - outliers were only removed if verbose~=0
% May 2, 2023 (June)
%     nanstd and nanmean are depreciated
%     switched to std(__,'omitnan')

arg_default('verbose',0); % by default don't print anything
TF='yyyy/mm/dd HH:MM'; % time format
s = inputname(1);      % to identify which variable you are processing

% calculate start and end positions
Pst=wlen/2+1;
Ped=length(data)-(wlen/2);

vt=0:Ped-Pst;                       % create vertical index
hz=repmat([1:wlen+1],length(vt),1); % create horizontal index
pm=vt'+hz;                          % create position matrix
    
% calculate mean and std for each window
g=data(pm);           % grouped data

target=g(:,wlen/2+1);  
target_p=pm(:,wlen/2+1);

g(:,wlen/2+1)=[];
pm(:,wlen/2+1)=[];

% nanstd and nanmean are depreciated - don't work in 2022b 
% https://www.mathworks.com/help/stats/nanmean.html
gstd=std(g,[],2,"omitnan");
gavg=mean(g,2,"omitnan");
g_low=gavg-thres*gstd; % lower bound of the group
g_up=gavg+thres*gstd;  % upper bound of the group
rj=target_p(target<g_low| target>g_up); % find positions of data outside the range in the original array
if ~isempty(rj) % Originally had && verbose~0 which meant that the default arg would prevent outliers being removed
    data(rj)=NaN;

    if verbose~=0
        fprintf(1,'- %s: [run_std_dev] total=%d\n',s,length(rj));
        fprintf(1,' 。%s ',string(datestr(clean_tv(rj),TF)));
        fprintf(1, '\n');
    end
end

% Upper limit
upper_lim = nan(size(data));
upper_lim(target_p) = g_up;

% Lower limit
lower_lim = nan(size(data));
lower_lim(target_p) = g_low;

% Moving average
mov_avg = nan(size(data));
mov_avg(target_p) = gavg;
