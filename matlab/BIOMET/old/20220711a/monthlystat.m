function [stats,x_avg,x_std,n,x_sum] = monthlystat(t,x);
%MONTHLYSTAT Monthly statistics 
%    [TMON,XAVG,XSTD,N] = MONTHLYSTAT(T,X) where T is a time vector of data 
%    and X is a corresponding variable, returns a time TMON and monthly 
%    average XAVG, standard deviation XSTD, and the number N of non-nan 
%    oberservations per month.
%
%    STAT = MONTHLYSTAT(T,X) returns a matrix containing monthly statisics 
%    in its rows. The columns contain a time value, sum, average, min, 
%    max, std, N for X>0, N, andthe median. This is especially for Elyn, 
%    but it may prove useful anyway.
%
%    See also FASTAVG and RUNMEAN

%------------------------------------------------------------------
% kai*       Oct 29, 2002
%
% Revisions: 
%------------------------------------------------------------------


% Find out how many years are in t
% To avoid problems because of the first element being yyyy1231:23:59:59
% or the last one being yyyy0101:00:00:01 use second and second to last 
% element

dv= datevec([t(2); t(end-1)]); 
yy = [dv(1,1):dv(2,1)+1];

% Find which of these are leap years
leap = datevec(datenum(yy(:),1,60)); % This will be either Mar 1 or Feb 29
ind_leap = find(leap(:,3) == 29);

% Create a matrix of days in month for leap years and all years
% Years are in colums
lastday_leap = [31 29 31 30 31 30 31 31 30 31 30 31]' * ones(1,length(ind_leap));
lastday      = [31 28 31 30 31 30 31 31 30 31 30 31]' * ones(1,length(yy)); 
lastday(:,ind_leap) = lastday_leap;

% Find next beginning of month from t(2)
dv= datevec(round(t(1)));
if dv(3) ~= 1
   dv(2) = dv(2) + 1;
end   
t_next_mon = datenum(dv(1),dv(2),1,0,30,0);
ind = find(round(t(1:32*48)*48)/48 == t_next_mon);

lastday = cumsum(lastday(dv(2):12*(length(yy)-1)+dv(2)-1))';

% Indices of beginning and end of month
ind_mon_end = ind-1 + (lastday).*48;
if ind_mon_end(end) > length(t)
   ind_mon_end(end) = length(t);
end
ind_mon_beg = [1; ind_mon_end(1:end-1)];

if nargout > 1
	%------------------------------------------------------------------
	% no min max median requested - fast calculation
	%------------------------------------------------------------------
   n = ind_mon_end - ind_mon_beg;
   
   % Treat NaNs correctly
   ind_nan = find(isnan(x));
   if any(ind_nan)
      ind_nan_sum = cumsum(isnan(x));
      n = n - ( ind_nan_sum(ind_mon_end)-ind_nan_sum(ind_mon_beg) );   
   end
   
   x(ind_nan) = 0;
	tsum  = [0; cumsum(t)];
	xsum  = [0; cumsum(x)];
   x2sum = [0; cumsum(x.^2)];
   
	x_sum = (xsum([ind_mon_end])-xsum([ind_mon_beg]));
   warning off; % because some n are likely 0
   x_avg = x_sum./n;
   x_std = sqrt((x2sum([ind_mon_end])-x2sum([ind_mon_beg]))./n - x_avg.^2); 
   stats = (tsum([ind_mon_end])-tsum([ind_mon_beg]))./(ind_mon_end - ind_mon_beg);
   warning on;
else
	%------------------------------------------------------------------
	% all statistics requested - slow calculation
	%------------------------------------------------------------------
   stats = NaN .* zeros(length(ind_mon_end),9);
   for i = 1:length(ind_mon_beg),
      tmp = find( t >=  t(ind_mon_beg(i)) &  t < t(ind_mon_end(i)) & ~isnan(x) );
      if ~isempty(x(tmp))
         stats(i,1) = mean(t(tmp));
         stats(i,2) = sum(x(tmp));
         stats(i,3) = mean(x(tmp));
         stats(i,4) = max(x(tmp));
         stats(i,5) = min(x(tmp));
         stats(i,6) = std(x(tmp));
         stats(i,7) = length(find(x(tmp) > 0));
         stats(i,8) = length(x(tmp));
         stats(i,9) = median(x(tmp));
      end
   end
end

return
         
         