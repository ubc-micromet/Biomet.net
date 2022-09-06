function [xsum,xmean,OrigIntervals] = bio_daily_avg(tx,cx_mat,td,interval_days)

[n,m] = size(cx_mat);
xsum = [];
xmean = [];
for i=1:m
    ind = find(~isnan(cx_mat(:,i)) & cx_mat(:,i)~=1e38);
    [xsum1,xmean1,OrigIntervals1] = integz1(tx(ind),cx_mat(ind,i),td,interval_days);
    xsum = [xsum xsum1(:)];
    xmean = [xmean xmean1(:)];
end
OrigIntervals = OrigIntervals1;
