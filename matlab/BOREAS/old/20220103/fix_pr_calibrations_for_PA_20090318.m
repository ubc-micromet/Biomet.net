% Fix bad H2O eddy calibration at OBS for DOY 275 and 277 

%  March 18, 2009:  NickG
%------------------------------------------------------
% Fix eddy calibrations
%------------------------------------------------------
%
% Load the original file
%
VB2MatlabDateOffset = 693960;
GMToffset = 6/24;

fileName = 'D:\Nick\matlab\OA\cal_fix_20090318\calibrations.cp_pr';
fid = fopen(fileName,'r');
if fid < 3
    error(['Cannot open file: ' fileName])
end
cal_voltage = fread(fid,[30 inf],'float32');
fclose(fid);
decDOY=(cal_voltage(1,:)+cal_voltage(2,:)+VB2MatlabDateOffset-GMToffset);

% ---------- fix ---------------------------
% find all points 72.1<DOY<75.1
ind = find(decDOY >= datenum(2009,1,72.1) & decDOY < datenum(2009,1,75.5) );
% set ignore flag
cal_voltage(4,ind)=  373.54;
%
%--------------------------------------------------------

% Save the eddy fix results
fid = fopen(fileName,'wb');
if fid < 3
    error(['Cannot open file: ' fileName])
end
fwrite(fid,cal_voltage,'float32');
fclose(fid);
