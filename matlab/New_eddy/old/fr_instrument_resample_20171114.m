function Instrument_data = fr_instrument_resample(configIn,systemNum,Instrument_data)
%
%
%
% Revisions:
%
%   Oct 18, 2017 (Zoran)
%       - Major revisions
%       - Added special parameter in the instrument config part
%       .Resampling_type that enables resampling of data using interp1
%       function.  This will be useful when:
%         - instruments are measuring data at random intervals but having the timing
%         indexes stored with the data (example LGR instruments measuring
%         at a frequency that should be 10 Hz but instead it's ~220/18
%         - a CSAT3 sonics is set to measure at 60Hz that need to be converted
%         to 20Hz
%       - An attempt was made to keep the program operating in the legacy
%       way if the Resampling_type is not set
%
%   Dec 12, 2003
%       - changed from mean removal to increased N for the resample function (N=100)
%

% cycle for each instrument in the system
for currentInstrument = configIn.System(systemNum).Instrument                      
    Fs_instrument = configIn.Instrument(currentInstrument).Fs ;
    Fs_system = configIn.System(systemNum).Fs;
    if Fs_system ~= Fs_instrument % check if resampling is needed
        % instruments can have different modes of resampling.
        if isfield(configIn.Instrument(currentInstrument),'Resampling_type')...
                & ~isempty(configIn.Instrument(currentInstrument).Resampling_type)
            % If there is an non-empty field named Resampling_type 
            switch configIn.Instrument(currentInstrument).Resampling_type
                case 1;
                    % This is an LGR instrument that is measured at 10Hz
                    % but it actually stores data at ~220/18 Hz
                    % The resampling to new frequency (either up to 20Hz or
                    % down to 10Hz) will be done by utilizing the time
                    % stamp stored as the last channel in the EngUnits
                    % matrix.
                    
                    % First extract time and convert it to seconds
                    tv = Instrument_data(currentInstrument).EngUnits(:,28);
                    tv_start = fr_round_time(Instrument_data(3).EngUnits(1,28),'sec',1); 
                    tv_seconds = (tv-tv_start)*24*60*60;
                    % Create the target time vector (0 0.1 0.2 ... or 1800
                    % 1800.1 1800.2...]
                    % The "-1/Fs_system/2" parameter reduces the number of
                    % points from 18001 to 18000.
                    tv_seconds_target = round(tv_seconds(1)):1/Fs_system:ceil(tv_seconds(end))-1/Fs_system/2;
                    % interpolate to create the resampled data
                    Instrument_data(currentInstrument).EngUnits = ...
                        interp1(tv_seconds,Instrument_data(currentInstrument).EngUnits, tv_seconds_target);
                case 2
                    % This type of resampling was initially set up for a
                    % CSAT3 from Altaf's TP39 site that was set to sample
                    % at 60Hz instead of 20Hz. The goal was to lower the
                    % samling rate to 20 Hz.
                    % There is no time stamp here so the assumption will be
                    % made that the data has been collected at a uniform
                    % rate (which it is).
                    
                    % Create a "time trace"
                    NumOfSamples = length(Instrument_data(currentInstrument).EngUnits);
                    t_end_seconds = NumOfSamples / Fs_instrument;           % the trace duration in seconds
                    tv_seconds = linspace(0,t_end_seconds,NumOfSamples);    % time vector in seconds
                    % Create the target time vector (0 -> t_end_seconds)
                    tv_seconds_target = 0:1/Fs_system:t_end_seconds-1/Fs_system/2;
                    % Resample by interpolating
                    Instrument_data(currentInstrument).EngUnits = ...
                        interp1(tv_seconds,Instrument_data(currentInstrument).EngUnits, tv_seconds_target);
                    
                otherwise;
            end % switch
            
        else
            % If Resampling_type field is not specified or empty, use the legacy method
            
            % Continue with processing only if the data matrix is not empty
            if ~isempty(Instrument_data(currentInstrument).EngUnits)
                P = round(Fs_system * configIn.Instrument(currentInstrument).Oversample );
                Q = round(Fs_instrument * configIn.Instrument(currentInstrument).Oversample);
                %        Instrument_means = mean(Instrument_data(currentInstrument).EngUnits);     
                len = 100;

                Instrument_data(currentInstrument).EngUnits = ...
                   resample(Instrument_data(currentInstrument).EngUnits,P,Q,len);  % resample data Fs*P/Q use N=100

                % Truncate front and back as they have a ring on them if AVG~=0;
                Instrument_data(currentInstrument).EngUnits = Instrument_data(currentInstrument).EngUnits(len/2:end-len/2,:);

                %        [n,m] = size(Instrument_data(currentInstrument).EngUnits);
                %        Instrument_data(currentInstrument).EngUnits = ...
                %                Instrument_data(currentInstrument).EngUnits + ones(n,1)*Instrument_means;  % resample data Fs*P/Q
            end % isempty    
        end % if isfield
    end % if
  
end % for 
    
