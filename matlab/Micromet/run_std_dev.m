function data=run_std_dev(data,clean_tv,wlen,thres,verbose)

% This function is designed for removing spikes in the time series.

% Parameters
% data: time series to be checked
% wlen: window length. The value represents the amount used for calcualtion
%       of std and mean.
% thres: threshold for rejecting outlier. 

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

gstd=nanstd(g,[],2);   % group standard deviation
gavg=nanmean(g,2);     % group average
g_low=gavg-thres*gstd; % lower bound of the group
g_up=gavg+thres*gstd;  % upper bound of the group

rj=target_p(target<g_low| target>g_up); % find positions of data outside the range in the original array

if ~isempty(rj) && verbose~=0
    data(rj)=NaN;
    fprintf(1,'- %s: [run_std_dev] total=%d\n',s,length(rj));
    fprintf(1,' 。%s ',string(datestr(clean_tv(rj),TF)));
    fprintf(1, '\n');    
end


