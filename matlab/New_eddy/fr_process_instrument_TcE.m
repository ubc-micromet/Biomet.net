function Instrument_data = fr_process_instrument_TcE(Instrument_data,configIn,dateIn,i);
% Instrument_data = fr_process_instrument_TcE(Instrument_data,configIn,dateIn,i);
%        
% Stadard processing of Chromel-Constantan thermocouples: conversion of mV
% to temperature using the CJC and measured zeros
 
CJC     = Instrument_data.EngUnits(:,1) * ones(1,2);
zero_mV = Instrument_data.EngUnits(:,2) * ones(1,2);
Tc_mV   = Instrument_data.EngUnits(:,[3 4]);

Instrument_data.EngUnits(:,[3 4])  = fr_calc_tc((Tc_mV - zero_mV)) + CJC;