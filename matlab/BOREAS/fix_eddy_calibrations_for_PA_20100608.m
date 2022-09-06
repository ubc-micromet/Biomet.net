% PA eddy calibration fix 

% NickG, June 3, 2010
%------------------------------------------------------
% Chang licorSN in cal file to reflect new LI-7000 numbering protocol
%------------------------------------------------------
VB2MatlabDateOffset = 693960;
GMToffset = 6/24;

fileName = 'D:\Nick_Share\recalcs\PA\LI7000_h2o_span_problem\hhour\calibrations.cp2';
fid = fopen(fileName,'r');
if fid < 3
    error(['Cannot open file: ' fileName])
end
cal_voltage = fread(fid,[30 inf],'float32');
fclose(fid);
decDOY=(cal_voltage(1,:)+cal_voltage(2,:)+VB2MatlabDateOffset-GMToffset);

% ---------- fix incorrect cal1 conc ----------------------
% 
% 
ind_badcal1 = find(cal_voltage(4,:)<369 & decDOY>datenum(2010,1,155) & ...
                   decDOY<datenum(2010,1,159.5)); 

cal_voltage(4,ind_badcal1) = 369.17;

% ----------- end of fix -------------------------------

% Save the eddy cal fix results
fid = fopen(fileName,'wb');
if fid < 3
    error(['Cannot open file: ' fileName])
end
fwrite(fid,cal_voltage,'float32');
fclose(fid);

