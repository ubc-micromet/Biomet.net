function configIn = fr_init_complete_system(configIn,systemNum)
% configIn = fr_init_complete_system(configIn,systemNum)
%
% Gather instrument information that goes into system information
%
% (c) kai*               File created:      Feb 16, 2005
%                        Last modification: Nov 14, 2017

% Revisions:
%
% Mar 19, 2018 (Zoran & Jilmarie)
%   - Had to fix issues with the sites that don't have FluxNames and
%     FluxTypes in their ini files.  They would crash here.
% Nov 14, 2017 (Zoran)
%   - added:
%       configIn.System(systemNum).FluxNames
%       configIn.System(systemNum).FluxTypes

configIn.System(systemNum).CovVector = [];
configIn.System(systemNum).Delays.Samples = [];
configIn.System(systemNum).ChanNames = [];
configIn.System(systemNum).ChanUnits = [];



totalChans = 0;
for i=1:length(configIn.System(systemNum).Instrument)
    nInstrument = configIn.System(systemNum).Instrument(i);
    nInstChan = length(configIn.Instrument(nInstrument).CovChans);
    
    configIn.System(systemNum).CovVector = [ configIn.System(systemNum).CovVector ...
            configIn.Instrument(nInstrument).CovChans + totalChans ];
    
    configIn.System(systemNum).ChanNames = [configIn.System(systemNum).ChanNames configIn.Instrument(nInstrument).ChanNames(configIn.Instrument(nInstrument).CovChans)];
 
    configIn.System(systemNum).ChanUnits = [configIn.System(systemNum).ChanUnits configIn.Instrument(nInstrument).ChanUnits(configIn.Instrument(nInstrument).CovChans)];  

    if isfield(configIn.Instrument(nInstrument),'FluxNames')
        if ~isfield(configIn.System(systemNum),'FluxNames')
            configIn.System(systemNum).FluxNames = [];
        end
        configIn.System(systemNum).FluxNames = [configIn.System(systemNum).FluxNames configIn.Instrument(nInstrument).FluxNames];
    end
      
    if isfield(configIn.Instrument(nInstrument),'FluxTypes')
        if ~isfield(configIn.System(systemNum),'FluxTypes')
            configIn.System(systemNum).FluxTypes = [];
        end
        configIn.System(systemNum).FluxTypes = [configIn.System(systemNum).FluxTypes configIn.Instrument(nInstrument).FluxTypes];
    end
    
    configIn.System(systemNum).Delays.Samples  = [ configIn.System(systemNum).Delays.Samples  configIn.Instrument(nInstrument).Delays.Samples];

    totalChans                  = totalChans + nInstChan;
end
configIn.System(systemNum).MaxColumns = totalChans;

% Default settings for spikes etc.
if ~isfield(configIn,'Spikes') | isempty(configIn.Spikes)
    configIn.System(systemNum).Spikes.ON = 1;
else 
    configIn.System(systemNum).Spikes = configIn.Spikes;
end
if ~isfield(configIn,'Spectra') | isempty(configIn.Spectra)
    configIn.System(systemNum).Spectra.ON = 0;
else
    configIn.System(systemNum).Spectra = configIn.Spectra;
end
if ~isfield(configIn,'Stationarity') | isempty(configIn.Stationarity)
    configIn.System(systemNum).Stationarity.ON = 0;
else
    configIn.System(systemNum).Stationarity = configIn.Stationarity;
end
