% OBS profile calibration fix 

% NickG, Jan 22, 2009
%------------------------------------------------------
% Fix bad profile licor calibrations for 2008
%------------------------------------------------------
VB2MatlabDateOffset = 693960;
GMToffset = 6/24;

fileName = 'D:\Nick_Share\recalcs\BS\cal_fix_20100817\calibrations.cB2';
fid = fopen(fileName,'r');
if fid < 3
    error(['Cannot open file: ' fileName])
end
cal_voltage = fread(fid,[30 inf],'float32');
fclose(fid);
decDOY=(cal_voltage(1,:)+cal_voltage(2,:)+VB2MatlabDateOffset-GMToffset);

% ---------- fix -------------------------------------
% correct for empty cal1 tank 
% 
ind = find((decDOY>datenum(2010,8,17) & decDOY<datenum(2010,8,18)) & cal_voltage(4,:) < 400);

cal_voltage(4,ind) = 456.52;

% ----------- end of fix -------------------------------

% Save the profile fix results
fid = fopen(fileName,'wb');
if fid < 3
    error(['Cannot open file: ' fileName])
end
fwrite(fid,cal_voltage,'float32');
fclose(fid);

