function [Stats_New,HF_Data] = yf_calc_module_main(tv_calc,SiteFlag,ExportFlag);
% [Stats_New,HF_Data] = yf_calc_module_main(tv_calc,SiteFlag,ExportFlag);
%
% UBC's main NEE system calculation function
%
%  ExportFlag values:
%
%  1 - HF_data contains Instrument data and System data after conversion to eng units 
%      and alignement (delays due to sample tube etc. are not removed).
%      Stats_New contains Instrument statistics ONLY.
%      This option is to be used when only HF data plotting is needed.
%
%  2 - HF_data contains Instrument data and System data after conversion to eng units, 
%      alignment and removal of delay using delay times as specified in the
%      ini-file.
%      Stats_New contains Instrument and System statistics.
%      This option is for debugging the alignement & delay removal
%
%  See yf_calc_module_main_export_example for debug examples.
%
% (c) Zoran Nesic           File created:             , 2001
%                           Last modification:  Jun 26, 2008
%

%Revisions
% June 26, 2008
%   -miscVariables added as an output parameter to do_eddy_calc so that
%    actual Pbar and Tair used in calculations is passed back to the Stats
%    structure (Nick and Zoran)
% Feb 16, 2005 (kai*)
%   - Moved delay removal into fr_create_system_data, so it is present at
%     for ProcessData statements
%   - Generate HF data with alignment only (ExportFlag == 1) or with
%   additional delay removal (ExportFlag==2)
% Jun 28, 2004 (kai*)
%   - Changed setfield usage for instrument_stat if the instrument field is not yet present (I have not tested it
%     but this might be a difference between the old and new matlab versions).
% Apr 19, 2004 (kai*)
%   - introduced creation of empty system field in system calculation catch statement. Otherwise the order of
%     system fields in the structure changes if the program crashes on the first half-hour of the day and
%     Matlab will not concatenate structures with the same fieldnames in varying order.
% Apr 12, 2004 (kai*)
%   - broke up try/catch so it works on individual instruments/systems
% Feb 10, 2004
%   - moved adding of MiscVariables to Stats_New into the loop to enable
%   the changes of MiscVariables that happen in the "ProcessData" stage to
%   get updated in the Stats_New.MiscVariables.

% March 26, 2003:  place the Configuration data only in Stats(1)
% April 15, 2003:  put date as a field in configIn
% April 23, 2003:  added if ~isempty(extraCalculations); end; lines in to avoid errors when extra calcs are 
%                    off in init file
% May 25, 2003: initiated different way to determine the number of extraCalculation entries to process

% make sure you call fr_set_site if needed!!
if ~exist('SiteFlag') | isempty(SiteFlag)
    SiteFlag        = fr_current_SiteID;                % Get current site ID
end

if ~exist('ExportFlag') 
    ExportFlag        = [];                           % No plotting is a default
end

hhours          = length(tv_calc);                  % calculate the number of hhours
tv_calc         = fr_round_hhour(tv_calc,2);        % Round to end of hhours
configIn        = fr_get_init(SiteFlag,tv_calc(1)); % Get the configuration file

%Initialize results' structure so its elements have this order
%Stats = fr_stats_init_main(configIn,tv_calc);       % 
Stats_New.TimeVector    = [];
Stats_New.RecalcTime    = [];
Stats_New.Configuration = [];
Stats_New.Instrument    = [];
Stats_New.MiscVariables = [];
for i = 1:length(configIn.System)
    eval(['Stats_New.' configIn.System(i).FieldName ' = [];']);
end 
%Stats_New = [];

HF_Data = [];

for i = 1:hhours
    try
        t0 = now;
        currentDate = tv_calc(i);                       % hhour to calculate
        Stats_New = setfield(Stats_New,{i},'TimeVector',currentDate);% 
        Stats_New = setfield(Stats_New,{i},'RecalcTime',now);% 
        configIn  = fr_get_init(SiteFlag,currentDate);  % get the ini file
        %Revision: place the Configuration data only in Stats(1) March 26, 2003        
        
        nSystems        = length(configIn.System);      % the numer of systems to work on
        nInstruments    = length(configIn.Instrument);  % the numer of instruments to work on
        
        
        % STEP - Load and Convert all Instruments to Eng.Units 
        Instrument_data = fr_read_and_convert(currentDate, configIn);
    catch
        disp(['Error reading data:' lasterr])
    end
    
    try
        % STEP - Calculate Avg, Min, Max & Std for all instruments
        Instrument_stats = fr_calc_instrument_stats(Instrument_data, configIn);
        if isempty(Stats_New(i).Instrument)
            Stats_New = setfield(Stats_New,{i},'Instrument',Instrument_stats(1));
        end    
        for j = 1:nInstruments
            Stats_New = setfield(Stats_New,{i},'Instrument',{j},Instrument_stats(j));
        end
        
        % STEP - Create misc. variables (see ini file)
        miscVariables = fr_create_miscVariables(configIn,Instrument_data);
    catch
        disp(['Error calculating instrument stats:' lasterr])
    end
    
    % Zoran, Feb 10, 2004 moved this into the j=1:nSystem loop (see below)
    % Stats_New = setfield(Stats_New,{i},'MiscVariables',miscVariables);   
    
    try
        % STEP - Prepare high-freq. data for export if that option is selected 
        if ~isempty(ExportFlag)
            for j = 1:nInstruments
                HF_Data = setfield(HF_Data,{i},'Instrument',{j},'EngUnits',Instrument_data(j).EngUnits);
                HF_Data = setfield(HF_Data,{i},'Instrument',{j},'Stats',Instrument_stats(j));
            end
        end
    catch
        disp(['Error exporting data: ' lasterr])
    end
    
    for j=1:nSystems   
        try %system analysis
            if configIn.System(j).ON == 1;
                
                nInstruments = length(configIn.System(j).Instrument);       % the number of instruments in the current system
                
                % STEP - Create an EngUnits matrix
                 [EngUnits,miscVariables,Instrument,configIn,Delays,EngUnits_alignment_only] = fr_create_system_data(configIn,j,Instrument_data,miscVariables);                
                 if ~exist('i_conf') ;
                     Stats_New = setfield(Stats_New,{i},'Configuration',configIn);
                     i_conf = i;
                 end
                               
                
                % STEP - Prepare System high-freq. data for export if that option is selected 
                if ExportFlag == 1
                    HF_Data = setfield(HF_Data,{i},'System',{j},'EngUnits',EngUnits_alignment_only);
                else
                    % or process the System calculations
                    
                    % STEP - Select a type of calculation (System.Type)
                    switch upper(configIn.System(j).Type)
                        case 'EDDY',
                            if ExportFlag == 2
                                HF_Data = setfield(HF_Data,{i},'System',{j},'EngUnits',EngUnits);
                            end    
                            [tmp,miscVariables] = do_eddy_calc(EngUnits,miscVariables,configIn,j,currentDate); % miscVariables added as an output parameter, June 26, 2008
                            tmp = setfield(tmp,['Delays'],Delays);
                            Stats_New = setfield(Stats_New,{i},[configIn.System(j).FieldName],tmp);    
                            Stats_New = setfield(Stats_New,{i},[configIn.System(j).FieldName],{1},'MiscVariables',{1},'Instrument',Instrument);
                            
                            % STEP - Perform extra calculations on System data
                            if isfield(configIn.ExtraCalculations,'SystemLevel');
                                extraCalculations = fr_calc_extraCalculations(configIn,j,'SystemLevel',...
                                    Instrument_data, miscVariables, Stats_New,EngUnits);
                                if ~isempty(extraCalculations)
                                    %for currentVariable = 1:length(getfield(configIn.ExtraCalculations,{1},'SystemLevel'))   % cycle for each calculation set
                                    for currentVariable = 1:length(fieldnames(extraCalculations));
                                        extraCalculationsfield = fieldnames(extraCalculations);
                                        Stats_New = setfield(Stats_New,{i},...
                                            [configIn.System(j).FieldName],{1},char(extraCalculationsfield(currentVariable)),...
                                            getfield(extraCalculations,{1},char(extraCalculationsfield(currentVariable))));
                                    end
                                end   
                            end
                        case 'PROFILE',
                        case 'SOILRESP',
                        case 'USERTYPE',
                        otherwise,
                            error 'Wrong system type!'
                    end % switch   
                end
                Stats_New = setfield(Stats_New,{i},'MiscVariables',miscVariables);
            end % if c.System(i).ON
        catch % try system analysis
            Stats_New = setfield(Stats_New,{i},[configIn.System(j).FieldName],[]); % Create field even if empty
            disp(['Error evaluating system ' configIn.System(j).FieldName ': ' lasterr])
        end
    end % for j=1:nSystems
    
    disp(sprintf('%s (%s), (%d/%d), time = %4.2f (s)',datestr(currentDate),FR_DateToFileName(currentDate),i,hhours,(now-t0)*25*60*60));  
end


