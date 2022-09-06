VB2MatlabDateOffset = 693960;
GMToffset = 6/24;
Year = 1999;
fileName = 'd:\sites\cr\hhour\calibrations.cc2';
%fileName = 'c:\sites\cr\hhour\calibrations_20000609.cc2';
fid = fopen(fileName,'r');
if fid < 3
    error(['Cannot open file: ' fileName])
end
cal_voltage = fread(fid,[30 inf],'float32');
fclose(fid);

[n,m] = size(cal_voltage);

decDOY=(cal_voltage(1,:)+cal_voltage(2,:)+VB2MatlabDateOffset-GMToffset);


% fix licor num values
ind = find(decDOY >= datenum(2003,1,156) & decDOY < datenum(2003,1,162.5));
cal_voltage(3,ind)=cal_voltage(3,ind+30);

% fix licor num values
ind = find(decDOY >= datenum(2003,1,226.2) & decDOY < datenum(2003,1,232));
cal_voltage(10,ind)=cal_voltage(10,ind(end)+2)*ones(size(ind));
cal_voltage(11,ind)=cal_voltage(11,ind(end)+2)*ones(size(ind));
cal_voltage(12,ind)=cal_voltage(12,ind(end)+2)*ones(size(ind));
cal_voltage(17,ind)=cal_voltage(17,ind(end)+2)*ones(size(ind));
cal_voltage(21,ind)=cal_voltage(21,ind(end)+2)*ones(size(ind));
cal_voltage(25,ind)=cal_voltage(25,ind(end)+2)*ones(size(ind));
cal_voltage(26,ind)=cal_voltage(26,ind(end)+2)*ones(size(ind));
cal_voltage(13,ind)=cal_voltage(13,ind(end)+2)*ones(size(ind));

% Save the results
fid = fopen(fileName,'wb');
if fid < 3
    error(['Cannot open file: ' fileName])
end
fwrite(fid,cal_voltage,'float32');
fclose(fid);