function dataStruct = SAL_ACS_calc_one_day(currentDate,siteID,plotFlag,fullCalcFlag,chambersToCalc,slopesToCalc,flagSaveData)
% dataStruct = SAL_ACS_calc_selected(currentDate,siteID,plotFlag,fullCalcFlag,chambersToCalc,slopesToCalc,flagSaveData)
% 
% Main chamber flux calculation function for SAL ACS system.
%
%
% File created                  Aug 25, 2023
% Last modification:            Aug 25, 2023 (Zoran)
%

% Revisions:
%   


    arg_default('chambersToCalc',Inf);
    arg_default('slopesToCalc',Inf);
    arg_default('plotFlag',false);
    arg_default('fullCalcFlag',false);
    arg_default('flagSaveData',false);
    
    %==================================================================
    % Steps
    %==================================================================
    
    %----------------------------------------------------------------
    %   - Load gas analyzer and climate data into the data structure
    %----------------------------------------------------------------
    currentDate = floor(currentDate(1));                        % date input is a scalar integer (one day processing)
    tx = now;                                                   % Measure the elapsed time
    configIn = fr_get_init(siteID,currentDate);                 % get configuration data
    dataStruct = SAL_read_one_day(currentDate,configIn);       % read one day of data
    dataStruct.tv = currentDate;
    dataStruct.date = datestr(currentDate,'yyyy-mm-dd');
    fprintf('Load data for: %s (%4.1f sec.)\n',...
        datestr(currentDate,'yyyymmdd'),(now-tx)*24*3600);      % print elapsed time
    
    %----------------------------------------------------------------
    %   - Find indexes so each chamber run can have its climate and
    %     LGR data matched for each slope

    %----------------------------------------------------------------
    tx = now;
    indOut = UdeM_find_chamber_indexes(dataStruct,configIn);
    dataStruct.indexes = indOut;
    fprintf('Processed chamber indexes (%6.2f sec.)\n',(now-tx)*24*3600);
    %----------------------------------------------------------------
    %   - Do basic stats for all chamber related data
    %----------------------------------------------------------------
    tx = now;
    dataStruct = UdeM_ACS_calc_basic_stats(dataStruct);
    fprintf('Processed basic stats (%6.2f sec.)\n',(now-tx)*24*3600);
    
    % ----------------------------------------------------------------
    % Exponential fits and flux calculations
    % ----------------------------------------------------------------
    tx = now;
    if fullCalcFlag
        fprintf('Processing fluxes. Full-calculations option. \nThis may take time.  Started at: %s\n',datestr(now));
    else
        fprintf('Processing fluxes (fast option). Started at: %s\n',datestr(now));
    end
    dataStruct = UdeM_ACS_calc_slopes_and_fluxes(dataStruct,plotFlag,fullCalcFlag,chambersToCalc,slopesToCalc);
    fprintf('Processed fluxes (%6.2f sec.)\n',(now-tx)*24*3600);
    
    fileNameOut = fullfile(dataStruct.configIn.hhour_path,sprintf('%s_recalcs_UdeM',datestr(currentDate,'yyyymmdd')));
    if ~flagSaveData 
        % check if the user doesn't want to save the data before existing
        % This function used to save data automatically. 
        lAnswer = questdlg('Do you want to save data? Program will overwrite any existing files!', ...
                         'File save', ...
                         'Yes', 'No', 'No');
        if strcmp(lAnswer,'No'),return,end
    end
    fprintf('%s Saving flux data for %s in file: %s \n',datestr(now),datestr(currentDate,'yyyymmdd'),fileNameOut)
    % Save output structure
    save(fileNameOut,'dataStruct')
end 
    
    
    %[dataPth,hhourPth,databasePth,csi_netPth] = fr_get_local_path;
    
    % Main structure
    %
    % Data structure contains one day of data!!
    %
    %
    %      dataStruct
    %               .configuration: [1x1 struct]
    %
    %               .rawData  - high frequency data (Instrument and Loggers)
    %                   .analyzer
    %                       .CH4_ppm       - data for one day
    %                       .CO2_ppm
    %                       ... (all variables)
    %                       .tv             - time vector for hhour
    %                   .logger
    %                       .CH_CTRL
    %                           ... (all variables)
    %                       .CH_AUX_30min
    %                           ... (all variables)
    %               .data30min - hhour averages (same structure as rawData)
    %                   .analyzer
    %                       .co2.data
    %                       .ch4.data
    %                   .logger
    %                       .CH_CTRL
    %                           ... (all variables)
    %                       .CH_AUX_30min
    %                           ... (all variables)
    %               .chamber()     - all chamber related data
    %                   .sample()  - sample (avg/min/max/std)
    %                       .tv
    %                       .soilTemperature_in [avg/min/max/std]
    %                       .soilTemperature_out [avg/min/max/std]
    %                       .soilVWC_in [avg/min/max/std]
    %                       .soilVWC_out [avg/min/max/std]
    %                       .par_in [avg/min/max/std]
    %                       .par_out [avg/min/max/std]
    %                       .airTemperature [avg/min/max/std]
    %                       .airPressure [avg/min/max/std]
    %                       .co2_dry [avg/min/max/std]
    %                       .ch4_dry [avg/min/max/std]
    %                       .nwo_dry [avg/min/max/std]
    %                       .h2o_dry [avg/min/max/std]
    %                       .indSlope
    %                           .n2o [start end]
    %                           .co2 [start end]
    %                           .ch4 [start end]
    %                       .diag   (detailed diagnostics for this slope -all
    %                               HF data [avg/min/max/std] for this slope)
    %                           .pressureIn [avg/min/max/std]
    %                           .pressureOut [avg/min/max/std]
    %                           ...
   