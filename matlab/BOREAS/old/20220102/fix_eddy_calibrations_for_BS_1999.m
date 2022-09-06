% Fix bad eddy calibrations at OBS for 1999

%  Feb :  NickG
%------------------------------------------------------
% Fix bad eddy cals resulting from locked up TCH pwr suppply 
% DOY 240, 252, 254, 255, 256, 274
%------------------------------------------------------
%
% Load the original file
%
VB2MatlabDateOffset = 693960;
GMToffset = 6/24;

fileName = 'L:\BS_HFREQ_1999\met-data\recalc_20070208\hhour\calibrations.cb2';
fid = fopen(fileName,'r');
if fid < 3
    error(['Cannot open file: ' fileName])
end
cal_voltage = fread(fid,[30 inf],'float32');
fclose(fid);
decDOY=(cal_voltage(1,:)+cal_voltage(2,:)+VB2MatlabDateOffset-GMToffset);

% fix #1 bad zeros: find bad points 

ind_bad = find( decDOY >= datenum(1999,1,161) & decDOY < datenum(1999,1,172) & cal_voltage(10,:) > 1000 );
% set ignore flag
cal_voltage(6,ind_bad)= 1;

% fix #2 bad cal1: find bad point

ind_bad = find( decDOY >= datenum(1999,1,205) & decDOY < datenum(1999,1,210) & cal_voltage(12,:) < 1000 );
% set ignore flag
cal_voltage(6,ind_bad)= 1;

% fix #3: pressure spikes, cal1

ind_bad = find( decDOY >= datenum(1999,1,113) & decDOY < datenum(1999,1,180) & cal_voltage(17,:) < 500 );
% set ignore flag
cal_voltage(6,ind_bad)= 1;

% Save the eddy fix results
fid = fopen(fileName,'wb');
if fid < 3
    error(['Cannot open file: ' fileName])
end
fwrite(fid,cal_voltage,'float32');
fclose(fid);
