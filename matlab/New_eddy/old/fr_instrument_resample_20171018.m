function Instrument_data = fr_instrument_resample(configIn,systemNum,Instrument_data)
%
%
%
% Revisions:
%   Dec 12, 2003
%       - changed from mean removal to increased N for the resample function (N=100)
%

for currentInstrument = configIn.System(systemNum).Instrument                      % cycle for each instrument in the system
    if configIn.System(systemNum).Fs ~= configIn.Instrument(currentInstrument).Fs  % check if resampling is needed
        P = round(configIn.System(systemNum).Fs ...
                * configIn.Instrument(currentInstrument).Oversample );
        Q = round(configIn.Instrument(currentInstrument).Fs ...
           * configIn.Instrument(currentInstrument).Oversample);
%        Instrument_means = mean(Instrument_data(currentInstrument).EngUnits);     
len = 100;

Instrument_data(currentInstrument).EngUnits = ...
   resample(Instrument_data(currentInstrument).EngUnits,P,Q,len);  % resample data Fs*P/Q use N=100

% Truncate front and back as they have a ring on them if AVG~=0;
Instrument_data(currentInstrument).EngUnits = Instrument_data(currentInstrument).EngUnits(len/2:end-len/2,:);

%        [n,m] = size(Instrument_data(currentInstrument).EngUnits);
%        Instrument_data(currentInstrument).EngUnits = ...
%                Instrument_data(currentInstrument).EngUnits + ones(n,1)*Instrument_means;  % resample data Fs*P/Q
             
    end
end % for 
    
