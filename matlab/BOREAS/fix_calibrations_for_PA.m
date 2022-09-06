VB2MatlabDateOffset = 693960;
GMToffset = 6/24;
Year = 1999;
fileName = 'c:\sites\paoa\hhour\calibrations.cp2';
fid = fopen(fileName,'r');
if fid < 3
    error(['Cannot open file: ' fileName])
end
cal_voltage = fread(fid,[30 inf],'float32');
fclose(fid);

[n,m] = size(cal_voltage);

decDOY=(cal_voltage(1,:)+cal_voltage(2,:)+VB2MatlabDateOffset-GMToffset);

% fix licor number
ind = find(decDOY <= (datenum(1998,6,17)+80/96));
cal_voltage(3,ind)=791;
ind = find(decDOY > (datenum(1998,6,17)+80/96) & decDOY <= (datenum(1999,6,30)+88/96));
cal_voltage(3,ind)=914;
ind = find(decDOY > (datenum(1999,6,30)+88/96));
cal_voltage(3,ind)=1038;

% fix calibration gas values
ind = find(decDOY < datenum(1998,3,13));
cal_voltage(4,ind)=1000;    % test
ind = find(decDOY >= datenum(1998,3,13) & decDOY < datenum(1999,5,25));
cal_voltage(4,ind)=349.38;
ind = find(decDOY >= datenum(1999,5,25) & decDOY < datenum(1999,12,24));
cal_voltage(4,ind)=359.796;
ind = find(decDOY >= datenum(1999,12,24));
cal_voltage(4,ind)=361.117;

cal_voltage(5,1:308)=cal_voltage(5,310);

% Save the results
fid = fopen(fileName,'wb');
if fid < 3
    error(['Cannot open file: ' fileName])
end
fwrite(fid,cal_voltage,'float32');
fclose(fid);
