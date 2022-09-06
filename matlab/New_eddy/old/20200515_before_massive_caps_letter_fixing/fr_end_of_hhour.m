function [tv_calc,hhours] = fr_end_of_hhour(tv_in,endDate)
% fr_standard_hhour(tv_calc,endDate)
%
% Return time vector that is pointing to the end of hhours
% and the number of hhours.

% ceil(currentDate.*48)./48 - rounds up to the end of the hhour
% round is just there because there is a small (1e-6) rounding error
tv_calc = (ceil(tv_in.*48)./48);
hhours  = length(tv_calc);