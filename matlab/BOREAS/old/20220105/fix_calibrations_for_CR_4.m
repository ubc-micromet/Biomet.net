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


% ---------- fix calibrations ---------------------------
% find points between May 6 and May 12
ind = find((decDOY >= datenum(2005,5,4) & decDOY <= datenum(2005,5,13) ) & cal_voltage(19,:)>100 );
% fix CAL_1 corrected value
cal_voltage(6,ind)= 1;


% Save the results
fid = fopen(fileName,'wb');
if fid < 3
    error(['Cannot open file: ' fileName])
end
fwrite(fid,cal_voltage,'float32');
fclose(fid);