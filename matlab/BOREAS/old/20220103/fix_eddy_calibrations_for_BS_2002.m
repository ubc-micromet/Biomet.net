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

fileName = 'L:\BS_HFREQ_2002\met-data\recalc_20070208\hhour\calibrations.cb2';
fid = fopen(fileName,'r');
if fid < 3
    error(['Cannot open file: ' fileName])
end
cal_voltage = fread(fid,[30 inf],'float32');
fclose(fid);
decDOY=(cal_voltage(1,:)+cal_voltage(2,:)+VB2MatlabDateOffset-GMToffset);

% fix #1 find bad zero cals  

ind_bad1 = find( decDOY >= datenum(2002,1,97.5) & decDOY < datenum(2002,1,98) & cal_voltage(10,:) < -500 );
% set ignore flag
cal_voltage(6,ind_bad1)= 1;

% fix #2 find bad zero cals

ind_bad2 = find( decDOY > datenum(2002,1,323) & decDOY < datenum(2002,1,355) & cal_voltage(10,:) > -50  );
% set ignore flag
cal_voltage(6,ind_bad2)= 1;

% Save the eddy fix results
fid = fopen(fileName,'wb');
if fid < 3
    error(['Cannot open file: ' fileName])
end
fwrite(fid,cal_voltage,'float32');
fclose(fid);
