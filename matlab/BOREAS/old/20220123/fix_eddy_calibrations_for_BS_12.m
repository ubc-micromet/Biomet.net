% Fix bad CO2 eddy calibration at OBS for DOY 75 and 89

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

%-----------fix #1----------------------------
% find points between DOY 70 and 74 (bad following sample filter change)
ind_bad = find((decDOY >= datenum(2006,1,70) & decDOY <= datenum(2006,1,75)) |...
    (decDOY >= datenum(2006,1,20) & decDOY <= datenum(2006,1,21))  );
% set ignore flag
cal_voltage(6,ind_bad)= 1;

% ---------- fix #2---------------------------
% find all points between DOY 75 and 90 where the zero CO2 exceeded 100 mV
ind = find(decDOY >= datenum(2006,1,74) & decDOY <= datenum(2006,1,91) & (cal_voltage(10,:) > 100) );
% set ignore flag
cal_voltage(6,ind)= 1;
%
%----------- fix #3, incorrect cal1 conc in UBC_DAQ.ini -----------------------------
ind_wrong_cal1 = find(decDOY-datenum(2006,1,0)>= 89.5 & decDOY-datenum(2006,1,0)<= 90.54);
cal_voltage(4,ind_wrong_cal1)= 374.222;
%--------------------------------------------------------

% Save the eddy fix results
fid = fopen(fileName,'wb');
if fid < 3
    error(['Cannot open file: ' fileName])
end
fwrite(fid,cal_voltage,'float32');
fclose(fid);
