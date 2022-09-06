VB2MatlabDateOffset = 693960;
GMToffset = 8/24;
%Year = 2007;
fileName = 'D:\Sites\CR\hhour\calibrations.cc2';
fid = fopen(fileName,'r');
if fid < 3
    error(['Cannot open file: ' fileName])
end
cal_voltage = fread(fid,[30 inf],'float32');
fclose(fid);

[n,m] = size(cal_voltage);

decDOY=(cal_voltage(1,:)+cal_voltage(2,:)+VB2MatlabDateOffset-GMToffset);

doy = decDOY -datenum(2007,1,0);
% ---------- fix calibrations ---------------------------
% correct for wrong cal1 tank CO2 conc
ind_badcal1 = find(doy>=114.628 & doy<116.5);
cal_voltage(4,ind_badcal1)= 358.0700;

% correct for bad cal zero on DOY170
ind_badzero = find(doy>170 & doy <172 & cal_voltage(10,:) > 200);
cal_voltage(6,ind_badzero) = 1;

% Save the results
fid = fopen(fileName,'wb');
if fid < 3
    error(['Cannot open file: ' fileName])
end
fwrite(fid,cal_voltage,'float32');
fclose(fid);
