% Fix bad H2O eddy calibration at OBS for DOY 275 and 277 

%  September 26, 2005:  NickG
%------------------------------------------------------
% Fix eddy H2O calibration
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

% ---------- fix ---------------------------
% find all points for DOY 261
ind = find(decDOY >= datenum(2005,1,275) & decDOY <= datenum(2005,1,278) & (cal_voltage(11,:) > 300) );
% set ignore flag
cal_voltage(6,ind)= 1;
%
%--------------------------------------------------------

% Save the eddy fix results
fid = fopen(fileName,'wb');
if fid < 3
    error(['Cannot open file: ' fileName])
end
fwrite(fid,cal_voltage,'float32');
fclose(fid);
