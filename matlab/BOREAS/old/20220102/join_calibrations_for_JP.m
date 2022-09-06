%
% Joining of the two calibration files for OJP. The one was on the OJP_001 until
% that computer died. The other one was created on the OBS_001 that was used as
% a replacement for it.
%


fileName = 'e:\met-data\hhour\calibrations.cj2';
fid = fopen(fileName,'r');
if fid < 3
    error(['Cannot open file: ' fileName])
end
cal_voltage1 = fread(fid,[30 inf],'float32');
fclose(fid);

fileName = 'c:\sites\paoj\hhour\calibrations.cj2';
fid = fopen(fileName,'r');
if fid < 3
    error(['Cannot open file: ' fileName])
end
cal_voltage2 = fread(fid,[30 inf],'float32');
fclose(fid);

cal_voltage = [cal_voltage1  cal_voltage2];

% Save the results
fid = fopen(fileName,'wb');
if fid < 3
    error(['Cannot open file: ' fileName])
end


fwrite(fid,cal_voltage,'float32');
fclose(fid);

