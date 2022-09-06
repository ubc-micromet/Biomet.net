% Fix bad CO2 eddy calibration at OBS 

%  Oct 19, 2007:  NickG
%------------------------------------------------------
% Fix bad eddy cals resulting from eddy TCH/Licor change, DOY291 
%------------------------------------------------------
%
% Load the original file
%
VB2MatlabDateOffset = 693960;
GMToffset = 6/24;

fileName = 'D:\Nick\matlab\OBS\cal_fixes\20071019\calibrations.cb2';
fid = fopen(fileName,'r');
if fid < 3
    error(['Cannot open file: ' fileName])
end
cal_voltage = fread(fid,[30 inf],'float32');
fclose(fid);
decDOY=(cal_voltage(1,:)+cal_voltage(2,:)+VB2MatlabDateOffset-GMToffset);

% find bad calibrations
doy = decDOY -datenum(2007,1,0);
ind_bad = find( (doy>291.65 & doy <= 291.8) & cal_voltage(10,:)>500);
% set ignore flag
cal_voltage(6,ind_bad)= 1;

% find and fix wrong Licor SN
ind_SN=find(doy>291.44 & doy<291.72);
cal_voltage(3,ind_SN)=7000;

% Save the eddy fix results
fid = fopen(fileName,'wb');
if fid < 3
    error(['Cannot open file: ' fileName])
end
fwrite(fid,cal_voltage,'float32');
fclose(fid);
