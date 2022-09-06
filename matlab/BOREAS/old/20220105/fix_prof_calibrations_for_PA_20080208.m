% OBS profile calibration fix

% Fix profile calibrations for 2007 thru DOY285

% NickG, Feb 8, 2008
%------------------------------------------------------
% Fix profile calibrations
%------------------------------------------------------
VB2MatlabDateOffset = 693960;
GMToffset = 6/24;

fileName = 'D:\Nick_Share\recalcs\PA\recalc_20080208\hhour\calibrations.cp_pr';
fid = fopen(fileName,'r');
if fid < 3
    error(['Cannot open file: ' fileName])
end
cal_voltage = fread(fid,[30 inf],'float32');
fclose(fid);
decDOY=(cal_voltage(1,:)+cal_voltage(2,:)+VB2MatlabDateOffset-GMToffset);

% ---------- fix -------------------------------------
% find bad profile cal values up to DOY366, 2007
% 
doy = decDOY - datenum(2007,1,0);

ind_bad = find(((cal_voltage(10,:)>200 | cal_voltage(10,:)<-3000) & (doy>0 & doy<391)) | (doy>47 & doy<51) ); % bad cal0

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

