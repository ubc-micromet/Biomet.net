% Fix bad CO2 eddy calibration at CR for DOY 136 to 145 

%  May 25, 2006:  NickG
%------------------------------------------------------
% Fix eddy CO2 calibration
%------------------------------------------------------
%
% Load the original file
%
VB2MatlabDateOffset = 693960;
GMToffset = 6/24;

fileName = '\\paoa001\sites\CR\hhour\calibrations.cc2';
fid = fopen(fileName,'r');
if fid < 3
    error(['Cannot open file: ' fileName])
end
cal_voltage = fread(fid,[30 inf],'float32');
fclose(fid);
decDOY=(cal_voltage(1,:)+cal_voltage(2,:)+VB2MatlabDateOffset-GMToffset);

% ---------- fix ---------------------------
% find all points for DOY 261
ind = find(decDOY >= datenum(2006,1,136) & decDOY <= datenum(2006,1,145) & (cal_voltage(4,:) == 0) );
% set ignore flag
cal_voltage(4,ind)= 400;
%
%--------------------------------------------------------

% Save the eddy fix results
fid = fopen(fileName,'wb');
if fid < 3
    error(['Cannot open file: ' fileName])
end
fwrite(fid,cal_voltage,'float32');
fclose(fid);
