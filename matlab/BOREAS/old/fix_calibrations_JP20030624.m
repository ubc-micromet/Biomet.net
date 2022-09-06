% function to fix bad calibration values
% see also 'M:\Projects\Procedures and documentation\Common\DOC\FixingLicorCalFiles.txt'


VB2MatlabDateOffset = 693960;
GMToffset = 6/24;
fileName = 'd:\met-data\hhour\calibrations.cj2';
fid = fopen(fileName,'r');
if fid < 3
    error(['Cannot open file: ' fileName])
end
cal_voltage = fread(fid,[30 inf],'float32');
fclose(fid);


[n,m] = size(cal_voltage);

decDOY=(cal_voltage(1,:)+cal_voltage(2,:)+VB2MatlabDateOffset-GMToffset);

% ---------- fix 1 -------------------------------------
% fix bad calibration gas value for Nov 6 - Nov 18th, 2002
ind = find(decDOY >= datenum(2002,11,7) & decDOY <= datenum(2002,11,19));
% fix CAL1 value
cal_voltage(4,ind)=330.42;
% ----------- end of fix 1 -------------------------------

% ---------- fix 2 -------------------------------------
% fix bad calibration gas value for Apr 10-30, 2003
ind = find(decDOY >= datenum(2003,1,100) & decDOY <= datenum(2003,1,120));
% fix CAL1 value
cal_voltage(4,ind)=354.03;
% ----------- end of fix 2 -------------------------------

% Save the results
fid = fopen(fileName,'wb');
if fid < 3
    error(['Cannot open file: ' fileName])
end
fwrite(fid,cal_voltage,'float32');
fclose(fid);

%to look at changes use
%cal_pl(90:130,2003,'jp','d:\met-data\hhour\calibrations.cj2');