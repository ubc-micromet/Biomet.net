% PA chamber calibration fix

% Fix profile calibrations for 2008 thru DOY157

% NickG, June 18, 2008
%------------------------------------------------------
% Fix chamber calibrations
%------------------------------------------------------
VB2MatlabDateOffset = 693960;
GMToffset = 6/24;

fileName = 'D:\Nick_Share\recalcs\PA\recalc_20080606\hhour\calibrations.cp_ch';
fid = fopen(fileName,'r');
if fid < 3
    error(['Cannot open file: ' fileName])
end
cal_voltage = fread(fid,[30 inf],'float32');
fclose(fid);
decDOY=(cal_voltage(1,:)+cal_voltage(2,:)+VB2MatlabDateOffset-GMToffset);

% ---------- fix -------------------------------------
% find bad chamber cal 
% 
doy = decDOY - datenum(2008,1,0);

ind_bad=find(decDOY>=datenum(2007,10,5,0,0,0)& decDOY<datenum(2008,6,11) & cal_voltage(3,:)==1036);

% correct cal1 CO2 conc
cal_voltage(3,ind_bad)= 914;
% ----------- end of fix -------------------------------

% Save the profile fix results
fid = fopen(fileName,'wb');
if fid < 3
    error(['Cannot open file: ' fileName])
end
fwrite(fid,cal_voltage,'float32');
fclose(fid);

