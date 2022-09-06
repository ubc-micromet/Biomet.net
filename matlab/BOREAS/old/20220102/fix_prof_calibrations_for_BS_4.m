% OBS profile calibration fix

% Fix incorrect Licor SN after installation of LI-6262 in
%  profile TCH on March 29, 2007

% NickG, April 2, 2007
%------------------------------------------------------
% Fix profile calibrations
%------------------------------------------------------
VB2MatlabDateOffset = 693960;
GMToffset = 6/24;

fileName = '\\paoa001\sites\paob\hhour\calibrations.cb_pr';
fid = fopen(fileName,'r');
if fid < 3
    error(['Cannot open file: ' fileName])
end
cal_voltage = fread(fid,[30 inf],'float32');
fclose(fid);
decDOY=(cal_voltage(1,:)+cal_voltage(2,:)+VB2MatlabDateOffset-GMToffset);

% ---------- fix -------------------------------------
% find bad profile cal values May 11, May 20, May 30 and daily
% since June 6, 2005
ind = find(decDOY >= datenum(2007,3,29,12,0,0) & decDOY < datenum(2007,4,3,12,0,0));
% set ignore flag
cal_voltage(3,ind)= 1037;
% ----------- end of fix -------------------------------

% Save the profile fix results
fid = fopen(fileName,'wb');
if fid < 3
    error(['Cannot open file: ' fileName])
end
fwrite(fid,cal_voltage,'float32');
fclose(fid);

