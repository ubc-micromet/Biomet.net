VB2MatlabDateOffset = 693960;
GMToffset = 6/24;
fileName = 'D:\sites\paob\hhour\calibrations.cb2';
fid = fopen(fileName,'r');
if fid < 3
    error(['Cannot open file: ' fileName])
end
cal_voltage = fread(fid,[30 inf],'float32');
fclose(fid);


[n,m] = size(cal_voltage);

decDOY=(cal_voltage(1,:)+cal_voltage(2,:)+VB2MatlabDateOffset-GMToffset);

% ---------- fix 1 -------------------------------------
% fix bad calibration gas value for Apr 11, 2003 until Jun 27, 2003
ind = find(decDOY >= datenum(2003,4,11) & decDOY <= datenum(2003,6,27));
% fix CAL1 value
cal_voltage(4,ind)=361.975;
% ----------- end of fix 1 -------------------------------

% Save the results
fid = fopen(fileName,'wb');
if fid < 3
    error(['Cannot open file: ' fileName])
end


fwrite(fid,cal_voltage,'float32');
fclose(fid);

