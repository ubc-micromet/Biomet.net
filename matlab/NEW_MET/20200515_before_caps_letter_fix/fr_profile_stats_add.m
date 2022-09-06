function Profile = fr_profile_stats_add(Profile,prOut, ind)
% fr_profile_stats_add - adds the Profile output structure to a larger structure (one hhour into many hhours)
%
%   Profile = fr_profile_stats_add(Profile,prOut, ind)
%
% Inputs
%       Profile         - Output structure of the Profile results for many hhours 
%       prOut           - profile calculation structure (one hhour) to be added to Profile
%       ind             - location of prOut within Profile
% Outputs
%       Profile         - output structure, returns all the cycle mins and maxes and the averages
%                         for a number of periods (hhours)
%
% (c) Zoran Nesic               File created:       Mar xx, 2001
%                               Last modification:  Aug  5, 2001
%

% Revisions:
%   Aug 5, 2001
%       - reduced the number of fields for the case when LI-800 i used
%         (needs the co2 field only)
%

Profile.co2.CycleAvg(:,:,ind) = prOut.co2.CycleAvg;
Profile.co2.CycleMax(:,:,ind) = prOut.co2.CycleMax;
Profile.co2.CycleMin(:,:,ind) = prOut.co2.CycleMin;
Profile.co2.CycleStd(:,:,ind) = prOut.co2.CycleStd;
Profile.co2.Avg(ind,:)        = prOut.co2.Avg;


% use try to avoid problems when an LI800 is used
% (it does not have anything but co2 values)
try
    Profile.h2o.CycleAvg(:,:,ind) = prOut.h2o.CycleAvg;
    Profile.h2o.CycleMax(:,:,ind) = prOut.h2o.CycleMax;
    Profile.h2o.CycleMin(:,:,ind) = prOut.h2o.CycleMin;
    Profile.h2o.CycleStd(:,:,ind) = prOut.h2o.CycleStd;
    Profile.h2o.Avg(ind,:)        = prOut.h2o.Avg;

    Profile.Tbench.CycleAvg(:,:,ind) = prOut.Tbench.CycleAvg;
    Profile.Tbench.CycleMax(:,:,ind) = prOut.Tbench.CycleMax;
    Profile.Tbench.CycleMin(:,:,ind) = prOut.Tbench.CycleMin;
    Profile.Tbench.CycleStd(:,:,ind) = prOut.Tbench.CycleStd;
    Profile.Tbench.Avg(ind,:)        = prOut.Tbench.Avg;

    Profile.Plicor.CycleAvg(:,:,ind) = prOut.Plicor.CycleAvg;
    Profile.Plicor.CycleMax(:,:,ind) = prOut.Plicor.CycleMax;
    Profile.Plicor.CycleMin(:,:,ind) = prOut.Plicor.CycleMin;
    Profile.Plicor.CycleStd(:,:,ind) = prOut.Plicor.CycleStd;
    Profile.Plicor.Avg(ind,:)        = prOut.Plicor.Avg;

    Profile.Pgauge.CycleAvg(:,:,ind) = prOut.Pgauge.CycleAvg;
    Profile.Pgauge.CycleMax(:,:,ind) = prOut.Pgauge.CycleMax;
    Profile.Pgauge.CycleMin(:,:,ind) = prOut.Pgauge.CycleMin;
    Profile.Pgauge.CycleStd(:,:,ind) = prOut.Pgauge.CycleStd;
    Profile.Pgauge.Avg(ind,:)        = prOut.Pgauge.Avg;
end

    