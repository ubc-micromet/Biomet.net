function Instrument_data = fr_process_instrument_GILLR2(Instrument_data,configIn,dateIn,i);
% Instrument_data = fr_process_instrument_GILLR2(Instrument_data,configIn,i);
%        
% Stadard processing of GILLR2: Crosswind correction and conversion of
% speed of sound to sonic temperature

% Here we adjust inputs to fit the format of fr_GILLR2_calc since it
% incorporates all we know about this sonic

sonic_poly = [1 0; 1 0; 1 0; 1 0]; % Inputs here are fundamental units, polynomials have already been applied
chi = 0; % This will cause the sonic temperature not to be converted to air temperature

[sonicOut,Tair_v,sos_corrected, sos] = fr_GillR2_calc(sonic_poly, Instrument_data.EngUnits(:,1:4)',chi,0);

Instrument_data.EngUnits(:,1:4) = sonicOut';