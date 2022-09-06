% Fix bad CO2 eddy calibration at OBS 

%  Feb 13, 2007:  NickG
%------------------------------------------------------
% Fix bad eddy cals resulting thru DOY284 
%------------------------------------------------------
%
% Load the original file
%
VB2MatlabDateOffset = 693960;
GMToffset = 6/24;

fileName = 'D:\Nick_Share\recalcs\BS\recalc_20080207\hhour\calibrations.cb2';
fid = fopen(fileName,'r');
if fid < 3
    error(['Cannot open file: ' fileName])
end
cal_voltage = fread(fid,[30 inf],'float32');
fclose(fid);
decDOY=(cal_voltage(1,:)+cal_voltage(2,:)+VB2MatlabDateOffset-GMToffset);

% find bad calibrations
doy = decDOY -datenum(2007,1,0);
ind_bad = find((cal_voltage(10,:)>500 & doy>291 & doy<321) );
% set ignore flag
cal_voltage(6,ind_bad)= 1;

% Save the eddy fix results
fid = fopen(fileName,'wb');
if fid < 3
    error(['Cannot open file: ' fileName])
end
fwrite(fid,cal_voltage,'float32');
fclose(fid);
