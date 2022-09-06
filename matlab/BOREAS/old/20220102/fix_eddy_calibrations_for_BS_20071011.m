% Fix bad CO2 eddy calibration at OBS 

%  Feb 13, 2007:  NickG
%------------------------------------------------------
% Fix bad eddy cals resulting thru DOY284 
%------------------------------------------------------
%
% Load the original file
%
VB2MatlabDateOffset = 693960;
GMToffset = 6/24;

fileName = 'D:\Nick_Share\recalcs\BS\recalc_20071011\calibrations.cb2';
fid = fopen(fileName,'r');
if fid < 3
    error(['Cannot open file: ' fileName])
end
cal_voltage = fread(fid,[30 inf],'float32');
fclose(fid);
decDOY=(cal_voltage(1,:)+cal_voltage(2,:)+VB2MatlabDateOffset-GMToffset);

% find bad calibrations
doy = decDOY -datenum(2007,1,0);
ind_bad = find((doy > 0 & doy <= 284 ) & (cal_voltage(10,:) > 0 | cal_voltage(13,:) > 100) |...
                ((doy>116 & doy<118) & cal_voltage(13,:)>50 ));
% find incorrect cal1 CO2 conc.
ind_wrongcal1 = find( doy>170.565 & doy <170.575);
% set ignore flag
cal_voltage(6,ind_bad)= 1;
% correct cal1 CO2 conc
cal_voltage(4,ind_wrongcal1)= 383.73;

% Save the eddy fix results
fid = fopen(fileName,'wb');
if fid < 3
    error(['Cannot open file: ' fileName])
end
fwrite(fid,cal_voltage,'float32');
fclose(fid);
