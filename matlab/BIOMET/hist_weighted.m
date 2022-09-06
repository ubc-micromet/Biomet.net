function nn1 = hist_weighted(mainVar,weightingVar,bins)
% hist_weighted Weighted histogram count.
%   nn1 = hist_weighted(mainVar,weightingVar,bins) for vector mainVar
wBar = mean(weightingVar);
bins = bins(:)';
miny = min(min(mainVar));
maxy = max(max(mainVar));
binwidth = [diff(bins) 0];
bins = [bins(1)-binwidth(1)/2 bins+binwidth/2];
bins(1) = min(bins(1),miny);
bins(end) = max(bins(end),maxy);
nbin = length(bins);
% Shift bins so the internal is ( ] instead of [ ).
bins = full(real(bins)); mainVar = full(real(mainVar)); % For compatibility
bins = bins + max(eps,eps*abs(bins));
[nn,binInd] = histc(mainVar,[-inf bins],1);
    
nn1=NaN*ones(size(nn));
for i=1:length(nn);
    ind=find(binInd==i);
    nn1(i)=sum(weightingVar(ind)/wBar);
end

% Combine first bin with 2nd bin and last bin with next to last bin
nn1(2,:) = nn1(2,:)+nn1(1,:);
nn1(end-1,:) = nn1(end-1,:)+nn1(end,:);
nn1 = nn1(2:end-1,:);

