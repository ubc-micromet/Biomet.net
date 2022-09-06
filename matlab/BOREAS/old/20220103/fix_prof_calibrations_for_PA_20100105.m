% PA profile calibration fix 

% NickG, Jan 20, 2010
%------------------------------------------------------
% Fix bad profile licor calibrations for 2009
%------------------------------------------------------
VB2MatlabDateOffset = 693960;
GMToffset = 6/24;

fileName = 'D:\Nick_Share\recalcs\PA\recalc_20100105\hhour\calibrations.cp_pr';
fid = fopen(fileName,'r');
if fid < 3
    error(['Cannot open file: ' fileName])
end
cal_voltage = fread(fid,[30 inf],'float32');
fclose(fid);
decDOY=(cal_voltage(1,:)+cal_voltage(2,:)+VB2MatlabDateOffset-GMToffset);

% ---------- fix -------------------------------------
% 
% temp ctl lost in TCH
ind_badT = find((decDOY>datenum(2009,1,33) & decDOY<datenum(2009,1,52)));
cal_voltage(6,ind_badT) = 1;

% dead pump
ind_pmp = find((decDOY>datenum(2009,1,262) & decDOY<datenum(2009,1,268)) & ...
                (cal_voltage(10,:)<150 | cal_voltage(22,:)>2200));
cal_voltage(6,ind_pmp) = 1;

% cal 1 empty
ind_mt = find((decDOY>datenum(2009,1,316) & decDOY<datenum(2009,1,326)) & ...
                cal_voltage(13,:)>300 );
cal_voltage(6,ind_mt) = 1;

% incorrect cal1 [CO2]
ind_badc = find((decDOY>datenum(2009,1,325) & decDOY<datenum(2009,1,331)) );
cal_voltage(4,ind_badc) = 355.55;
% ----------- end of fix -------------------------------

% Save the profile fix results
fid = fopen(fileName,'wb');
if fid < 3
    error(['Cannot open file: ' fileName])
end
fwrite(fid,cal_voltage,'float32');
fclose(fid);

