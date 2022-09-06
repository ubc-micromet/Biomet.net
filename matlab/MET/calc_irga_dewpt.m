function[Tdew,mf_wet,mf_dry,Tdew_target] = calc_irga_dewpt(T,RH,dP,P_atm,P_licor,Td,mf_wet_target)

% Program to calculate values for LICOR 6262 H2O calibration
%
%   T = room temp
%   RH = relative humidity/100
%   dP = overpressure (measured with blue pressure transducer box)(in kPa)(mbar*0.1)
%   P = barometric pressure (measured with LICOR)(kPa)
%   Td = dew point temperature that was set = 0 if it is same as calc Tdew (ie temp,
%   pressures, overpressures did not change from original values when setting the dewpoint)
%   Tdew = calc dew point according to Dew Pt. Generator manual
%   mf_wet = mole fraction of H2O for wet air and for setting LICOR potentiometer
%   mf_dry = mole fraction of H2O for dry air
%
%   mf_wet_target = desired mole fraction of H2O for wet air
%   Tdew_target = dew point temperature for setting DPG
%
%   E.Humphreys         Sept 1998
%   Revisions				Mar 9, 2001
%--------------------------------------------------------------------------------------

if ~isempty(mf_wet_target);
   flag = 1;
else;
   flag = 0;
end

if flag ==1
   e_meas_target = mf_wet_target.*P_licor./1000;
   e_target = e_meas_target.*(P_atm+dP)./P_licor;
   z_target = log(e_target/0.61365);
   Tdew_target = 240.97*z_target/(17.502-z_target);
   
   disp(sprintf('Set Tdew = %4.4f degC for a target wet mole fraction = %4.4f mmol/mol',...
      Tdew_target,mf_wet_target));
   
end
 

%--------------------------------------------------------------------------------------
e_sat = 0.61365*exp((17.502*T)./(240.97+T));

e = e_sat*RH;

e_610 =((P_atm+dP)/P_licor)*e;

z = log(e_610/0.61365);

Tdew = 240.97*z/(17.502-z);  %This is the value the dew pt. generator should be set

%Calculate the mole fraction that the licor IRGA should be calibrated to

if Td == 0;
    Tdew = Tdew;
else
    Tdew = Td;
end

e = 0.61365*exp((17.502*Tdew)./(240.97+Tdew));
e_meas = (P_licor*e)/(P_atm+dP);

mf_wet = 1000*(e_meas)/P_licor;  %in mmol/mol of moist air
% this means mf_wet = 1000*e/(P_atm+dP) 

mf_dry = 1000*(e)/(P_atm+dP-e);  %in mmol/mol of dry air
% this means mf_dry = 1000*e_meas/(P_licor - e_meas)




