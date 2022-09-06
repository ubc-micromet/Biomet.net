% Fix to deal with the problems arising from a power issue to the
% Profile TCH box, resulting in bad calibrations for DOY 131, 140, 150
% and ongoing DOY 157 to present (June 23, 2005)

% last revision June 23, 2005:  NickG

%------------------------------------------------------
% Fix profile calibrations
%------------------------------------------------------
VB2MatlabDateOffset = 693960;
GMToffset = 6/24;

fileName = '\\paoa001\sites\paob\hhour\calibrations.cb_pr';
fid = fopen(fileName,'r');
if fid < 3
    error(['Cannot open file: ' fileName])
end
cal_voltage = fread(fid,[30 inf],'float32');
fclose(fid);
decDOY=(cal_voltage(1,:)+cal_voltage(2,:)+VB2MatlabDateOffset-GMToffset);

% ---------- fix -------------------------------------
% find bad profile CAL1 and CAL2 (CO2) values May 11, May 20, May 30 and daily
% since June 6, 2005
ind = find((decDOY >= datenum(2005,5,11)) & ((cal_voltage(17,:) <= 100) |...
                      (cal_voltage(10,:) > 500)));
% fix CAL1 and CAL2 corrected value
cal_voltage(6,ind)= 1;
% ----------- end of fix -------------------------------

% Save the results
fid = fopen(fileName,'wb');
if fid < 3
    error(['Cannot open file: ' fileName])
end
fwrite(fid,cal_voltage,'float32');
fclose(fid);

