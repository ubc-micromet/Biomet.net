function [out97,out98] = montana98_daily_avg

load \\boreas_006\c\eva\fluxnet\cd\cd_traces97.dat
CD_traces = cd_traces97;
[n,m] = size(CD_traces);
[xsum97,xmean97,OrigIntervals97] = bio_daily_avg(CD_traces(:,2),CD_traces(:,3:m),1:366,1);
out97 = [1997*ones(length(OrigIntervals97),1) OrigIntervals97(:) xmean97];
save \\boreas_006\c\eva\fluxnet\cd\CR_daily_avg97.dat out97 -ascii

load \\boreas_006\c\eva\fluxnet\cd\cd_traces98.dat
CD_traces = cd_traces98;
[xsum98,xmean98,OrigIntervals98] = bio_daily_avg(CD_traces(:,2),CD_traces(:,3:m),1:366,1);
out98 = [1998*ones(length(OrigIntervals98),1) OrigIntervals98(:) xmean98];
save \\boreas_006\c\eva\fluxnet\cd\CR_daily_avg98.dat out98 -ascii

