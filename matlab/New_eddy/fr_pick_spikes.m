function [spike, y, y_mean, y_std] = fr_pick_spikes(x,o,bp,limit,thold)
% fr_pick_spikes.m  Program which identifies spikes
%
% x: input trace
% o: 'l' for linear interp (not statistically correct), 'c' for block avg
% bp: vector of intervals for averaging  needs to be evenly spaced
% limit: std limit for a spike to be selected
% thold: diff limit for a spike to be selected
%

%E.Humphreys  23.03.01
%Revisions:  Oct 12, 2002 - Elyn changed no spike output from NaN to []

if nargin < 2, o  = 1; end
if nargin < 3, bp = 0; end

n = size(x,1);
if n == 1,
  x = x(:);			% If a row, turn into column vector
end
N = size(x,1);
ind = find(bp <= N);
tbp = bp(ind); clear bp;
bp  = tbp; clear tbp;

switch o
case {0,'c','constant'}
  bp = unique([0;bp(:);N]);	% Include both endpoints
  lb = length(bp)-1;
  y_mean  = [zeros(N,1)];	% Build running mean
  y_std = [zeros(N,1)];
  for kb = 1:lb
     y_mean((bp(kb)+1:bp(kb+1))) = mean(x(bp(kb)+1:bp(kb+1))); %find
 end
 y      = x - y_mean;		% Remove best fit
 
 if length(bp) <= 2; %ie. no bp
    y_std = sqrt(sum((y.^2)./(N-1)));
 else
    for kb = 1:lb
       tmp = diff(bp);
       y_std((bp(kb)+1:bp(kb+1))) = sqrt(sum((y(bp(kb)+1:bp(kb+1)).^2)./(tmp(kb)-1))); %find 'running' std deviation
    end
 end

case {1,'l','linear'}
  bp = unique([0;bp(:);N-1]);	% Include both endpoints
  lb = length(bp)-1;
  a  = [zeros(N,lb) ones(N,1)];	% Build regressor with linear pieces + DC
  y_std = [zeros(N,1)];
  for kb = 1:lb
    M = N - bp(kb);
    a([1:M]+bp(kb),kb) = [1:M]'/M;
 end
 y_mean = a*(a\x);
 y      = x - y_mean;		% Remove best fit
 
 if length(bp) <= 2; %ie. no bp
    y_std = sqrt(sum((y.^2)./(N-1)));
 else
    for kb = 1:lb
       tmp = diff(bp);
       y_std((bp(kb)+1:bp(kb+1))) = sqrt(sum((y(bp(kb)+1:bp(kb+1)).^2)./(tmp(kb)-1))); %find 'running' std deviation
    end
 end
 
 
otherwise
  % This should eventually become an error.
  warning(['Invalid trend type ''' num2str(o) '''.. assuming ''linear''.']);
  y = detrend(x,1,bp); 

end

tmp = find(abs(y) - limit.*y_std > 0);

if ~isempty(tmp);
   dspike = [NaN; diff(tmp)]; %ensure 2 pts aren't considered spikes
   ind = find(dspike ~= 1);
   tmpspike = tmp(ind);
   
   %ensure spikes are over a certain threshold
   diffx1 = [NaN; diff(x)];
   diffx2 = [x(1:end-1)-x(2:end); NaN];
   ind   = find(abs(diffx1(tmpspike)) > thold & abs(diffx2(tmpspike)) > thold);
   spike = tmpspike(ind);
else
   spike = [];
end



if n == 1
  y = y.';
end
