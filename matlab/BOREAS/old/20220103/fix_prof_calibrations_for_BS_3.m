% OBS profile calibration fix

% profile calibration fix for DOY 7 (missed in earlier fix) and 11, 2006

% NickG, Feb 20/2006
%------------------------------------------------------
% Fix profile calibrations
%------------------------------------------------------
VB2MatlabDateOffset = 693960;
GMToffset = 6/24;

fileName = '\\PAOA001\Sites\Paob\HHour\calibrations.cb_pr';
fid = fopen(fileName,'r');
if fid < 3
    error(['Cannot open file: ' fileName])
end
cal_voltage = fread(fid,[30 inf],'float32');
fclose(fid);
decDOY=(cal_voltage(1,:)+cal_voltage(2,:)+VB2MatlabDateOffset-GMToffset);

% ---------- fix -------------------------------------
% find bad profile cal values DOY 7 and 11 in 2006

ind_fix = find( (decDOY >= datenum(2006,1,0) & decDOY <= datenum(2006,2,7)) & ((cal_voltage(12,:) > 2000) | (cal_voltage(10,:) < -185)));
% set ignore flag
cal_voltage(6,ind_fix)= 1;
% ----------- end of fix -------------------------------

% Save the profile fix results
fid = fopen(fileName,'wb');
if fid < 3
    error(['Cannot open file: ' fileName])
end
fwrite(fid,cal_voltage,'float32');
fclose(fid);

