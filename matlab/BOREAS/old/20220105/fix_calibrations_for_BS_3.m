% Introduce the new 'Ignore calibration' flag (cal_voltage(6,:)) to
% deal with wrong calibrations between April 11 and 26, 2003
% for both the profile and the eddy systems

%------------------------------------------------------
% Fix eddy calibrations
%------------------------------------------------------
VB2MatlabDateOffset = 693960;
GMToffset = 6/24;

fileName = '\\paoa001\sites\paob\hhour\calibrations.cb2';
fid = fopen(fileName,'r');
if fid < 3
    error(['Cannot open file: ' fileName])
end
cal_voltage = fread(fid,[30 inf],'float32');
fclose(fid);
decDOY=(cal_voltage(1,:)+cal_voltage(2,:)+VB2MatlabDateOffset-GMToffset);

% ---------- fix -------------------------------------
% fix bad calibration zero value for Apr 11, 2003 until Apr 26, 2003
ind = find(decDOY >= datenum(2003,4,10) & decDOY <= datenum(2003,4,26));
% fix CAL0 corrected value
cal_voltage(6,ind)= 1;
% ----------- end of fix -------------------------------

% Save the results
fid = fopen(fileName,'wb');
if fid < 3
    error(['Cannot open file: ' fileName])
end
fwrite(fid,cal_voltage,'float32');
fclose(fid);

%------------------------------------------------------
% Fix profile calibrations
%------------------------------------------------------
fileName = '\\paoa001\sites\paob\hhour\calibrations.cb_pr';
fid = fopen(fileName,'r');
if fid < 3
    error(['Cannot open file: ' fileName])
end
cal_voltage = fread(fid,[30 inf],'float32');
fclose(fid);
decDOY=(cal_voltage(1,:)+cal_voltage(2,:)+VB2MatlabDateOffset-GMToffset);

% ---------- fix -------------------------------------
% fix bad calibration zero value for Apr 11, 2003 until Apr 26, 2003
ind = find(decDOY >= datenum(2003,4,10) & decDOY <= datenum(2003,4,26));
% fix CAL0 corrected value
cal_voltage(6,ind)= 1;
% ----------- end of fix -------------------------------

% Save the results
fid = fopen(fileName,'wb');
if fid < 3
    error(['Cannot open file: ' fileName])
end
fwrite(fid,cal_voltage,'float32');
fclose(fid);

