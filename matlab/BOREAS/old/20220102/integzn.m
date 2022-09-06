function [xsum,xmean,OrigIntervals] = integzn(tx,cx,td,days,reject)
% [xsum,xmean,OrigIntervals] = integzn(tx,cx,td,days,reject)
%
%       tx      time vector in 1/48 parts per day
%       cx      data vector corresponding to tx
%       td      time vector in days
%       days    interval of integration in days (INTEGER) 
%       reject  the number of elements per averaging interval that
%               MUST be present so the average value can be calculated
%               (default is 24 => every day that has less then 24 valid
%                hhours will be rejected)
%
% (c) Zoran Nesic           File created:           Jan 18, 1999
%                           Last modification:      Jan 18, 1999
%
%Revisions:
%

if nargin < 4
    days = 1;                                   % default interval of integration is 1 day
end
if ~exist('reject') | isempty(reject)
    reject = 24;
end
xsum =  zeros(1,ceil(length(td)/days));         % fill the output vectors with zeros
xmean = xsum;

st = min(td);                                   % find first
ed = max(td);                                   % and last time stamp
RoundTime = floor(tx);                          % get the integer time
ind = find(RoundTime>=st & RoundTime <= ed);    % find the time interval
tx = tx(ind);                                   % extract the time interval
cx = cx(ind);                                   % extract the data interval
RoundTime = RoundTime(ind);
XS = cumsum(cx);                                % calculate cumsum for the entire data set
indTmp = diff(RoundTime);                       % find change of dates
dayInd = [find(indTmp>=1) ;length(RoundTime)];  % index for each day
binInd = dayInd(days:days:end);                 % calculate new index that uses var days
binInd = binInd(:);                             % binInd is a column vector
xsum = XS(binInd);                              % extract cumsum results
xsum(2:end) = xsum(2:end)-xsum(1:end-1);        % calculate daily sums (in xsum)
Nind = [binInd(1);diff(binInd)];                % data points per day
xmean = xsum./Nind;
return
%OrigIntervals = st:days:ceil((ed-st)/days)*days;% create intervals of integration
OrigIntervals = st:days:st+ceil((ed-st+1)/days)*days;% create intervals of integration

indZero = find( cx ~= 0 );                      % find indexes for all cx ~= 0
%maxNonZeroTime = tx(max(indZero));
%minNonZeroTime = tx(min(indZero));
maxNonZeroTime = ceil(tx(max(indZero)));
minNonZeroTime = floor(tx(min(indZero)));

stNew = find(OrigIntervals >= minNonZeroTime );
stNew = min(stNew);
edNew = find(OrigIntervals <= maxNonZeroTime );
edNew = max(edNew);
NewIntervals = OrigIntervals(stNew):days:OrigIntervals(edNew);
len   = length(NewIntervals);

RoundTime = floor(tx);
k = 1;
for i=NewIntervals;
    ind = find( (RoundTime >=i) & (RoundTime <= i + days-1) );
    xsum(k) = sum(cx(ind));
    nn = length(ind);
    if nn > reject*days
        xmean(k) = xsum(k) / nn;
%    elseif k > 1
%        xmean(k) = xmean(k-1);
    else
%        xmean(k) = 0;
			xmean(k) = NaN;
	end
    k = k+1;
%    fprintf('%d',i);
end
%
% Fill up the non-existant data with NaN's
%
xmeanTmp = xmean;
xsumTmp = xsum;
xmean = NaN * zeros(size(OrigIntervals));
xsum = xmean;

xmean(stNew:stNew + len -1) = xmeanTmp(1:len);
xsum(stNew:stNew + len -1) = xsumTmp(1:len);
