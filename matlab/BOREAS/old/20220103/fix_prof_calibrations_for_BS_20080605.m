% OBS profile calibration fix

% Fix profile calibrations for 2008 

% NickG, June 5, 2008
%------------------------------------------------------
% Fix profile calibrations due to insuffucient cal0 flow
%------------------------------------------------------
VB2MatlabDateOffset = 693960;
GMToffset = 6/24;

fileName = 'D:\Nick_Share\recalcs\BS\recalc_20080605\hhour\calibrations.cb_pr';
fid = fopen(fileName,'r');
if fid < 3
    error(['Cannot open file: ' fileName])
end
cal_voltage = fread(fid,[30 inf],'float32');
fclose(fid);
decDOY=(cal_voltage(1,:)+cal_voltage(2,:)+VB2MatlabDateOffset-GMToffset);

% ---------- fix -------------------------------------
% find bad profile cal0 values DOY46-53, 2008
% 
doy = decDOY - datenum(2008,1,0);
ind_bad = find(doy>=46 & doy<53 );

% set ignore flag
cal_voltage(6,ind_bad)= 1;
% ----------- end of fix -------------------------------

% Save the profile fix results
fid = fopen(fileName,'wb');
if fid < 3
    error(['Cannot open file: ' fileName])
end
fwrite(fid,cal_voltage,'float32');
fclose(fid);

