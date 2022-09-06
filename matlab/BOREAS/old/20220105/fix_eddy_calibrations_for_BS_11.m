VB2MatlabDateOffset = 693960;
GMToffset = 6/24;


fileName = 'D:\sites\paob\hhour\calibrations.cb2'
fid = fopen(fileName,'r');
if fid < 3
    error(['Cannot open file: ' fileName])
end
cal_voltage = fread(fid,[30 inf],'float32');
fclose(fid);

decDOY=(cal_voltage(1,:)+cal_voltage(2,:)+VB2MatlabDateOffset-GMToffset);


%  ---------- Praveeena's fix for bad cal  2003 -------------------------------------
 
ind_fix1 = find((decDOY >= datenum(2003,1,0) & decDOY <= datenum(2003,1,366)) & ((cal_voltage(10,:)>500) | (cal_voltage(10,:)<-500)));

cal_voltage(6,ind_fix1) = 1;

ind_fix2 = find((decDOY >= datenum(2003,1,0) & decDOY <= datenum(2003,1,366)) & ((cal_voltage(11,:)>400) | (cal_voltage(11,:)<-400)));

cal_voltage(6,ind_fix2) = 1;
%--------------------------------------------------------------------------

% Save the results
fid = fopen(fileName,'wb');
if fid < 3
    error(['Cannot open file: ' fileName])
end


fwrite(fid,cal_voltage,'float32');
fclose(fid);

