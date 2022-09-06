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

%
%----------- fix additional incorrect cal1 CO2 conc in UBC_DAQ.ini going back to DOY80 -----------------------------
ind_wrong_cal1 = find(decDOY-datenum(2006,1,0)>= 80 & decDOY-datenum(2006,1,0)<= 89.5);
cal_voltage(4,ind_wrong_cal1)= 374.222;
%--------------------------------------------------------

% Save the eddy fix results
fid = fopen(fileName,'wb');
if fid < 3
    error(['Cannot open file: ' fileName])
end
fwrite(fid,cal_voltage,'float32');
fclose(fid);
