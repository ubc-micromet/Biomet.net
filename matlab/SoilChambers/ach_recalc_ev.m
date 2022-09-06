function [evNew] = ach_recalc_ev(clean_tv,ev)

%--------------------------
%Normal procedure to follow
%--------------------------

evNew = ev;

%smooth effective volume signal by running a two-week moving window (time step 1 day)
[evNew,indNew] = runmean(evNew,14*48,1);
[clean_tvNew,indNew] = runmean(clean_tv,14*48,1);

%interpolate between good points
ind_nan_ev = find(isnan(evNew));        % find index for bad points
ind_not_nan_ev = find(~isnan(evNew));   % find index for good points
evNew(ind_nan_ev) = interp1(clean_tv(ind_not_nan_ev),...
                             evNew(ind_not_nan_ev),...
                             clean_tv(ind_nan_ev));


%fill remaining gaps (beginning and end of year) with first and last good points                         
ind_nonan_ev = find(~isnan(evNew));
evNew(1:ind_nonan_ev(1)-1) = evNew(ind_nonan_ev(1));                         
evNew(ind_nonan_ev(end)+1:end) = evNew(ind_nonan_ev(end));                         
                         
%fill remaining gaps (beginning and end of year) with mean of good points                         
% ind_nan_ev = find(isnan(evNew));
% ind_nonan_ev = find(~isnan(evNew));
% evNew(ind_nan_ev) = mean(evNew(ind_nonan_ev));




