% OBS profile calibration fix 

% NickG, Jan 22, 2009
%------------------------------------------------------
% Fix bad profile licor calibrations for 2008
%------------------------------------------------------
VB2MatlabDateOffset = 693960;
GMToffset = 6/24;

fileName = 'D:\Nick_Share\recalcs\BS\recalc_20090112\hhour\calibrations.cb_pr';
fid = fopen(fileName,'r');
if fid < 3
    error(['Cannot open file: ' fileName])
end
cal_voltage = fread(fid,[30 inf],'float32');
fclose(fid);
decDOY=(cal_voltage(1,:)+cal_voltage(2,:)+VB2MatlabDateOffset-GMToffset);

% ---------- fix -------------------------------------
% correct bad cal1 tank CO2 conc.
% 
doy = decDOY - datenum(2008,1,0);
ind_badcal1 = find((decDOY>datenum(2008,1,304.635) & decDOY<datenum(2008,1,305.1)));
cal_voltage(4,ind_badcal1) = 380.16;

% set ignore flag for bad zero cal
ind_badzero = find(cal_voltage(10,:)>300 & (doy>=1 & doy<367) );
cal_voltage(6,ind_badzero) = 1;

% ----------- end of fix -------------------------------

% Save the profile fix results
fid = fopen(fileName,'wb');
if fid < 3
    error(['Cannot open file: ' fileName])
end
fwrite(fid,cal_voltage,'float32');
fclose(fid);

