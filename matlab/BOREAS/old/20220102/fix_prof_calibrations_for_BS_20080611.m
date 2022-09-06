% OBS profile calibration fix 

% NickG, June 11, 2008
%------------------------------------------------------
% Fix incorrect profile licor SN-- coefficients weren't wrong, only naming
% convention
%------------------------------------------------------
VB2MatlabDateOffset = 693960;
GMToffset = 6/24;

fileName = 'D:\Nick_Share\recalcs\BS\pr_cal_fix_20080611\calibrations.cb_pr';
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
%doy = decDOY - datenum(2007,1,0);
ind_bad = find(decDOY>=datenum(2007,1,8) & decDOY<datenum(2008,6,12) & cal_voltage(3,:)==1037 );

% correct licor SN
cal_voltage(3,ind_bad)= 1037001;
% ----------- end of fix -------------------------------

% Save the profile fix results
fid = fopen(fileName,'wb');
if fid < 3
    error(['Cannot open file: ' fileName])
end
fwrite(fid,cal_voltage,'float32');
fclose(fid);

