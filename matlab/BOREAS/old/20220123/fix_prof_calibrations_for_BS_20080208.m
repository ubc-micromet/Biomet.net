% OBS profile calibration fix

% Fix profile calibrations for 2007 thru DOY285

% NickG, Feb 8, 2008
%------------------------------------------------------
% Fix profile calibrations
%------------------------------------------------------
VB2MatlabDateOffset = 693960;
GMToffset = 6/24;

fileName = 'D:\Nick_Share\recalcs\BS\recalc_20080207\hhour\calibrations.cb_pr';
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
ind_bad = find((cal_voltage(10,:)>1000 & doy>290 & doy<292) | (cal_voltage(10,:)>-500 & doy>292 & doy<320) );  % cal0 bad
ind_bad2 = find( doy>291.2 & doy<291.8); % cal1 bad
ind = union(ind_bad,ind_bad2);
% set ignore flag
cal_voltage(6,ind)= 1;
% ----------- end of fix -------------------------------

% Save the profile fix results
fid = fopen(fileName,'wb');
if fid < 3
    error(['Cannot open file: ' fileName])
end
fwrite(fid,cal_voltage,'float32');
fclose(fid);

