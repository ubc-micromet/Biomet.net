function Profile = fr_profile_stats_init(N_cycles, N_levels, LicorType, N_hhours)
% fr_profile_stats_init - initializes the output structure for a profile system calculations
%
%   Profile = fr_profile_stats_init(N_cycles, N_levels, LicorType, N_hhours)
%
% Inputs
%       N_cycles        - how many times does the profile system cycle during the given period of time
%                         (usually a half an hour)
%       N_levels        - the number of profile levels
%       LicorType       - '6262' or '800', 800 has only one output - co2 itself
%
% Outputs
%       Profile         - output structure, returns all the cycle mins and maxes and the averages
%                         for the entire period (hhour)
%
% (c) Zoran Nesic               File created:       Mar xx, 2001
%                               Last modification:  Aug  5, 2001
%

% Revisions:
%   Aug 5, 2001
%       - reduced the number of fields for the case when LI-800 i used
%         (needs the co2 field only)
%
tmp = NaN*zeros(N_cycles,N_levels,N_hhours);

% Removed Jul 27, 2001
%Profile.RecalcTimeVector = NaN*zeros(N_hhours,1);
%Profile.TimeVector = NaN*zeros(N_hhours,1);

Profile.co2.CycleAvg      = tmp;
Profile.co2.CycleMax      = tmp;
Profile.co2.CycleMin      = tmp;
Profile.co2.CycleStd      = tmp;
Profile.co2.Avg           = NaN*zeros(N_hhours,N_levels);

if ~strcmp(LicorType,'800')
    Profile.h2o.CycleAvg      = tmp;
    Profile.h2o.CycleMax      = tmp;
    Profile.h2o.CycleMin      = tmp;
    Profile.h2o.CycleStd      = tmp;
    Profile.h2o.Avg           = NaN*zeros(N_hhours,N_levels);

    Profile.Tbench.CycleAvg   = tmp;
    Profile.Tbench.CycleMax   = tmp;
    Profile.Tbench.CycleMin   = tmp;
    Profile.Tbench.CycleStd   = tmp;
    Profile.Tbench.Avg        = NaN*zeros(N_hhours,N_levels);

    Profile.Plicor.CycleAvg   = tmp;
    Profile.Plicor.CycleMax   = tmp;
    Profile.Plicor.CycleMin   = tmp;
    Profile.Plicor.CycleStd   = tmp;
    Profile.Plicor.Avg        = NaN*zeros(N_hhours,N_levels);

    Profile.Pgauge.CycleAvg   = tmp;
    Profile.Pgauge.CycleMax   = tmp;
    Profile.Pgauge.CycleMin   = tmp;
    Profile.Pgauge.CycleStd   = tmp;
    Profile.Pgauge.Avg        = NaN*zeros(N_hhours,N_levels);
end