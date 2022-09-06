function Instrument_data = fr_process_instrument_6262(Instrument_data,configIn,dateIn,i);
% Instrument_data = fr_process_instrument_6262(Instrument_data,configIn,i);
%        
% Stadard processing of LiCor 6262: conversion of mV to mixing ratios

co2 = Instrument_data.EngUnits(:,1);
h2o = Instrument_data.EngUnits(:,2);
Tbench = Instrument_data.EngUnits(:,3);
Plicor = filtfilt(fir1(10,0.8),1,Instrument_data.EngUnits(:,4));

CO2_Cal = configIn.Instrument(i).Cal.CO2;
H2O_Cal = configIn.Instrument(i).Cal.H2O;

[co2,h2o,Tbench,Plicor]= fr_licor_calc(configIn.Instrument(i).SerNum,[],co2,h2o,Tbench,Plicor,CO2_Cal,H2O_Cal);

Instrument_data.EngUnits(:,1:4) = [co2 h2o Tbench Plicor];

