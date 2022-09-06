% Fix bad CO2 eddy calibration at OBS 

%  June, 5 2008:  NickG
%------------------------------------------------------
% Fix 2008 bad eddy cals at OBS resulting from insufficient cal0 flow
% (eddy)
%------------------------------------------------------
%
% Load the original file
%
VB2MatlabDateOffset = 693960;
GMToffset = 6/24;

fileName = 'D:\Nick_Share\recalcs\BS\recalc_20080605\hhour\calibrations.cb2';
fid = fopen(fileName,'r');
if fid < 3
    error(['Cannot open file: ' fileName])
end
cal_voltage = fread(fid,[30 inf],'float32');
fclose(fid);
decDOY=(cal_voltage(1,:)+cal_voltage(2,:)+VB2MatlabDateOffset-GMToffset);

% find bad calibrations
doy = decDOY -datenum(2008,1,0);
ind_bad = find(doy>=53 & doy<60 );
% set ignore flag
cal_voltage(6,ind_bad)= 1;

% Save the eddy fix results
fid = fopen(fileName,'wb');
if fid < 3
    error(['Cannot open file: ' fileName])
end
fwrite(fid,cal_voltage,'float32');
fclose(fid);
