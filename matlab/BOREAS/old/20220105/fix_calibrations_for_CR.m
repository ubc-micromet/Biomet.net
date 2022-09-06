VB2MatlabDateOffset = 693960;
GMToffset = 6/24;
Year = 1999;
fileName = 'c:\sites\cr\hhour\calibrations.cc2';
%fileName = 'c:\sites\cr\hhour\calibrations_20000609.cc2';
fid = fopen(fileName,'r');
if fid < 3
    error(['Cannot open file: ' fileName])
end
cal_voltage = fread(fid,[30 inf],'float32');
fclose(fid);

[n,m] = size(cal_voltage);

decDOY=(cal_voltage(1,:)+cal_voltage(2,:)+VB2MatlabDateOffset-GMToffset);

% fix licor number
ind = find(decDOY <= datenum(1998,9,3));
cal_voltage(3,ind)=174;
ind = find(decDOY > datenum(1998,9,3) & decDOY <= datenum(1999,6,9));
cal_voltage(3,ind)=791;
ind = find(decDOY > datenum(1999,6,9)& decDOY <= datenum(2000,7,7,20,0,0));
cal_voltage(3,ind)=740;
ind = find(decDOY > datenum(2000,6,7,14,0,0)& decDOY <= datenum(2000,6,9));
cal_voltage(3,ind)=483;

% fix calibration gas values
ind = find(decDOY < datenum(1998,8,12));
cal_voltage(4,ind)=346.9;
ind = find(decDOY >= datenum(1998,8,12));
cal_voltage(4,ind)=352;
cal_voltage(5,1:369)=cal_voltage(5,375);

% Save the results
fid = fopen(fileName,'wb');
if fid < 3
    error(['Cannot open file: ' fileName])
end
fwrite(fid,cal_voltage,'float32');
fclose(fid);