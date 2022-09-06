%===============================================================
function c = ALO_init_all(dateIn)
%===============================================================
%
% (c) Zoran Nesic           File created:       Nov  7, 2003
%                           Last modification:  Nov  7, 2003 
%

%
%   Revisions:
% 
%

Dates    = zeros(1,100);
% All times are GMT
Dates(1) = datenum(2002,9,30,0,30,0);                     % system set up

% The following line needs to be changed when dateIn becomes datenum (not a string yyyymmddQQ)
dateIn = datenum(str2num(dateIn(1:4)),str2num(dateIn(5:6)),str2num(dateIn(7:8)),str2num(dateIn(9:10))/96*24,0,0);

%-------------------------------
% Common 
%-------------------------------
c.PC_name       = fr_get_pc_name;
[c.path,c.hhour_path,c.database_path] = fr_get_local_path;
c.ext           = '.DA';
c.hhour_ext     = '.ALO.mat';
c.site          = 'ALO';
localPCname	   = 'ALO';							% check for this name later on to select 
															% dataBase option (see nTair below)

% Instrument numbers in the order of their dependency
% (independent first)

nHFDATA = 1;     % High frequency file
nCLDATA = 2;     % Climate data file
nSONIC = 3;      % Sonic CSAT3 
nIRGA  = 4;      % LI-7500 IRGA
nPb    = 5;      % barometric pressure (from Climate data)
nTair  = 6;      % from Climate data

% Variables listed within this section will become part of the
% output stats
c.MiscVariables(1).Name             = 'BarometricP';
c.MiscVariables(1).Execute          = {['nPb = ' num2str(nPb) ';'],...
    											   'miscVar = mean(Instrument_data(nPb).EngUnits);'};
c.MiscVariables(2).Name             = 'Tair';
c.MiscVariables(2).Execute          = {['nTair = ' num2str(nTair) ';'],...
                                       'miscVar = mean(Instrument_data(nTair).EngUnits);'};


%------------------------------------------------
% All instruments
%------------------------------------------------

%-----------------------
% High-Frequency data file
%-----------------------
c.Instrument(nHFDATA).Name       = 'HF_data';
c.Instrument(nHFDATA).Type       = 'CR5000';
c.Instrument(nHFDATA).SerNum     = 0;
c.Instrument(nHFDATA).FileType   = 'ALO_HFDATA';      %
c.Instrument(nHFDATA).FileID     = '1';               % String!
c.Instrument(nHFDATA).Fs         = 10;                % Frequency of sampling
c.Instrument(nHFDATA).Oversample = 6;                 % 
c.Instrument(nHFDATA).ChanNumbers = [1:6];            % chans to read from
c.Instrument(nHFDATA).NumOfChans = length(c.Instrument(nHFDATA).ChanNumbers);
c.Instrument(nHFDATA).ChanNames  = {'u','v','w','T_sonic','CO2','H2O'};
c.Instrument(nHFDATA).ChanUnits  = {'m/s','m/s','m/s','degC','mmol/m3','mmol/m3'};
c.Instrument(nHFDATA).Poly       =  [];
%c.Instrument(nHFDATA).Poly       =  [1  0;...
%     									1  0;...
%    					  				1  0;...
%   									   1  0; 
%   										1 0 ];
c.Instrument(nHFDATA).Delays.Samples = [zeros(1,6)];
c.Instrument(nHFDATA).ProcessData  = [];
c.Instrument(nHFDATA).CovChans     = [];
c.Instrument(nHFDATA).Orientation  = 0;                   % degrees from North 
c.Instrument(nHFDATA).Alignment.Type = 'Slave';            % all instruments get aligned to this instrument (Master)
c.Instrument(nHFDATA).Alignment.ChanNum = [];            % chanel used for the alignment


%-----------------------
% Climate
%-----------------------
c.Instrument(nCLDATA).Name       = 'ALO_Clim';
c.Instrument(nCLDATA).Type       = 'CR23x_data';
c.Instrument(nCLDATA).SerNum     = 0;
c.Instrument(nCLDATA).FileType   = 'ALO_CLDATA';    % "Instrument" type file mean that an actual instrument should be used
c.Instrument(nCLDATA).FileID     = 'yyyyddd';       % yyyyddd is reserved word. Program will recalculate extension. 
c.Instrument(nCLDATA).Fs         = 10/60/30;           % Frequency of sampling 1/30min
c.Instrument(nCLDATA).Oversample = 1;   % 
c.Instrument(nCLDATA).ChanNumbers = [1:7];  
c.Instrument(nCLDATA).NumOfChans = length(c.Instrument(nCLDATA).ChanNumbers);  
c.Instrument(nCLDATA).ChanNames  = {'ID','Year','DOY','HHMM','Tair','RH','Pb'};
c.Instrument(nCLDATA).ChanUnits  = {'1','1','1','1','degC','%','kPa'};
c.Instrument(nCLDATA).Poly       = [];
c.Instrument(nCLDATA).Delays.Samples = [0];
c.Instrument(nCLDATA).ProcessData =  [];
c.Instrument(nCLDATA).CovChans   = [];
c.Instrument(nCLDATA).Alignment.Type = '';
c.Instrument(nCLDATA).Alignment.ChanNum = [];    


%-----------------------
% Sonic #1 definitions:
%-----------------------
c.Instrument(nSONIC).Name       = 'EC Anemometer';
c.Instrument(nSONIC).Type       = 'CSAT3';
c.Instrument(nSONIC).SerNum     = 0;
c.Instrument(nSONIC).FileType   = 'Instrument';        %
c.Instrument(nSONIC).FileID     = num2str(nHFDATA);    % String!
c.Instrument(nSONIC).Fs         = c.Instrument(str2num(c.Instrument(nSONIC).FileID)).Fs;                % Frequency of sampling
c.Instrument(nSONIC).Oversample = c.Instrument(str2num(c.Instrument(nSONIC).FileID)).Oversample;                 % 
c.Instrument(nSONIC).ChanNumbers = [1:4];            % chans to read from
c.Instrument(nSONIC).NumOfChans = length(c.Instrument(nSONIC).ChanNumbers);
c.Instrument(nSONIC).ChanNames  = c.Instrument(str2num(c.Instrument(nSONIC).FileID)).ChanNames(c.Instrument(nSONIC).ChanNumbers);
c.Instrument(nSONIC).ChanUnits  = c.Instrument(str2num(c.Instrument(nSONIC).FileID)).ChanUnits(c.Instrument(nSONIC).ChanNumbers);
c.Instrument(nSONIC).Poly       =  [];
c.Instrument(nSONIC).Delays.Samples = [0 0 0 0];
c.Instrument(nSONIC).ProcessData  = [];
c.Instrument(nSONIC).CovChans     = [1 2 3 4];
c.Instrument(nSONIC).Orientation  = 0;                  % degrees from North 
c.Instrument(nSONIC).Alignment.Type = '';               % all instruments get aligned to this instrument (Master)
c.Instrument(nSONIC).Alignment.ChanNum = [];            % chanel used for the alignment

%-----------------------
% IRGA #1 definitions:
%-----------------------
c.Instrument(nIRGA).Name      = 'EC IRGA';
c.Instrument(nIRGA).Type      = '7500';
c.Instrument(nIRGA).SerNum    = '';
c.Instrument(nIRGA).FileType   = 'Instrument';             % 
c.Instrument(nIRGA).FileID     = num2str(nHFDATA);
c.Instrument(nIRGA).Fs         = c.Instrument(str2num(c.Instrument(nIRGA).FileID)).Fs;                    % Frequency of sampling
c.Instrument(nIRGA).Oversample = c.Instrument(str2num(c.Instrument(nIRGA).FileID)).Oversample;                     % 
c.Instrument(nIRGA).ChanNumbers = [5 6];                % chans to read from the Instrument(nIRGA)
c.Instrument(nIRGA).NumOfChans = length(c.Instrument(nIRGA).ChanNumbers);
c.Instrument(nIRGA).ChanNames  = c.Instrument(str2num(c.Instrument(nIRGA).FileID)).ChanNames(c.Instrument(nIRGA).ChanNumbers);
c.Instrument(nIRGA).ChanUnits  = c.Instrument(str2num(c.Instrument(nIRGA).FileID)).ChanUnits(c.Instrument(nIRGA).ChanNumbers);  
c.Instrument(nIRGA).CovChans   = [1 2];
c.Instrument(nIRGA).Delays.Samples = [0 0];
c.Instrument(nIRGA).Alignment.Type = '';                    % this instrument (Slave) will be aligned with the Master
c.Instrument(nIRGA).Alignment.ChanNum = [];                 % chanel used for the alignment
c.Instrument(nIRGA).ProcessData = [];
%c.Instrument(nIRGA).ProcessData = {['nIRGA = ' num2str(nIRGA) ';'],...
%      '[c.Instrument(nIRGA).CO2_Cal, c.Instrument(nIRGA).H2O_Cal] = fr_get_manual_Licor_cal(char(configIn.site),dateIn);',...
%      'Instrument_data(i).EngUnits(:,1) = (Instrument_data(i).EngUnits(:,1) + c.Instrument(nIRGA).CO2_Cal(2)).*c.Instrument(nIRGA).CO2_Cal(1);',...
%      'Instrument_data(i).EngUnits(:,2) = (Instrument_data(i).EngUnits(:,2) + c.Instrument(nIRGA).H2O_Cal(2)).*c.Instrument(nIRGA).H2O_Cal(1);'};  



%-----------------------
% Barometer
%-----------------------
c.Instrument(nPb).Name       = 'Barometer';
c.Instrument(nPb).Type       = 'LI7500 pressure sensor';
c.Instrument(nPb).SerNum     = 0;
c.Instrument(nPb).FileType   = 'Instrument';    % "Instrument" type file mean that an actual instrument should be used
c.Instrument(nPb).FileID     = num2str(nCLDATA);   % 
c.Instrument(nPb).Fs         = c.Instrument(str2num(c.Instrument(nPb).FileID)).Fs;           % Frequency of sampling 
c.Instrument(nPb).Oversample = c.Instrument(str2num(c.Instrument(nPb).FileID)).Oversample;   % 
c.Instrument(nPb).ChanNumbers = [7];  
c.Instrument(nPb).NumOfChans = length(c.Instrument(nPb).ChanNumbers);  
c.Instrument(nPb).ChanNames  = c.Instrument(str2num(c.Instrument(nPb).FileID)).ChanNames(c.Instrument(nPb).ChanNumbers);
c.Instrument(nPb).ChanUnits  = c.Instrument(str2num(c.Instrument(nPb).FileID)).ChanUnits(c.Instrument(nPb).ChanNumbers);
c.Instrument(nPb).Poly       = [];
c.Instrument(nPb).Delays.Samples = [0];
c.Instrument(nPb).ProcessData =  [];
c.Instrument(nPb).CovChans   = [];
c.Instrument(nPb).Alignment.Type = '';
c.Instrument(nPb).Alignment.ChanNum = [];    

%-----------------------
% mean air temperature (best measurement of thermodynamic air temperature)
%-----------------------
%c.Instrument(nTair).Name       = 'EC mean Tair';
%c.Instrument(nTair).Type       = 'Tair';
%c.Instrument(nTair).SerNum     = 0;
%c.Instrument(nTair).FileType   = 'Instrument';    % "Instrument" type file mean that an actual instrument should be used
%c.Instrument(nTair).FileID     = num2str(nCLDATA);   %
%c.Instrument(nTair).Fs         = c.Instrument(str2num(c.Instrument(nTair).FileID)).Fs;           % Frequency of sampling 
%c.Instrument(nTair).Oversample = c.Instrument(str2num(c.Instrument(nTair).FileID)).Oversample;   % 
%c.Instrument(nTair).ChanNumbers = [5];  
%c.Instrument(nTair).NumOfChans = length(c.Instrument(nTair).ChanNumbers);  
%c.Instrument(nTair).ChanNames  = c.Instrument(str2num(c.Instrument(nTair).FileID)).ChanNames(c.Instrument(nTair).ChanNumbers);
%c.Instrument(nTair).ChanUnits  = c.Instrument(str2num(c.Instrument(nTair).FileID)).ChanUnits(c.Instrument(nTair).ChanNumbers);
%c.Instrument(nTair).Poly       = [];
%c.Instrument(nTair).Delays.Samples = [0];
%c.Instrument(nTair).ProcessData = [];
%c.Instrument(nTair).CovChans   = [];
%c.Instrument(nTair).Alignment.Type = '';
%c.Instrument(nTair).Alignment.ChanNum = []; 
c.Instrument(nTair).Name       = 'EC mean Tair';
c.Instrument(nTair).Type       = 'Tair';
c.Instrument(nTair).SerNum     = 0;
c.Instrument(nTair).FileType   = 'Instrument';    % "Instrument" type file mean that an actual instrument should be used
c.Instrument(nTair).FileID     = num2str(nSONIC);   %
c.Instrument(nTair).Fs         = c.Instrument(str2num(c.Instrument(nTair).FileID)).Fs;           % Frequency of sampling 
c.Instrument(nTair).Oversample = c.Instrument(str2num(c.Instrument(nTair).FileID)).Oversample;   % 
c.Instrument(nTair).ChanNumbers = [4];  
c.Instrument(nTair).NumOfChans = length(c.Instrument(nTair).ChanNumbers);  
c.Instrument(nTair).ChanNames  = c.Instrument(str2num(c.Instrument(nTair).FileID)).ChanNames(c.Instrument(nTair).ChanNumbers);
c.Instrument(nTair).ChanUnits  = c.Instrument(str2num(c.Instrument(nTair).FileID)).ChanUnits(c.Instrument(nTair).ChanNumbers);
c.Instrument(nTair).Poly       = [];
c.Instrument(nTair).Delays.Samples = [0];
c.Instrument(nTair).ProcessData = [];
c.Instrument(nTair).CovChans   = [];
c.Instrument(nTair).Alignment.Type = '';
c.Instrument(nTair).Alignment.ChanNum = []; 




% Space to add hooks for the programs that can be called from the main calc program
c.ExtraCalculations.InstrumentLevel = {};               % add all the extra calculations (Matlab statements as cells)
                                                        % that one wants performed on the instrument data
                                                        
%------------------------------------------------
% Eddy system 1
%
%------------------------------------------------
nMainEddy = 1;
c.System(nMainEddy).ON 				   = 1;                        % system #1 calculations are ON
c.System(nMainEddy).Type            = 'Eddy';                   % eddy correlation system
c.System(nMainEddy).Name            = 'Tower EC, YF site';      % long system name
c.System(nMainEddy).FieldName       = 'MainEddy';               % this is the output structure field name for all the system stats
c.System(nMainEddy).Rotation        = 'three';                  % do three rotations
c.System(nMainEddy).Fs              = 10;                       % sampling freq. for the system (data will be resampled to
                                                                % match this frequency if needed)
c.System(nMainEddy).Instrument      = [ nSONIC nIRGA];          % select instruments (Anemometer + IRGA) for system 1
% removed, see below  c.System(1).MaxColumns      = 4+2;                      % Sonic + IRGA + TCs + (KH2O + Misc)
c.System(nMainEddy).MaxFluxes       = 15;
c.System(nMainEddy).MaxMisc         = 15;
c.System(nMainEddy).CovVector = [];                             % create CovVector and Delays vectore 
c.System(nMainEddy).Delays.Samples = [];                        % based on the intrument setup
c.System(nMainEddy).Delays.RefChan = 4;                         % Delays calculated against this channel (T sonic)
c.System(nMainEddy).Delays.ArrayLengths = [5000 5000];          % the num of points used [ RefChan  DelayedChan]
c.System(nMainEddy).Delays.Span = 100;                          % max LAG (see fr_delay.m)
c.System(nMainEddy).Delays.Channels = [5 6];%[c.Instrument(nIRGA).CovChans];                    % Delays calculated on channels 5 and 6 (CO2 and H2O) 
c.System(nMainEddy).ProcessData = {['nIRGA = ' num2str(nIRGA) ';'],...
                                   ['nSONIC = ' num2str(nSONIC) ';'],...
                                   'Pbarometric = miscVariables.BarometricP;', ...
                                   'Tair_v = Instrument_data(nSONIC).EngUnits(:,4);',...
                                   'H_density = Instrument_data(nIRGA).EngUnits(:,2);',...
                                   'C_density = Instrument_data(nIRGA).EngUnits(:,1);',...
                                   'Tair_a = fr_Tair_Chi_Iteration(H_density, Tair_v, Pbarometric);',...
                                   'Instrument_data(nSONIC).EngUnits(:,4) = Tair_a;',...
                                   '[Cmix,Hmix] = fr_convert_open_path_irga(C_density, H_density,Tair_a,Pbarometric);', ...
                                'Instrument_data(nIRGA).EngUnits(:,1) = Cmix;',...
                                'Instrument_data(nIRGA).EngUnits(:,2) = Hmix;',...
                              'miscVariables.Tair = mean(Tair_a);',...

                                   };
%                                   'Instrument_data(nIRGA).EngUnits(:,1) = Cmix;',...
%                                   'Instrument_data(nIRGA).EngUnits(:,2) = Hmix;',...

totalChans = 0;
for i=1:length(c.System(1).Instrument)
    nInstrument = c.System(1).Instrument(i);
    c.System(1).CovVector       = [ c.System(1).CovVector ...
                                            c.Instrument(nInstrument).CovChans + totalChans ];
    c.System(1).Delays.Samples  = [ c.System(1).Delays.Samples  c.Instrument(nInstrument).Delays.Samples];
    totalChans                  = totalChans + c.Instrument(nInstrument).NumOfChans;
end
c.System(1).MaxColumns = totalChans;

%------------------------------------------------
% add all the extra calculations (Matlab statements as cells)
% that one wants performed on the System data

c.ExtraCalculations.SystemLevel(1).Type = 'Eddy';
c.ExtraCalculations.SystemLevel(1).Name = 'Turbulence_Statistics';
c.ExtraCalculations.SystemLevel(1).ON   = 1;
c.ExtraCalculations.SystemLevel(1).Execute = { ...
            '[Eddy_HF_data] = fr_create_system_data(configIn,1,dataIn,miscVariables);',...
	         'Eddy_delays = configIn.System(1).Delays.Samples;',...
	         '[Eddy_HF_data] = fr_shift(Eddy_HF_data, Eddy_delays);',...
            '[Eddy_HF_data] = fr_rotatn_hf(Eddy_HF_data,[stats(end).MainEddy.Three_Rotations.Angles.Eta stats(end).MainEddy.Three_Rotations.Angles.Theta stats(end).MainEddy.Three_Rotations.Angles.Beta]);',...
            'Skewness_out  = skewness(Eddy_HF_data);',...
            'Kurtosis_out  = kurtosis(Eddy_HF_data);',...
            'Turbulence_Statistics.Skewness = Skewness_out;',...
            'Turbulence_Statistics.Kurtosis = Kurtosis_out;'};
      
c.ExtraCalculations.SystemLevel(2).Type = 'Eddy';
c.ExtraCalculations.SystemLevel(2).Name = 'WPLFluxes';
c.ExtraCalculations.SystemLevel(2).ON   = 1;
foo = c.System(nMainEddy).ProcessData(1:8);
foo(9) = {'Instrument_data(nIRGA).EngUnits(:,1) = C_density.*44.01./1000;'};
foo(10) = {'Instrument_data(nIRGA).EngUnits(:,2) = H_density.*18.02./1000;'};
c.ExtraCalculations.SystemLevel(2).Execute = { ...
      ['nMainEddy = ' num2str(nMainEddy) ';'],...
      ['configIn.System(nMainEddy).ProcessData = [];'],... 
      ['configIn.System(nMainEddy).ProcessData(1) = {' 39 char(foo(1)) 39 '};' ]',... 
      ['configIn.System(nMainEddy).ProcessData(2) = {' 39 char(foo(2)) 39 '};'],... 
      ['configIn.System(nMainEddy).ProcessData(3) = {' 39 char(foo(3)) 39 '};'],... 
      ['configIn.System(nMainEddy).ProcessData(4) = {' 39 char(foo(4)) 39 '};'],... 
      ['configIn.System(nMainEddy).ProcessData(5) = {' 39 char(foo(5)) 39 '};'],... 
      ['configIn.System(nMainEddy).ProcessData(6) = {' 39 char(foo(6)) 39 '};'],... 
      ['configIn.System(nMainEddy).ProcessData(7) = {' 39 char(foo(7)) 39 '};'],... 
      ['configIn.System(nMainEddy).ProcessData(8) = {' 39 char(foo(8)) 39 '};'],... 
      ['configIn.System(nMainEddy).ProcessData(9) = {' 39 char(foo(9)) 39 '};'],... 
      ['configIn.System(nMainEddy).ProcessData(10) = {' 39 char(foo(10)) 39 '};'],...       
      '[Eddy_HF_data] = fr_create_system_data(configIn,nMainEddy,dataIn,miscVariables);',... 
       'tmp = do_eddy_calc(Eddy_HF_data,miscVariables,configIn,nMainEddy,stats(end).TimeVector);',...
       'tmp2 = []; tmp2 = setfield(tmp2,configIn.System(nMainEddy).FieldName,tmp);',...
       '[WPLFluxes] = calc_WPL_fluxes(configIn, nMainEddy, miscVariables, tmp2);'};  
 
 
 %------------------------------------------------
% Spectral calculation 
%
%------------------------------------------------
c.Spectra.ON 					= 1;

c.Spectra.no_spec_bins     = 100;
c.Spectra.no_in_bin    	   = 20;
%c.Spectra.Fs        	   = 20.0; %set spectra calc frequency to that of system in do_eddy_calc.m
c.Spectra.nfft      		   = 2^15;
% No of pts returned by psd, the first is just the average of the data
c.Spectra.n_spec 			   = c.Spectra.nfft/2+1;

c.Spectra.noverlap         = 0;
% Here just give the name of the function used for windowing
c.Spectra.filtX            = 'hamming';
c.Spectra.dflag            = 'linear';

% This referes to the vector that is submitted to fr_calc_spectra which is 
% the same Eddy_HF_data that is required for fr_eddy_calc. If you want something 
% else change this before you calc the spectra
c.Spectra.psdVec           = [1 2 3 4 5 6];
c.Spectra.csdVec           = [1 2 4 5 6];
c.Spectra.csdRef           = 3; % Trace to do co-spectra against, mostly w

%------------------------------------------------
% Spike test 
%
%------------------------------------------------
c.Spikes.ON           = 1;

c.Spikes.bp_vect      = [1250:1250:floor(30 * 60 * c.Instrument(nSONIC).Fs)];
c.Spikes.spike_av     = 'c';
c.Spikes.spike_limit  = 5;
c.Spikes.spike_thold  = [0.25 0.25 0.25 0.2 3.65 0.5]; % 
c.Spikes.despike.ON   = 1;

%------------------------------------------------
% Stationarity test 
%
%------------------------------------------------
c.Stationarity.ON           = 1;

c.Stationarity.no_of_rec    = 6;
c.Stationarity.no_of_subrec = 6;
c.Stationarity.min_length   = 20 * 60 * c.Instrument(nSONIC).Fs; % Minimum record length in samples
c.Stationarity.stationVec   = [1 2 3 4 5 6];
c.Stationarity.stationRef   = 3;

%------------------------------------------------
% Short file information
%
%------------------------------------------------
c.Shortfiles.Remove(1).System       = 'MainEddy'; %from this 'system' field remove the following fields below
c.Shortfiles.Remove(1).Fields       = {'Zero_Rotations', ...
      'Stationarity', ...
      'Turbulence_Statistics'};
c.Shortfiles.Remove(1).ProcessData  = {'for k = 1:length(st); st(k).MainEddy.Spectra.Csd = []; end;',...
      'for k = 1:length(st); st(k).MainEddy.Spectra.fCsd = []; end;',...
      'for k = 1:length(st); st(k).MainEddy.Spectra.fPsd = []; end;',...
      'for k = 1:length(st); st(k).MainEddy.Spectra.Psd = st(k).MainEddy.Spectra.Psd(:,[4 5 6]); end',...
      'for k = 1:length(st); st(k).MainEddy.Three_Rotations.LinDtr = []; end',...
      'for k = 1:length(st); st(k).MainEddy.Three_Rotations.AvgDtr.Cov = []; end',...
   };
c.Shortfiles.Remove(2).System       = 'Instrument'; %from this 'system' field remove the following fields below
c.Shortfiles.Remove(2).Fields       = {'Name',...
    'Type',...
    'SerNum',...
    'ChanNames',...
    'ChanUnits',...
    'Std'};