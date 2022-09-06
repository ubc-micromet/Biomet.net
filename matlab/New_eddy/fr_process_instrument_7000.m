function Instrument_data = fr_process_instrument_7000(Instrument_data,configIn,dateIn,Instrument_Num);
% Instrument_data = fr_process_instrument_7000(Instrument_data,configIn,i);
%        
% Stadard processing of LiCor 7000: application of calibrations

%revisions
% Feb 3, 2011 (Nick)
%   -commented out Plicor and Tbench: never used or exported

if isfield(configIn.Instrument(Instrument_Num),'Cal')
    co2 = Instrument_data.EngUnits(:,1);
    h2o = Instrument_data.EngUnits(:,2);
%     Tbench = Instrument_data.EngUnits(:,3);
%     Plicor = filtfilt(fir1(10,0.8),1,Instrument_data.EngUnits(:,4));
    
    [CO2_Cal] = configIn.Instrument(Instrument_Num).Cal.CO2;
    [H2O_Cal] = configIn.Instrument(Instrument_Num).Cal.H2O;
    
    Instrument_data.EngUnits(:,1:2) = [CO2_Cal(1).*(co2-CO2_Cal(2)) H2O_Cal(1).*(h2o-H2O_Cal(2))];
end


