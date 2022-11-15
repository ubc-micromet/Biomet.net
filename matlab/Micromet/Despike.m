function output=Despike(data,wlen,intv,thres)

% This function is designed for removing spikes in the time series.

% Parameters
% data:
% wlen: window length. The value represents the amount used for calcualtion
%       of std and mean.
% intv: the step for each window.
% thres: threshold for rejecting outlier. 

% Example
% despiked=RunStdDev(data,6,4,4)
% -> Every 6 points will be used for calcualting std and avg.

for i=1:size(data,2)
    dat_p=data(:,i);
    vt=1:intv:(length(dat_p)-wlen);     % create vertical index
    hz=repmat([1:wlen],length(vt),1); % create horizontal index
    pm=vt'+hz-1;   % create position matrix
    
    % calculate mean and std for each window
    g=dat_p(pm);       % grouped data
    Q_3=quantile(g',0.75)';
    Q_1=quantile(g',0.25)';
    IQR=Q_3-Q_1; % interquantile range
    
    g_low=Q_1-thres*IQR;
    g_up=Q_3+thres*IQR;
    
    g(g<g_low| g>g_up)=NaN;
    
    % ungroup data
    rejected=unique(pm(isnan(g)));
    despiked=dat_p;
    despiked(rejected)=NaN;
    
    % calculate the number of rejected data
    bNaN=find(isnan(dat_p));
    aNaN=find(isnan(despiked));
    fprintf(1,'[%d] Rejected: %d points\n',i,length(aNaN)-length(bNaN));
    output(:,i)=despiked;
end

