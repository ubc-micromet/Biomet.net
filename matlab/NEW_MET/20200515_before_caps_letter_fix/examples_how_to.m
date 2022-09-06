% 
% This file provides examples how to run the most important functions
% from this set (new_met).
%
%
% calculate one day of data (hhour stats) use fr_calc_one_day_stats()
% ex.:
% stats = fr_calc_one_day_stats('CR',1998,2,22,0);
% st    =fr_save_hhour('CR',stats);
%   calculates 48 hhours for Dec 9, 1997 (GMT TIME), collected at Campbell River site
%   (use 'PA' for Prince Albert old aspen) and saves it under x:\met-data\hhour\980222.hc.mat
%
% stats = fr_calc_one_day_stats('CR',1998,2,22,1);
% st    =fr_save_hhour('CR',stats);
%   the same as above but LOCAL TIME
%
% To calculate fluxes for Mar 5 - Mar 15, 1998
%   for month = 3:3;
%       for day = 5:15;
%           stats = fr_calc_one_day_stats('CR',1998,month,day,0);
%           st    = fr_save_hhour('CR',stats);
%       end
%   end
%
%
% To calculate fluxes for Mar 25 - Apr 5, 1998
%   month =   [ 3  3  3  3  3  3  3 4 4 4 4 4];
%   day   =   [25 26 27 28 29 30 31 1 2 3 4 5];
%   for i = 1:length(day)
%        stats = fr_calc_one_day_stats('CR',1998,month(i),day(i),0);
%        st    = fr_save_hhour('CR',stats);
%   end
%
% For plotting and extracting hhour values that are stored in
% "stats" use the Campbell River Site Key Table
% (Excel file MasterKeyTable.xls)
% The following examples should help the user to understend the sintax used
% in the key table and the sintax of some, not so often used, Matlab commands.
%
% Extracting DecDOY
%   t = squeeze(stats.DecDOY);
% Extracting Year
%
% Extracting mean and max co2 values from "stats"
% co2_avg = squeeze(stats.BeforeRot(1,11,:));
% co2_max = squeeze(stats.BeforeRot(3,11,:));
%
% Extracting w^co2 (m/s*ppm) and w^h2o (m/s*mmol/mol)
% w_co2 = squeeze(stats.AfterRot(7,7,:));
% w_h2o = squeeze(stats.AfterRot(7,8,:));
%
% To calculate more than one day of data one could use fr_call_calc_main
% script (after editing it so it runs for the time period needed).
% or a new function could be written using fr_calc_one_day_stats as a
% starting point.
%
% To plot high freq. data at the site use
% fr_plt_now()
%
% Ex1.: fr_plt_now(7,2)             plots H2O (LiCor) for the current hhour
%
% Ex2.: [EngUnits_GillR2,EngUnits_DAQ] = fr_plt_now(6,2); plots CO2 but also
%       returns all the channels (Gill AND DAQbook) so user can use them
%       directly.
%
% Ex3.: fr_plt_now(4,1);            plots Tair from GillR2
%
% Ex4.: fr_plt_now(6,2,now-49,'PA');     plots co2, DAQbook, PA site, 49 days ago
%
