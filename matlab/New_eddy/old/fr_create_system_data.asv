function  [EngUnits,miscVariables,Instrument,configIn,Delays,EngUnits_alignment_only] = fr_create_system_data(configIn,systemNum,Instrument_data,miscVariables)
%
%
%
% (c) Zoran Nesic               File created:       Oct   , 2001
%                               Last modification:  July 18, 2011

% Revisions
% July 18, 2011
%   -added LI-7200 to sonic to air temp conversion section. LI-7200
%   outputs true mixing ratios (i.e. WPL corrected), so no other
%   conversions needed.
%  Apr 28, 2009 (Zoran)
%   - added NaN's for the columns of data that are missing (missing
%   instruments).
% Feb 10, 2004
%   -   Added output structure Instrument to pass the alignment info to the
%   caller function
%
%  Jun 27, 2002 - removed the Instrument.ProcessData part from here to fr_read_and_convert.m
%  July 7, 2003 - fr_instrument_align now takes multiple instruments (no changes to this program)
%  Aug 29, 2003 - allow alignment info to pass into miscVariables structure

% ToDo: 
% - Move standard instrument conversions into switch/case statement
% (keeps code tight)

configIn = fr_init_complete_system(configIn,systemNum);

% STEP - Resample data if needed
Instrument_data = fr_instrument_resample(configIn,systemNum,Instrument_data);

% STEP - Align data
Instrument_data = fr_instrument_align(configIn,systemNum,Instrument_data);

% STEP - Create a data matrix
EngUnits_alignment_only = [];
for currentInstrument = configIn.System(systemNum).Instrument              % cycle for each instrument in the system
    % Extract only channels needed for Eddy calculations
    if ~isempty(Instrument_data(currentInstrument).EngUnits)
        EngUnits_alignment_only = [EngUnits_alignment_only Instrument_data(currentInstrument).EngUnits(:,configIn.Instrument(currentInstrument).CovChans)];     % append each individual instrument
    else
        % if EngUnits are empty, then assign a vector of NaNs
        % Here I also assume that the sonic data (first 4 channels) exist.
        EngUnits_alignment_only = [EngUnits_alignment_only NaN*zeros(size(EngUnits_alignment_only,1),length(configIn.Instrument(currentInstrument).CovChans))];     % append each individual instrument        
    end
end

% From this point on it is assumed that the data contains
% [u v w Ts co2 h2o aux1 aux2 ...]
% Units for co2 and h2o can be either molar densities if IRGA is LI7500 or
% mixing rations if IRGA is LI7000

% STEP - Calculate Delay times
for i = 1:2
    % Make sure array length requested for delay calc is not bigger than
    % actual delay
    if length(EngUnits_alignment_only(:,1)) < configIn.System(systemNum).Delays.ArrayLengths(i) ...
            | isinf(configIn.System(systemNum).Delays.ArrayLengths(i))
        configIn.System(systemNum).Delays.ArrayLengths(i) = length(EngUnits_alignment_only(:,1));
    end 
end

DelTimes = zeros(size(configIn.System(systemNum).Delays.Channels));
for Del_i = 1:length(configIn.System(systemNum).Delays.Channels)
    % Delay time calc here (for co2, h2o, kh2o using w or T as the reference)
    DelTimes(Del_i) = fr_delay( EngUnits_alignment_only(1:configIn.System(systemNum).Delays.ArrayLengths(1),...
        configIn.System(systemNum).Delays.RefChan), ...
        EngUnits_alignment_only(1:configIn.System(systemNum).Delays.ArrayLengths(2),...
        configIn.System(systemNum).Delays.Channels(Del_i)),...
        configIn.System(systemNum).Delays.Span);
    
end

% STEP - Overide delays to those just calculated
EngUnits_delays = configIn.System(systemNum).Delays.Samples;
if isfield(configIn.System(systemNum).Delays, 'Overide') & configIn.System(systemNum).Delays.Overide == 1;
    EngUnits_delays(configIn.System(systemNum).Delays.Channels) = DelTimes;
    Delays.Implemented = DelTimes; % Mar 6, 2004               
else
    Delays.Implemented = configIn.System(systemNum).Delays.Samples(configIn.System(systemNum).Delays.Channels);    
end
Delays.Calculated = DelTimes;

EngUnits = fr_shift(EngUnits_alignment_only, EngUnits_delays);  % remove the delay times from Eddy_HF_data_IN

% STEP - Run extra processing
if isfield(configIn.System(systemNum),'ProcessData') ...
          & ~isempty(configIn.System(systemNum).ProcessData)
    for j=1:length(configIn.System(systemNum).ProcessData)
        eval(char(configIn.System(systemNum).ProcessData(j)));
    end
end

% STEP - Run standard conversions (other than standard Ts to Ta, LI 7500 etc.)
% LI7000 - Convert mole fractions to mixing ratios
if strcmp(configIn.Instrument(configIn.System(systemNum).Instrument(2)).Type,'7000')
   chi = EngUnits(:,6);
   EngUnits(:,5) = EngUnits(:,5)./(1-chi/1000);
   EngUnits(:,6) = EngUnits(:,6)./(1-chi/1000);
   configIn.System(systemNum).ChanUnits(5:6) = {'\mumol/mol dry air','mmol/mol dry air'};
end

% Sonic - Convert sonic to air temperature
if strcmp(configIn.Instrument(configIn.System(systemNum).Instrument(2)).Type,'7500')
    Tsonic = EngUnits(:,4);
    % Calc air temperature and dry air density
    [EngUnits(:,4),rho_a] = Ts2Ta_using_density(Tsonic,miscVariables.BarometricP,EngUnits(:,6));
    configIn.System(systemNum).ChanNames(4) = {'Ta'};
elseif strcmp(configIn.Instrument(configIn.System(systemNum).Instrument(2)).Type,'7000') ...
     | strcmp(configIn.Instrument(configIn.System(systemNum).Instrument(2)).Type,'6262') ...
     | strcmp(configIn.Instrument(configIn.System(systemNum).Instrument(2)).Type,'7200') % "closed" open path, July 18, 2011
    chi = EngUnits(:,6)./(1+EngUnits(:,6)/1000);
    Tsonic   = EngUnits(:,4);
    EngUnits(:,4) = (Tsonic+273.16)./ (1 + 0.32 .* chi ./ 1000) - 273.16;
    configIn.System(systemNum).ChanNames(4) = {'Ta'};
else
    % Do nothing
end

% LI7500 - Convert molar density to mixing ratio
ind = find(strcmp(configIn.Instrument(configIn.System(systemNum).Instrument(2)).Type,'7500'));
for i =1:length(ind)
   %rho_v = EngUnits(:,6)./1000;
   EngUnits(:,5) = EngUnits(:,5)./rho_a .* 1000; % mmol/m^3 to mumol / mol dry air
   EngUnits(:,6) = EngUnits(:,6)./rho_a;         % mmol/m^3 to mmol / mol dry air
   configIn.System(systemNum).ChanUnits(5:6) = {'\mumol/mol dry air','mmol/mol dry air'};
end

% Zoran: Nov 7, 2003 -> added try/catch structure
% Zoran: Feb 10, 2004 -> created a stand alone Instrument() structure (used
% to go under miscVariables.Instrument()
for i = 1:length(Instrument_data);
    try
        Instrument(i).Alignment = Instrument_data(i).Alignment;
    catch
        Instrument(i).Alignment = []; 
    end
end;

