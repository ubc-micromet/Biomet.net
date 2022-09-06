function nee_night_time_corrected = calc_nee_night_time_corrected(clean_tv,nee,respiration,...
   												ustar,global_radiation)
% function nee_night_time_corrected = calc_nee_night_time_corrected(clean_tv,nee,respiration,...
%   												ustar,global_radiation)
%
% Replace night-time values with u*<0.35 with the value in respiration
%
% (c) kai*                                    File created:  Nov. 24, 2000
%                                             Last modified: Nov. 24, 2000
%
% Revisions: 

ind_replace = find(global_radiation <= 0 & ustar < 0.35);
nee_night_time_corrected = nee;
nee_night_time_corrected(ind_replace) = respiration(ind_replace);
