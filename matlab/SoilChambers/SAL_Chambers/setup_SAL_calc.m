%% Setup UdeM calculations
%cd D:\NZ\MATLAB\CurrentProjects\UdeM
%addpath('.\local_BIOMET.NET','-begin');
addpath('.\UBC_PC_Setup\Site_specific','-begin');
addpath('.\UBC_PC_Setup\PC_specific','-begin');
%[dataPth,hhourPth,databasePth,csi_netPth] = fr_get_local_path;


return


%% Main structure
%
% Data structure contains one day of data!!
%
%
%      dataOut
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
