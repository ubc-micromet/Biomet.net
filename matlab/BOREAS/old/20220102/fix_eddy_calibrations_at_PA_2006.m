% fix eddy calibrations for PA in 2006

VB2MatlabDateOffset = 693960;
GMToffset = 6/24;
Year = 2006;
fileName = 'D:\Sites\PAOA\HHour\calibrations.cp2';
fid = fopen(fileName,'r');
if fid < 3
    error(['Cannot open file: ' fileName])
end
cal_voltage = fread(fid,[30 inf],'float32');
fclose(fid);

[n,m] = size(cal_voltage);

decDOY=(cal_voltage(1,:)+cal_voltage(2,:)+VB2MatlabDateOffset-GMToffset);

% fix calibration gas values
doy=decDOY-datenum(2006,1,0);
ind_bad = find(doy>0 & doy < 327 & cal_voltage(10,:)>100);
ind_bad2 = find(doy>50 & doy <54 & cal_voltage(11,:)>40);
ind_bad3 = find(doy>306 & doy<308);
% set the ignore flag
cal_voltage(6,[ind_bad ind_bad2 ind_bad3])=1;


% Save the results
fid = fopen(fileName,'wb');
if fid < 3
    error(['Cannot open file: ' fileName])
end
fwrite(fid,cal_voltage,'float32');
fclose(fid);
