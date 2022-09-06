VB2MatlabDateOffset = 693960;
GMToffset = 6/24;
fileName = 'd:\junk\calibrations.cb2';
fid = fopen(fileName,'r');
if fid < 3
    error(['Cannot open file: ' fileName])
end
cal_voltage = fread(fid,[30 inf],'float32');
fclose(fid);


[n,m] = size(cal_voltage);

decDOY=(cal_voltage(1,:)+cal_voltage(2,:)+VB2MatlabDateOffset-GMToffset);

% remove bad CAL1 calibrations by overwriting it with good stuff
ind = find(decDOY >= datenum(2003,1,330) & decDOY <= datenum(2003,12,5));
for i = ind
    cal_voltage([12 13 17 23 24 25 26],i)=cal_voltage([12 13 17 23 24 25 26],ind(end)+1);
end

% Save the results
fid = fopen(fileName,'wb');
if fid < 3
    error(['Cannot open file: ' fileName])
end


fwrite(fid,cal_voltage,'float32');
fclose(fid);

