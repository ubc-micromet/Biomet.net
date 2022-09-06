%==================================================================
%
%   MET2MAT.m
%
%
%       This meta file transfers raw data to eng.units (MET.Exe data 
%       already in ascii form - ExportFile)
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
disp('start of the conversion (integers -> eng.units)')
e_units
disp('end of the conversion')
e_time = etime(clock,t0)
