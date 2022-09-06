% YF chamber calibration fix

% Merge chamber calibration files for YF

% NickG, June 19, 2008
%------------------------------------------------------
% Merge chamber calibrations
%------------------------------------------------------
VB2MatlabDateOffset = 693960;
GMToffset = 8/24;

filename1 = 'D:\Nick\data cleaning\YF\chamber_calfile_merge_20080618\calibrations.cyf_ch';
fid1 = fopen(filename1,'r');
if fid1 < 3
    error(['Cannot open file: ' filename1])
end
cal_voltage1 = fread(fid1,[30 inf],'float32');
fclose(fid1);

filename2 = 'D:\Nick\data cleaning\YF\chamber_calfile_merge_20080618\Calibrations_20070919.cyf_ch';
fid2 = fopen(filename2,'r');
if fid2 < 3
    error(['Cannot open file: ' filename2])
end
cal_voltage2 = fread(fid2,[30 inf],'float32');
fclose(fid2);

cal_voltage_tmp = [cal_voltage2'; cal_voltage1'];
cal_voltage=cal_voltage_tmp';
decDOY=(cal_voltage(1,:)+cal_voltage(2,:)+VB2MatlabDateOffset-GMToffset);
% ---------- fix -------------------------------------
% find bad chamber cal 
% 

% ----------- end of fix -------------------------------

% Save the merged chamber cal file
fid = fopen(filename1,'wb');
if fid < 3
    error(['Cannot open file: ' fileName])
end
fwrite(fid,cal_voltage,'float32');
fclose(fid);

