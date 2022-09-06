% OBS profile calibration fix

% Fix profile calibrations for 2007 thru DOY285

% NickG, Oct 11, 2007
%------------------------------------------------------
% Fix profile calibrations
%------------------------------------------------------
VB2MatlabDateOffset = 693960;
GMToffset = 6/24;

fileName = 'D:\Nick_Share\recalcs\BS\recalc_20071011\calibrations.cb_pr';
fid = fopen(fileName,'r');
if fid < 3
    error(['Cannot open file: ' fileName])
end
cal_voltage = fread(fid,[30 inf],'float32');
fclose(fid);
decDOY=(cal_voltage(1,:)+cal_voltage(2,:)+VB2MatlabDateOffset-GMToffset);

% ---------- fix -------------------------------------
% find bad profile cal values up to DOY284, 2007
% 
doy = decDOY - datenum(2007,1,0);
ind_bad = find( (doy>0 & doy <= 284) &...
                ((cal_voltage(10,:)>500 | cal_voltage(10,:)<-500) | cal_voltage(17,:)<0  |...
                  cal_voltage(25,:)<50));
ind_wrongcal1 = find(doy>170.565 & doy<171.01) ;             
% set ignore flag
cal_voltage(6,ind_bad)= 1;
% fix incorrect cal1 CO2 conc.
cal_voltage(6,ind_wrongcal1)= 383.73; 
% ----------- end of fix -------------------------------

% Save the profile fix results
fid = fopen(fileName,'wb');
if fid < 3
    error(['Cannot open file: ' fileName])
end
fwrite(fid,cal_voltage,'float32');
fclose(fid);

