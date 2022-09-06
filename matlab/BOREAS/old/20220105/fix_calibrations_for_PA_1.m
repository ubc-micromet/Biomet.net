VB2MatlabDateOffset = 693960;
GMToffset = 6/24;
Year = 1999;
fileName = 'd:\sites\paoa\hhour\calibrations.cp2';
fid = fopen(fileName,'r');
if fid < 3
    error(['Cannot open file: ' fileName])
end
cal_voltage = fread(fid,[30 inf],'float32');
fclose(fid);

[n,m] = size(cal_voltage);

decDOY=(cal_voltage(1,:)+cal_voltage(2,:)+VB2MatlabDateOffset-GMToffset);

% fix licor number
ind = find(decDOY <= (datenum(1998,6,17)+80/96));
cal_voltage(3,ind)=791;
ind = find(decDOY > (datenum(1998,6,17)+80/96) & decDOY <= (datenum(1999,6,30)+88/96));
cal_voltage(3,ind)=914;
ind = find(decDOY > (datenum(1999,6,30)+88/96));
cal_voltage(3,ind)=1038;

% fix calibration gas values
% fix CAL_1 number for Dec 28, 2004 to Jan 05, 2005
ind = find(decDOY >= datenum(2004,12,28,10,0,0) & decDOY <= datenum(2005,01,05,15,12,0));
% fix CAL_1 corrected value
cal_voltage(4,ind)= cal_voltage(4,ind(end)+1);

% Save the results
fid = fopen(fileName,'wb');
if fid < 3
    error(['Cannot open file: ' fileName])
end
fwrite(fid,cal_voltage,'float32');
fclose(fid);

% calRecord key table:
%
% 1. Date serial number (in VB format)
% 2. Time serial number (in VB format)
% 3. Licor serial number
% 4. CO2 calibration concentration (CAL_1)
% 5. CO2 calibration concentration (CAL_2)
% 6. Flag 'Ignore calibration' (cal not used of ==1)
% 7.
% 8.
% 9. Pbar       manually inserted when LI6252 is used
%10. CO2_mV     (N2)     Corrected
%11. H2O_mV     (N2)     Corrected
%12. CO2_mV     (CAL_1)  Corrected
%13. H2O_mV     (CAL_1)  Corrected
%14. CO2_mV     (CAL_2)  Corrected
%15. H2O_mV     (CAL_2)  Corrected
%16. Pgauge     (N2)
%17. Pgauge     (CAL_1)
%18. Pgauge     (CAL_2)
%19. CO2_mV     (N2)
%20. H2O_mV     (N2)
%21. Tbench_mV  (N2)
%22. Plicor_mV  (N2)
%23. CO2_mV     (CAL_1)
%24. H2O_mV     (CAL_1)
%25. Tbench_mV  (CAL_1)
%26. Plicor_mV  (CAL_1)
%27. CO2_mV     (CAL_2)
%28. H2O_mV     (CAL_2)
%29. Tbench_mV  (CAL_2)
%30. Plicor_mV  (CAL_2)

