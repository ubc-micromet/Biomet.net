% Fix bad eddy calibrations at OBS on DOY 228 (after the replacement of the
% site PC); also some bad calibrations missed in earlier fixes: DOY
% 70,77-79,82,131,141

%  September 8, 2005:  NickG
%------------------------------------------------------
% Fix eddy calibrations
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
% find all points for 
ind = find(decDOY >= datenum(2005,1,1) & (cal_voltage(10,:) > 500 | cal_voltage(10,:) < -500) |...
           ((decDOY >= datenum(2005,3,10)) & (decDOY <= datenum(2005,3,24)) & cal_voltage(10,:) >-60));
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
