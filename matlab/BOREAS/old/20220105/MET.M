%==================================================================
%
%   MET.m
%
%
%   This meta file does statistics on METxxx.BAS files.
%   (it is suppose to give the same results as on line 
%    calculation)
%
%==================================================================
format short e
t0 = clock;
disp('Loading data')
%
met1
%
disp('Loading finshed')
etime(clock,t0)
disp('start of calculation')
met2
disp('end of calculation')
e_time = etime(clock,t0)
