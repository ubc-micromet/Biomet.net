function [output,RJdata]=RunStdDev(data,wlen,thres,RJdata,tv,varStruct)

% This function is designed for removing spikes in the time series.

% Parameters
% data: time series to be checked
% wlen: window length. The value represents the amount used for calcualtion
%       of std and mean.
% thres: threshold for rejecting outlier. 

for i=1:size(data,2)
    dat_p=data(:,i);    
    var=varStruct(i).name;
    
    % calculate start and end positions
    Pst=wlen/2+1;
    Ped=length(dat_p)-(wlen/2);
    
    vt=0:Ped-Pst;                       % create vertical index
    hz=repmat([1:wlen+1],length(vt),1); % create horizontal index
    pm=vt'+hz;                          % create position matrix
    
    % calculate mean and std for each window
    g=dat_p(pm);           % grouped data
    
    target=g(:,wlen/2+1);  
    target_p=pm(:,wlen/2+1);
    
    g(:,wlen/2+1)=[];
    pm(:,wlen/2+1)=[];
    
    gstd=nanstd(g,[],2);   % group standard deviation
    gavg=nanmean(g,2);   
    g_low=gavg-thres*gstd;
    g_up=gavg+thres*gstd;
    
    rj0=find(target<g_low| target>g_up);
    rj=target_p(target<g_low| target>g_up);
    
    
    VarName=repmat(string(var),length(rj),1);
    PID=[1:length(rj)]';    
    timestamp=string(tv(rj,:));
    RJval=target(rj0,:);
    UpperBound=g_up(rj0,:);
    LowerBound=g_low(rj0,:);
    PreV=target(rj0-1,:);
    NxtV=target(rj0+1,:);
    Threshold=repmat(thres,length(rj),1);
    Window_len=repmat(wlen,length(rj),1);
    
    rj_all=table(VarName,PID,timestamp,RJval,LowerBound,UpperBound,...
        PreV,NxtV,Threshold,Window_len);
    rj_all.Properties.VariableNames={'VarName','PID','timestamp','value',...
        'LowerBound','UpperBound','PreviousValue','NextValue','Threshold','Window_len'};
    
    RJdata=[RJdata;rj_all];
    dat_p(rj)=NaN;
    output(:,i)=dat_p;
end
