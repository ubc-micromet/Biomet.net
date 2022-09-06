function InstrumentStats = fr_calc_instrument_stats(Instrument_data, configIn)
%
%
%
%
% (c) Zoran Nesic           File created:       Jun 27, 2002
%                           Last modification:  Jan 28, 2008

% Revisions
% Jan 28, 2008 (Z)
%  - Added diagnostic flag extraction for CSAT3 (used the same setup as for
%    LI-7500)
% Apr 29, 2005
%   added covariance calculations to Instrument.MiscVariables for sonics
%   (Z)
% Jun 30, 2004 (kai*)
% Introduced calculation of additional sonic stats (stats, cov & spectra after rot) if 
% configIn.Instrument(i) is a sonic and .SonicStats == 1
% Mar 31,2003 - deals with halfhours where sensor info is missing


nInstrument = length(configIn.Instrument);
InstrumentStats(nInstrument).Name = [];
InstrumentStats(nInstrument).Type = [];
InstrumentStats(nInstrument).SerNum = [];
InstrumentStats(nInstrument).ChanNames = [];
InstrumentStats(nInstrument).ChanUnits = [];
InstrumentStats(nInstrument).Avg = [];
InstrumentStats(nInstrument).Min = [];
InstrumentStats(nInstrument).Max = [];
InstrumentStats(nInstrument).Std = [];
InstrumentStats(nInstrument).MiscVariables.NumOfSamples = [];
for i=1:nInstrument
    InstrumentStats(i).Name = configIn.Instrument(i).Name;
    InstrumentStats(i).Type = configIn.Instrument(i).Type;
    InstrumentStats(i).SerNum = configIn.Instrument(i).SerNum;
    InstrumentStats(i).ChanNames = configIn.Instrument(i).ChanNames;
    InstrumentStats(i).ChanUnits = configIn.Instrument(i).ChanUnits;
    InstrumentStats(i).Avg = mean(Instrument_data(i).EngUnits,1);
    InstrumentStats(i).Min = min(Instrument_data(i).EngUnits,[],1);
    InstrumentStats(i).Max = max(Instrument_data(i).EngUnits,[],1);
    InstrumentStats(i).Std = std(Instrument_data(i).EngUnits,[],1);
    InstrumentStats(i).MiscVariables.NumOfSamples = length(Instrument_data(i).EngUnits);

    switch upper(InstrumentStats(i).Type)
        case {'7500'}
            try
                ind_diag = find(strcmp(lower(configIn.Instrument(i).ChanNames),'diag'));
                if ~isempty(ind_diag)
                    InstrumentStats(i).MiscVariables = fr_get_LI7500_diagnostics(Instrument_data(i).EngUnits(:,ind_diag(1)));        
                end
            end
            
        case {'CSAT3','GILLR2','GILLR3'}
            try %added this Mar 31,2003 - deals with halfhours where sensor info is missing
                % Additinal Sonic Misc Var
                InstrumentStats(i).MiscVariables.CupWindSpeed3D = sqrt(sum(InstrumentStats(i).Avg(1:3).^2));
                InstrumentStats(i).MiscVariables.CupWindSpeed   = sqrt(sum(InstrumentStats(i).Avg(1:2).^2));
                InstrumentStats(i).MiscVariables.WindDirection   = fr_sonic_wind_direction(InstrumentStats(i).Avg(1:2)',InstrumentStats(i).Type);
                % Take care of the orientation
                if isfield(configIn.Instrument(i),'Orientation')
                    Orientation = configIn.Instrument(i).Orientation;
                else
                    Orientation = 0;
                end
                InstrumentStats(i).MiscVariables.WindDirection = mod(InstrumentStats(i).MiscVariables.WindDirection+Orientation+360,360);
                dir = FR_Sonic_wind_direction([Instrument_data(i).EngUnits(:,1:3)]',InstrumentStats(i).Type);
                InstrumentStats(i).MiscVariables.WindDirection_Histogram = histc(dir,0:10:360);
                InstrumentStats(i).Cov = cov(Instrument_data(i).EngUnits);    
                % Extract diagnostic flags for each of the sonic (New: Jan
                % 28, 2008)
                switch upper(InstrumentStats(i).Type)
                    case {'CSAT3'}
                        ind_diag = find(strcmp(lower(configIn.Instrument(i).ChanNames),'diag'));
                        InstrumentStats(i).MiscVariables.BadPointsFlag = fr_get_CSAT3_diagnostics(Instrument_data(i).EngUnits(:,ind_diag(1)));
                    otherwise,
                        
                end % switch
            end
            try
                if isfield(configIn.Instrument(i),'SonicStats') & configIn.Instrument(i).SonicStats == 1
                    theta = 180/pi.*atan2(Instrument_data(i).EngUnits(:,3),sum(Instrument_data(i).EngUnits(:,1:2).^2,2));
                    InstrumentStats(i).MiscVariables.AttackAngle_Histogram = histc(theta,-45:5:45);
                    
                    % Additional Sonics Stats
                    InstrumentStats(i).Cov = cov(Instrument_data(i).EngUnits);
                    [meansSr,statsSr,angles] = FR_rotate(InstrumentStats(i).Avg(1:3),InstrumentStats(i).Cov,'N');
                    [Instrument_data(i).EngUnits_Rotated] = fr_rotatn_hf(Instrument_data(i).EngUnits,angles);      
                    InstrumentStats(i).Avg_Rotated = mean(Instrument_data(i).EngUnits_Rotated);
                    InstrumentStats(i).Min_Rotated = min(Instrument_data(i).EngUnits_Rotated);
                    InstrumentStats(i).Max_Rotated = max(Instrument_data(i).EngUnits_Rotated);
                    InstrumentStats(i).Std_Rotated = std(Instrument_data(i).EngUnits_Rotated);
                    InstrumentStats(i).Cov_Rotated = cov(detrend(Instrument_data(i).EngUnits_Rotated,1));
                    
                    % Spectra of sonic traces
                    configSpec = configIn;
                    configSpec.Spectra.Fs     = configIn.Instrument(i).Fs; %set spectra calc frequency to that of instrument
                    configSpec.Spectra.Fs     = configIn.Instrument(i).Fs; %set no of channels
                    configSpec.Spectra.nfft   = 2^(floor(log2(InstrumentStats(i).MiscVariables.NumOfSamples)));
                    configSpec.Spectra.psdVec = [1 2 3 4];
                    configSpec.Spectra.csdVec = [1 2 4];
                    
                    Spectra_single  = fr_calc_spectra(Instrument_data(i).EngUnits_Rotated(:,1:4), [0 0 0 0],configSpec,[]); 
                    InstrumentStats = setfield(InstrumentStats,{i},'Spectra',Spectra_single);
                end
            end % Sonics
            
    end
end % for 

