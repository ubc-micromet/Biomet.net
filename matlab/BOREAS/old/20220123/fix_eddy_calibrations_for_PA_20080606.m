% Fix bad CO2 eddy calibration at PA 

%  June 6, 2008:  NickG
%------------------------------------------------------
% Fix bad eddy cals thru DOY157, 2008
%------------------------------------------------------
%
% Load the original file
%
VB2MatlabDateOffset = 693960;
GMToffset = 6/24;

fileName = 'D:\Nick_Share\recalcs\PA\recalc_20080606\hhour\calibrations.cp2';
fid = fopen(fileName,'r');
if fid < 3
    error(['Cannot open file: ' fileName])
end
cal_voltage = fread(fid,[30 inf],'float32');
fclose(fid);
decDOY=(cal_voltage(1,:)+cal_voltage(2,:)+VB2MatlabDateOffset-GMToffset);

% find bad calibrations
doy = decDOY -datenum(2008,1,0);
ind_bad = find(doy>=59 & doy<60);
% correct cal1 conc
cal_voltage(4,ind_bad)= 383.29;

% Save the eddy fix results
fid = fopen(fileName,'wb');
if fid < 3
    error(['Cannot open file: ' fileName])
end
fwrite(fid,cal_voltage,'float32');
fclose(fid);
