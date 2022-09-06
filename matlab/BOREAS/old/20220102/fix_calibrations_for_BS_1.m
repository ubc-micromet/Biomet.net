VB2MatlabDateOffset = 693960;
GMToffset = 6/24;
Year = 1999;
fileName = 'c:\sites\paob\hhour\calibrations.cb2';
fid = fopen(fileName,'r');
if fid < 3
    error(['Cannot open file: ' fileName])
end
cal_voltage = fread(fid,[30 inf],'float32');
fclose(fid);


[n,m] = size(cal_voltage);

decDOY=(cal_voltage(1,:)+cal_voltage(2,:)+VB2MatlabDateOffset-GMToffset);

% fix licor number
ind = find(decDOY <= datenum(1999,7,29));
cal_voltage(3,ind)=1037;
ind = find(decDOY > datenum(1999,7,29));
cal_voltage(3,ind)=1036;

% fix calibration gas values
cal_voltage(4,1:130)=cal_voltage(4,200);
cal_voltage(5,1:130)=cal_voltage(5,200);

% Save the results
fid = fopen(fileName,'wb');
if fid < 3
    error(['Cannot open file: ' fileName])
end


fwrite(fid,cal_voltage,'float32');
fclose(fid);

