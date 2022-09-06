function Instrument_data = fr_instrument_resample(configIn,systemNum,Instrument_data)

for currentInstrument = configIn.System(systemNum).Instrument                      % cycle for each instrument in the system
    if configIn.System(systemNum).Fs ~= configIn.Instrument(currentInstrument).Fs  % check if resampling is needed
        P = round(configIn.System(systemNum).Fs ...
                * configIn.Instrument(currentInstrument).Oversample );
        Q = round(configIn.Instrument(currentInstrument).Fs ...
                * configIn.Instrument(currentInstrument).Oversample);
        Instrument_data(currentInstrument).EngUnits = ...
                resample(Instrument_data(currentInstrument).EngUnits,P,Q);  % resample data Fs*P/Q
    end
end % for 
    
