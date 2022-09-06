function [co2,h2o,Tbench,Plicor]= fr_licor_calc(LicNum,CalDate,co2_mv,h2o_mv,Tbench_mv,Plicor_mv,CO2_cal,H2O_cal)



if exist('CalDate')~=1 | isempty(CalDate)
   CalDate = 'new';
end
if exist('CO2_cal')~=1 | isempty(CO2_cal)
   CO2_cal = [1 0];
end
if exist('H2O_cal')~=1 | isempty(H2O_cal)
   H2O_cal = [1 0];
end
[cp,hp,Tc,Th,pp] = licor(LicNum,CalDate);

Tbench 	= 0.01221*Tbench_mv;
Plicor 	= polyval(pp,Plicor_mv);
[h2o,chi]= fr_licor_h( ...
                 hp, Th, Plicor, Tbench, ...
                 H2O_cal,h2o_mv);
co2      = fr_licor_c( ...
                 cp, Tc, Plicor, Tbench, ...
                 CO2_cal, co2_mv, [], chi);
                     
