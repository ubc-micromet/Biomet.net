function [CO2_cal,H2O_cal,cal_voltage,calTime,LicorNum] = fr_get_licor_cal_all_types(fileName)

[CO2_cal, H2O_cal, cal_voltage, calTime,LicorNum] = fr_get_Licor_cal(fileName);

ind_6252 = find(LicorNum == 209);
if ~isempty(ind_6252)
   [CO2_cal_6252,H2O_cal_6252] = fr_get_licor6252_cal(fileName,calTime(ind_6252));
   CO2_cal(ind_6252,:) = CO2_cal_6252;
   H2O_cal(ind_6252,:) = NaN;
end

ind_800 = find(isnan(LicorNum));
if ~isempty(ind_800)
   [CO2_cal_800,H2O_cal_800] = fr_get_li800_cal(fileName,calTime(ind_800));
   CO2_cal(ind_800,:) = CO2_cal_800;
   H2O_cal(ind_800,:) = NaN;
end
