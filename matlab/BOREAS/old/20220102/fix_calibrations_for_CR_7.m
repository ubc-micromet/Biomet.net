VB2MatlabDateOffset = 693960;
GMToffset = 8/24;
%Year = 2009;
fileName = 'D:\Nick_Share\recalcs\CR\recalc_20100113\hhour\calibrations.cc2';
fid = fopen(fileName,'r');
if fid < 3
    error(['Cannot open file: ' fileName])
end
cal_voltage = fread(fid,[30 inf],'float32');
fclose(fid);

[n,m] = size(cal_voltage);

decDOY=(cal_voltage(1,:)+cal_voltage(2,:)+VB2MatlabDateOffset-GMToffset);

doy = decDOY -datenum(2009,1,0);
% ---------- fix calibrations ---------------------------

% correct for low flow cal1
ind_badzero = find(doy>=272 & doy <343 |...
                    (doy>188 & doy<191 & cal_voltage(13,:)>50)  );
cal_voltage(6,ind_badzero) = 1;



% Save the results
fid = fopen(fileName,'wb');
if fid < 3
    error(['Cannot open file: ' fileName])
end
fwrite(fid,cal_voltage,'float32');
fclose(fid);
