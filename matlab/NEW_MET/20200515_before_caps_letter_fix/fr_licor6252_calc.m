function [co2,Tbench,Pgauge,Plicor] = fr_licor6252_calc(LicNum,CalDate,co2_mv,Tbench_mv,Pbarometric,Pgauge_mv,Pgauge_poly,CO2_cal)
% [co2,Tbench,Pgauge,Plicor] = fr_licor6252_calc(LicNum,CalDate,co2_mv,Tbench_mv,Pbarometric,Pgauge_mv,Pgauge_poly,CO2_cal)
% 
% Converts mV inputs of optical bench temperature, gauge pressure and co2 into their corresponding 
% engineering units using polynomials. For LI-6252 only. For LI-6262, see fr_licor_calc.
%
% Calculates Licor pressure based on barometric pressure and gauge pressure.
%
% (c) dgg         File created: May 6, 2003 (based on Zoran's work, see fr_licor_calc)
%                 Revisions: none

if exist('CalDate')~=1 | isempty(CalDate)
   CalDate = 'new';
end
if exist('CO2_cal')~=1 | isempty(CO2_cal)
   CO2_cal = [1 0];
end

[cp,hp,Tc,Th,pp] = licor(LicNum,CalDate);

Tbench  = 0.01221*Tbench_mv;
Pgauge  = polyval(Pgauge_poly,Pgauge_mv);
Plicor  = Pbarometric - Pgauge;
co2     = fr_licor_c(cp,Tc,Plicor,Tbench,CO2_cal,co2_mv);