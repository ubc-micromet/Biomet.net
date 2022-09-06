% PA eddy calibration fix 

% NickG, Jan 20, 2010
%------------------------------------------------------
% Fix bad eddy licor calibrations for 2009
%------------------------------------------------------
VB2MatlabDateOffset = 693960;
GMToffset = 6/24;

fileName = 'D:\Nick_Share\recalcs\PA\recalc_20100105\hhour\calibrations.cp2';
fid = fopen(fileName,'r');
if fid < 3
    error(['Cannot open file: ' fileName])
end
cal_voltage = fread(fid,[30 inf],'float32');
fclose(fid);
decDOY=(cal_voltage(1,:)+cal_voltage(2,:)+VB2MatlabDateOffset-GMToffset);

% ---------- fix -------------------------------------
% 
% 
indx = find((decDOY>datenum(2009,1,1) & decDOY<datenum(2009,1,366)) & cal_voltage(10,:) > -9);

cal_voltage(6,indx) = 1;

indg = find((decDOY>datenum(2009,1,7.5) & decDOY<datenum(2009,1,8.5)) | ...
             (decDOY>datenum(2009,1,314) & decDOY<datenum(2009,1,356)) ); % find bad gain

cal_voltage(6,indg) = 1;
% ----------- end of fix -------------------------------

% Save the eddy cal fix results
fid = fopen(fileName,'wb');
if fid < 3
    error(['Cannot open file: ' fileName])
end
fwrite(fid,cal_voltage,'float32');
fclose(fid);

