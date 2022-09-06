% Fix bad eddy calibrations at OBS for 2000

%  Feb 8, 2007: Nick
%------------------------------------------------------
% 
%------------------------------------------------------
%
% Load the original file
%
VB2MatlabDateOffset = 693960;
GMToffset = 6/24;

fileName = 'L:\BS_HFREQ_2001\met-data\recalc_20070208\hhour\calibrations.cb2';
fid = fopen(fileName,'r');
if fid < 3
    error(['Cannot open file: ' fileName])
end
cal_voltage = fread(fid,[30 inf],'float32');
fclose(fid);
decDOY=(cal_voltage(1,:)+cal_voltage(2,:)+VB2MatlabDateOffset-GMToffset);

% fix #1 find bad zero cals due to low cal1 flow 

ind_bad = find( decDOY >= datenum(2001,1,0) & decDOY < datenum(2001,1,366) & cal_voltage(10,:) > 50 );
% set ignore flag
cal_voltage(6,ind_bad)= 1;

% fix #2 find bad gains

ind_bad = find( decDOY > datenum(2001,1,198) & decDOY < datenum(2001,1,200) );
% set ignore flag
cal_voltage(6,ind_bad)= 1;

% Save the eddy fix results
fid = fopen(fileName,'wb');
if fid < 3
    error(['Cannot open file: ' fileName])
end
fwrite(fid,cal_voltage,'float32');
fclose(fid);
