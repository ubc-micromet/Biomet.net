function fix_calibrations_fore_PA_1a_serial_number_correction

% In fix_calibrations_for_PA_1.m the serial number change to S/N 1038 
% implemented for datenum(1999,6,30)+88/96) did not have an end date, 
% i.e. all serial numbers were changed to 1038 when the program was
% modified and used the next time (to fix some calibrations between 
% datenum(2004,12,28,10,0,0) and datenum(2005,01,05,15,12,0).
% 
% Here we take the last backup cal file before this change, extract the
% series of serial numbers from it and insert it into the current cal file.

VB2MatlabDateOffset = 693960;
GMToffset = 6/24;
Year = 1999;

% Read last valid backup before serial number mixup
fileName = 'd:\sites\paoa\hhour\Calibrations_20050105.cp2';

fid = fopen(fileName,'r');
if fid < 3
        error(['Cannot open file: ' fileName])
end

cal_voltage_backup = fread(fid,[30 inf],'float32');
fclose(fid);
decDOY_backup=(cal_voltage_backup(1,:)+cal_voltage_backup(2,:)+VB2MatlabDateOffset-GMToffset);

% Read current calibration file
fileName = 'd:\sites\paoa\hhour\calibrations.cp2';

fid = fopen(fileName,'r');
    if fid < 3
        error(['Cannot open file: ' fileName])
    end

cal_voltage = fread(fid,[30 inf],'float32');
fclose(fid);
decDOY=(cal_voltage(1,:)+cal_voltage(2,:)+VB2MatlabDateOffset-GMToffset);

plot(decDOY,cal_voltage(3,:),decDOY_backup,cal_voltage_backup(3,:))
datetick('x')

ind = find(decDOY <= (datenum(1998,6,17)+80/96));
cal_voltage(3,ind)=791;     
ind = find(decDOY > datenum(1998,6,17)+80/96 & decDOY <= datenum(1999,6,30)+88/96 );
cal_voltage(3,ind)=914;
ind = find(decDOY > datenum(1999,6,30)+88/96 & decDOY <= datenum(2000,1,1));
cal_voltage(3,ind)=1038;
ind = find(decDOY > datenum(2000,1,1) & decDOY <= datenum(2005,01,05,15,12,0));
ind_backup = find(decDOY_backup > datenum(2000,1,1) & decDOY_backup <= datenum(2005,01,05,15,12,0));
cal_voltage(3,ind)=cal_voltage_backup(3,ind_backup);

figure('Name','Corrected serial number')
plot(decDOY,cal_voltage(3,:))
datetick('x')


% Save the results to current calibration file
% -- DON'T FORGET TO UPLOAD THE FILE TO THE SITE --
fid = fopen(fileName,'wb');
if fid < 3
    error(['Cannot open file: ' fileName])
end
fwrite(fid,cal_voltage,'float32');
fclose(fid);


