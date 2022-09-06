function [xsum,xmean,OrigIntervals] = integz(tx,cx,td,days,reject)
%
%   [xsum,xmean,OrigIntervals] = integz(tx,cx,td,days)
%
%       tx      time vector in 1/48 parts per day
%       cx      data vector corresponding to tx
%       td      time vector in days
%       days    interval of integration in days (INTEGER) 
%       reject  the number of elements per averaging interval that
%               MUST be present so the average value can be calculated
%               (default if 24 => every day that has less then 24 valid
%                hhours will be rejected)
%
% (c) Zoran Nesic           File created:                 , 1996
%                           Last modification:      Jan  6, 1999
%
%Revisions:
%
%   Jan 6, 1999, Zoran 
%       - Added the "reject" parameter and its default value (24)
%       - saved integz1 as integz so that we have only one integration program
%   Jun 1, 1998, Zoran Nesic
%       -   changed:
%               OrigIntervals = st:days:ceil((ed-st+1)/days)*days;
%           to
%               OrigIntervals = st:days:st+ceil((ed-st+1)/days)*days;
%           to cover cases when st is NOT 1
%
%	Jan 14, 1998 by Bill Chen
%			-	change OrigIntervals, maxNonZeroTime, minNonZeroTime
%

disp('Warning: Use integz instead of integz1. The future versions')
disp('         of the Biomet software will not support integz1!')
disp('         At this time both versions are identical')

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
