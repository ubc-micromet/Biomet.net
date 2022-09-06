function stats_all = fr_calc_one_CD_stats(SiteFlag,year,month,sd,ed,FileName)
%
%For the given year, month and start day and end day, this function calculates
%fluxes for a CD data.
%
%
%(c) Bill Chen					File created:			Jan  7, 1998
%								   Last modification:   Feb 10, 1998 (by Zoran Nesic)
%

%
%Revisions:
%
% Feb 10, 1998
%    - changed the output parameter so it uses only a structure "stats_all"
%    - introduced structures reflecting the changes made on fr_calc_main
%      (see the output structure used by fr_calc_main.m)
%    - added input parameter FileName 
%

t0 = now;
for id = sd:ed
   disp(sprintf('Processing day: %d (%d/%d)',id,month,year));
   stats = fr_calc_one_day_stats(SiteFlag,year,month,id);
   stats_all.BeforeRot(:,:,[1:48] + (id-sd)*48) = stats.BeforeRot;
   stats_all.AfterRot(:,:,[1:48] + (id-sd)*48)  = stats.AfterRot;
   stats_all.RawData(:,:,[1:48] + (id-sd)*48)   = stats.RawData;
   stats_all.Fluxes([1:48] + (id-sd)*48,:)      = stats.Fluxes;
   stats_all.Misc([1:48] + (id-sd)*48,:)        = stats.Misc;
   stats_all.Angles([1:48] + (id-sd)*48,:)      = stats.Angles;
   stats_all.TimeVector([1:48] + (id-sd)*48,:)  = stats.TimeVector;
   stats_all.DecDOY([1:48] + (id-sd)*48,:)      = stats.DecDOY;
   stats_all.Year([1:48] + (id-sd)*48,:)        = stats.Year;
end

save 'c:\nz\paoa_004' stats_all
disp(sprintf('elapsed time = %f sec',now-t0))
