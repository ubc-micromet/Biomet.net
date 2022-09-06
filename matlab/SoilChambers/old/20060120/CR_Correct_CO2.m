%----------------------------------------------------------------------------------------
%Program CR_Correct_CO2.m
%
%Program to calculate the CO2 concentration from the raw millivolt signals
%from the 21x datalogger.
%the order is
%  1) Sorts through the pressure data and eliminates spurious results
%  2) Interpolates bad temperature data (which unfortunatly must be hand picked)
%  3) Filters the spurious pressure fluctuations caused by the aliasing problem
%  4) Calculates the "true" H2O and CO2 values 
%----------------------------------------------------------------------------------------

clear all;
close all;
tic

start = 1;
finish = 279020;       %note:  database is 279020 points long
k = [start:finish];

pth1 = ('\\boreas_007\chambers_dat\');
pth2 = ('c:\chambers_dat\');
Licor_temp = read_bor([pth1 '21x\cr_21x.10']);
Licor_pres = read_bor([pth1 '21x\cr_21x.11']);
CO2_mv  = read_bor([pth1 '21x\cr_21x.8']);
H2O_mv  = read_bor([pth1 '21x\cr_21x.9']);
CO2_conc= read_bor([pth1 '21x\cr_21x.21']);
CR_time = read_bor([pth1 '21x\cr_21x_tv'],8);


%----------------------------------------------------------------------------------
%  Makes a cooked timeseries (perfectly monotonic) so the interpolation
%  function will work properly
cooked_timeseries = new_time;
cooked_timeseries = cooked_timeseries(k);
DDOY_cooked = ch_time(cooked_timeseries,8,3);
DDOY_real   = ch_time(CR_time,8,3);
%-----------------------------------------------------------------------------------

%-----------------------------------------------------------------------------------
%  Section to filter out the crappy pressure values
ind_good = find(Licor_pres > -9000);
ind_bad  = find(Licor_pres < -9000);
Licor_pres(ind_bad) = interp1(cooked_timeseries(ind_good), Licor_pres(ind_good), cooked_timeseries(ind_bad));
clear ind_good...
      ind_bad...
      cooked_timeseries...
%-----------------------------------------------------------------------------------

%-----------------------------------------------------------------------------------
%  section to filter out the known erronious values
%  Anything that is obviously garbage is replaced with NaN
strt_bad_A = 5.04e4;   %section of data where there was some inexplicable noise  
fins_bad_A = 5.18e4;     
ind_bad_A = [strt_bad_A : fins_bad_A]';
CO2_mv(ind_bad_A) = NaN;
clear strt_bad_A...
      fins_bad_A
%-----------------------------------------------------------------------------------

%-----------------------------------------------------------------------------------
%   Truncates all the variables indexes to only the values of interest
Licor_temp = Licor_temp(k);
Licor_pres = Licor_pres(k);
CO2_mv = CO2_mv(k);
H2O_mv = H2O_mv(k);
CO2_conc = CO2_conc(k);
CR_time = CR_time(k);
%-----------------------------------------------------------------------------------


%-----------------------------------------------------------------------------------
%  This section filters the noisy pressure signal from the licor
%
filter_b  = fir1(40,0.01);              % Licor (cut-off freq. = 0.05*(1/5) = 0.01Hz)
filter_a  = 1;
licor_Num         = 740;
[cp, ...
 hp, ...
 Tc, ...
 Th, ...
 Psample_poly] = licor(licor_Num);
Licor_pres_f = filtfilt(filter_b,filter_a,[mean(Licor_pres(1:20)) * ones(1,20) Licor_pres']);
Licor_pres_f = Licor_pres_f(21:length(Licor_pres_f))';
%-----------------------------------------------------------------------------------

[CO2_gain CO2_offset H2O_offset]= chamber_cal;
CO2_gain = CO2_gain(k);
H2O_gain = CO2_gain;

CO2_offset = CO2_offset(k);
H2O_offset = H2O_offset(k);

%if testFlag~=1
%   CO2_gain = .9935;
%   H2O_gain = CO2_gain;
%   CO2_offset = -2;
%   H2O_offset = -2;
%else
%	CO2_gain = 1;
%	H2O_gain = CO2_gain;
%	CO2_offset = 0;
%   H2O_offset = 0;
%end



CO2_Cal(:,1) = CO2_gain;
CO2_Cal(:,2) = -1 .* CO2_offset;
H2O_Cal(:,1) = H2O_gain;
H2O_Cal(:,2) = -1 .* H2O_offset;

clear CO2_gain H2O_gain CO2_offset H2O_offset;

[h2o,chi]  = fr_licor_h( hp, Th, Licor_pres_f, Licor_temp, H2O_Cal, H2O_mv);
co2= fr_licor_c( cp, Tc, Licor_pres_f, Licor_temp, CO2_Cal, CO2_mv, [], chi);


clear start...
      finish...
      k...
      pth1...
      pth2...
      licor_Num...
      ind_bad_A...
      hp...
      finish...
      filter_a...
      filter_b...
      cp...
      chi...
      Th...
      Tc...
      Psample_poly...
      Licor_temp...
      H2O_mv...
      CO2_mv...
      H2O_Cal...
      DDOY_real...
      DDOY_cooked...
      CO2_mv...
      CO2_Cal...
      Licor_pres_f...
      Licor_pres
     
toc