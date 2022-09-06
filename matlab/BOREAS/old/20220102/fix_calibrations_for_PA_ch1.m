% Fix to deal with the problems arising from a power issue to the
% Profile TCH box, resulting in bad calibrations for DOY 131, 140, 150
% and ongoing DOY 157 to present (June 23, 2005)

% last revision June 23, 2005:  NickG

%------------------------------------------------------
% Fix profile calibrations
%------------------------------------------------------
VB2MatlabDateOffset = 693960;
GMToffset = 6/24;

fileName = '\\paoa001\sites\paoa\hhour\calibrations.cp_ch';
fid = fopen(fileName,'r');
if fid < 3
    error(['Cannot open file: ' fileName])
end
cal_voltage = fread(fid,[30 inf],'float32');
fclose(fid);
decDOY=(cal_voltage(1,:)+cal_voltage(2,:)+VB2MatlabDateOffset-GMToffset);

% ---------- fix -------------------------------------
% remove the all Aug 2005 calibrations
ind = find(decDOY < datenum(2005,8,1) | decDOY >= datenum(2005,9,2) ) ;
cal_voltage = cal_voltage(:,ind);

% ----------- end of fix -------------------------------

% Save the results
fid = fopen(fileName,'wb');
if fid < 3
    error(['Cannot open file: ' fileName])
end
fwrite(fid,cal_voltage,'float32');
fclose(fid);

