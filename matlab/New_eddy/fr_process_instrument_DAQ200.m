function Instrument_data = fr_process_instrument_DAQ200(Instrument_data,configIn,dateIn,i);
% Instrument_data = fr_process_instrument_DAQ200(Instrument_data,configIn,dateIn,i);
%        
% Stadard processing of DAQ bood: Channel reordering and removal of zero measurements from non-Tc
% channel

Instrument_data.EngUnits = Instrument_data.EngUnits(:,configIn.Instrument(i).ChanReorder);
Instrument_data.EngUnits(:,6:end) = ...
    Instrument_data.EngUnits(:,6:end) - Instrument_data.EngUnits(:,5) * ones(1,configIn.Instrument(i).NumOfChans-5);
