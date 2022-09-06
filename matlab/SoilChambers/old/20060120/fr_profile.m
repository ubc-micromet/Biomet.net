%Main program to calculate one minute profile averages and half hour averages
%
% - loads in data and calls calc_profile.m to calculate one min. avg's and
%  calls hhr_profile.m to calculate half hour avg's
%
% Inputs:   either CO2 or H2O concentration trace
%           status flag associated with above
%           time series associated with above
%           Skip_count = number of values to skip for calculation of one min. avg's
%           k = the minimum concentration to include in averages
%
% E. Humphreys       Oct 14, 1998


if exist('c:\chambers_dat\21x\') ~= 0;
   pth = 'c:\chambers_dat\21x\';
else
   addpath ('\\boreas_007\chambers_dat\21x');
   pth = '\\boreas_007\chambers_dat\21x\';
end

timeSer = read_bor([pth 'CR_21x_tv'],8);
CO2 = read_bor([pth 'CR_21x.21']);
status = read_bor([pth 'CR_21x.19']);

%[ddoy] = ch_time(timeSer,8,0);
%ddoy = timeSer-datenum('1-Jan-1998');

flagVoltages = [500 1000 1500 2000];
N = length(flagVoltages);
Skip_count = 2;								% skip this many samples when averaging
k = 350;

%get one-minute means
[t,s] = calc_profile(timeSer, CO2, status, flagVoltages, Skip_count);

s_calc = s;s_calc(s_calc==0) = NaN;
t_calc = t;t_calc(t_calc==0) = NaN;

fig = 0;
fig = fig+1; figure(fig);clf
plot(t_calc,s_calc,'o');

[CO2] = hhr_profile(t_calc,s_calc);

fig = fig+1; figure(fig);clf
plot(CO2(:,1),CO2(:,2:5));
zoom on

