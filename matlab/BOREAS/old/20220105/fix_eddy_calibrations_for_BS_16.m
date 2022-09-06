% Fix bad CO2 eddy calibration at OBS 

%  Oct 2, 2006:  NickG
%------------------------------------------------------
% Fix bad eddy cals resulting from locked up TCH pwr suppply 
% DOY 240, 252, 254, 255, 256, 274
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

% find points between DOY 246 and 249 
ind_bad = find((decDOY > datenum(2006,1,239) & decDOY <= datenum(2006,1,275)) &...
    (cal_voltage(10,:) > 1000 |  cal_voltage(10,:) < -1000));
% set ignore flag
cal_voltage(6,ind_bad)= 1;

% Save the eddy fix results
fid = fopen(fileName,'wb');
if fid < 3
    error(['Cannot open file: ' fileName])
end
fwrite(fid,cal_voltage,'float32');
fclose(fid);
