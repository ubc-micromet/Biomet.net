% Fix bad CO2 eddy calibration at OBS 

%  fix incorrect instance of Licor 1036
%------------------------------------------------------
% 
%------------------------------------------------------
%
% Load the original file
%
VB2MatlabDateOffset = 693960;
GMToffset = 6/24;

fileName = 'D:\Nick_Share\recalcs\BS\20061115\hhour\calibrations.cb2';
fid = fopen(fileName,'r');
if fid < 3
    error(['Cannot open file: ' fileName])
end
cal_voltage = fread(fid,[30 inf],'float32');
fclose(fid);
decDOY=(cal_voltage(1,:)+cal_voltage(2,:)+VB2MatlabDateOffset-GMToffset);

% fix number 1: correct Licor 1036 to 1036001
ind_wronglicor1 = find(decDOY >= datenum(1999,6,30,3,0,0) & decDOY < datenum(2000,4,19,0,30,0) & cal_voltage(3,:)==1036);
% correct licor SN
cal_voltage(3,ind_wronglicor1)= 1036001;

% fix number 2: correct Licor 1037 to 1037001
ind_wronglicor2 = find(decDOY >= datenum(1999,1,83) & decDOY < datenum(1999,6,30,3,0,0) & cal_voltage(3,:)==1037);
% correct licor SN
cal_voltage(3,ind_wronglicor2)= 1037001;

% fix number 3: correct Licor 1037 to 1037001
ind_wronglicor3 = find(decDOY >= datenum(2001,3,29,19,30,0) & decDOY < datenum(2004,5,28,22,0,0) & cal_voltage(3,:)==1037);
% correct licor SN
cal_voltage(3,ind_wronglicor3)= 1037001;

% Save the eddy fix results
fid = fopen(fileName,'wb');
if fid < 3
    error(['Cannot open file: ' fileName])
end
fwrite(fid,cal_voltage,'float32');
fclose(fid);
