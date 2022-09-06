function correct_PA_cal_file(sourceFileName,destinationFileName)

GMToffset = 6/24;
VB2MatlabDateOffset = 693960;

fid = fopen(sourceFileName,'r');
if fid < 3
    error(['Cannot open file: ' fileName])
end
cal_voltage = fread(fid,[30 inf],'float32');
fclose(fid);

Year = 1999;
decDOY=(cal_voltage(1,:)+cal_voltage(2,:)-datenum(Year,1,1))+VB2MatlabDateOffset-GMToffset+1;
