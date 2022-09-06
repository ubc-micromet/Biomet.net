% Fix bad CO2 eddy calibration at OBS 

%  March 31, 2006:  NickG
%------------------------------------------------------
% Fix bad eddy zero calibrations arising from improper cal0 flow
%  setting at site 
%------------------------------------------------------
%
% Load the original file
%
VB2MatlabDateOffset = 693960;
GMToffset = 6/24;

fileName = '\\paoa001\sites\paob\hhour\calibrations.cb2';
fid = fopen(fileName,'r');
if fid < 3
    error(['Cannot open file: ' fileName])
end
cal_voltage = fread(fid,[30 inf],'float32');
fclose(fid);
decDOY=(cal_voltage(1,:)+cal_voltage(2,:)+VB2MatlabDateOffset-GMToffset);

%---------- reverse part of fix_eddy_calibrations_for_BS_12 which knocked
%---------- out the eddy cals below

% find points between DOY 70 and 74 (bad following sample filter change)
ind_bad = find((decDOY >= datenum(2006,1,70) & decDOY <= datenum(2006,1,75)) );
% set ignore flag
cal_voltage(6,ind_bad)= 0;

% Save the eddy fix results
fid = fopen(fileName,'wb');
if fid < 3
    error(['Cannot open file: ' fileName])
end
fwrite(fid,cal_voltage,'float32');
fclose(fid);
