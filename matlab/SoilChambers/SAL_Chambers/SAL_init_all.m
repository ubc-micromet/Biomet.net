function configIn = SAL_init_all(dateIn)  
% Parameters, paths and files needed to do SAL chamber flux calculations
%
% File created:              20230825 (Zoran)
% Last modification:         20230825 (Zoran)
% 
%
% Revisions:
%
%

    % Site ID
    configIn.SiteId = 'SAL';

    Dates    = zeros(1,100); %#ok<*NASGU>

    %-------------------------------
    % Common
    %-------------------------------
    configIn.PC_name       = fr_get_pc_name;
    [configIn.path,configIn.hhour_path,configIn.database_path,configIn.csi_path] = fr_get_local_path;
    configIn.ext           = '.mat';
    configIn.hhour_ext     = '.hSAL.mat';
    configIn.site          = 'SAL-FARM';
    configIn.ch_ctrl       = 'ACS_CR23x_final_storage_2.dat';    % name of the chamber control logger
    configIn.localPCname   = fr_get_pc_name;							% check for this name later on to select
    configIn.gmt_to_local  = -8/24;

    %------------------------------------------------
    % All instruments
    %------------------------------------------------
    nPICARRO = 1;
    nCH_CTRL = 2;
    nCH_MET = 3;

    %------------------------------------------------
    % Get logger variable names
    %------------------------------------------------
    configIn = get_23x_variable_names(configIn,dateIn);
    
    %-----------------------
    % Closed path PICARRO CH4/N2O/CO2 definitions:
    %-----------------------
    configIn.Instrument(nPICARRO).varName    = 'PICARRO';
    configIn.Instrument(nPICARRO).Type       = 'analyzer';      % case sensitive!
    configIn.Instrument(nPICARRO).SerNum     = NaN;
    configIn.Instrument(nPICARRO).FileType   = 'PICARRO';          %
    configIn.Instrument(nPICARRO).FileID     = '';           % String!
    configIn.Instrument(nPICARRO).assign_in  = 'caller';        % Create variable LGR in hhour structure

    %-----------------------
    % CH_CTRL logger definitions:
    %-----------------------
    configIn.Instrument(nCH_CTRL).varName    = 'CH_CTRL';
    configIn.Instrument(nCH_CTRL).fileName   = 'ACS_CR23x_final_storage_2';
    configIn.Instrument(nCH_CTRL).Type       = 'logger';        % case sensitive!
    configIn.Instrument(nCH_CTRL).SerNum     = NaN;
    configIn.Instrument(nCH_CTRL).FileType   = 'CSI';           %
    configIn.Instrument(nCH_CTRL).FileID     = '';              % String!
    configIn.Instrument(nCH_CTRL).tableID    = 101;             %
    configIn.Instrument(nCH_CTRL).tableVars  = configIn.varNames.tableID_101;
    configIn.Instrument(nCH_CTRL).assign_in  =  'base';         %
    configIn.Instrument(nCH_CTRL).time_str_flag = [];           % first column is time vector
    configIn.Instrument(nCH_CTRL).tv_input_format = [1 2 3 4];  % type 1, year:2 doy:3 ddhh:4 (implied: sec:5)    
    configIn.Instrument(nCH_CTRL).headerlines = [];             % no header
    configIn.Instrument(nCH_CTRL).defaultNaN = 'NaN';           % default NaN

%     %-----------------------
%     % CTRL_AUX - fast logger definitions:
%     %-----------------------
%     configIn.Instrument(nCH_AUX_Fast).varName    = 'CH_AUX_10s';
%     configIn.Instrument(nCH_AUX_Fast).fileName   = 'AUX_CR1000XSeries_TVC_ACAux_fast';
%     configIn.Instrument(nCH_AUX_Fast).Type       = 'logger';        % case sensitive!
%     configIn.Instrument(nCH_AUX_Fast).SerNum     = 8323;
%     configIn.Instrument(nCH_AUX_Fast).FileType   = 'TOA5';          %
%     configIn.Instrument(nCH_AUX_Fast).FileID     = '101';           % String!
%     configIn.Instrument(nCH_AUX_Fast).assign_in  =  'base';         %
%     configIn.Instrument(nCH_AUX_Fast).time_str_flag = 1;            % first column is time vector
%     configIn.Instrument(nCH_AUX_Fast).headerlines = 4;              % header is 4 lines
%     configIn.Instrument(nCH_AUX_Fast).defaultNaN = 'NaN';           % default NaN

    %-----------------------
    % MET_30min - 30min MET data
    %-----------------------
    configIn.Instrument(nCH_MET).varName    = 'MET_30min';
    configIn.Instrument(nCH_MET).fileName   = 'ACS_CR23x_final_storage_1';
    configIn.Instrument(nCH_MET).Type       = 'logger';        % case sensitive!
    configIn.Instrument(nCH_MET).SerNum     = NaN;
    configIn.Instrument(nCH_MET).FileType   = 'CSI';           %
    configIn.Instrument(nCH_MET).FileID     = '';              % String!
    configIn.Instrument(nCH_MET).tableID    = 102;             %
    configIn.Instrument(nCH_MET).tableVars  = configIn.varNames.tableID_102;    
    configIn.Instrument(nCH_MET).assign_in  =  'base';         %
    configIn.Instrument(nCH_MET).time_str_flag = [];           % N/A
    configIn.Instrument(nCH_CTRL).tv_input_format = [1 2 3 4]; % type 1, year:2 doy:3 ddhh:4 (implied: sec:5)    
    configIn.Instrument(nCH_MET).headerlines = [];             % no header 
    configIn.Instrument(nCH_MET).defaultNaN = 'NaN';           % default NaN

    % The number of chambers in the experiment
    configIn.chNbr = 12; %
    
    % Chamber run time (2h per cycle, 12 cycles per day)
    configIn.sampleTime = 2*3600 / configIn.chNbr;              % seconds per chamber

    %-------------------------------------------------------------
    % Define chamber area and volume
    %-------------------------------------------------------------
    configIn = get_chamber_size(configIn,dateIn);
    
    %-------------------------------------------------------------
    % Define flux processing parameters:
    % - Chamber volume
    % - skipPoints     (points to
    % - deadBand
    % - pointsToTest   (... for t0 search)
    % - timePeriodToFit
    %-------------------------------------------------------------
    configIn = get_fit_parameters(configIn,dateIn);
    
    % Some global fitting parameters
    configIn.globalFitParam.useOriginalFit = 0;  % 1- use fit() function, otherwise use lsqcurvefit()
    configIn.globalFitParam.functionTolerance.co2 = 0.001;
    configIn.globalFitParam.functionTolerance.ch4 = 0.000001;
    configIn.globalFitParam.rmse_envelope_percent = 2;  % when minimizing rmse, find max(dcdt) for rmse<minRMSE*(1+rmse_envelope_percent)


    %---------------------------------------------------------------
    % Define which climate data traces are related to which chamber
    %---------------------------------------------------------------
    configIn = get_traces(configIn,dateIn);

end

%===============================================================
% get_fit_parameters  - setup exponential fit parameters
%                       Note: these settings are date dependant
%===============================================================

function configIn = set_exp_fit_parameters(configIn,chNum,gasType,skipPoints,deadBand,pointsToTest,pointsToFit)
    arg_default('pointsToFit',9999)
    configIn.chamber(chNum).(gasType).fit_exp.skipPoints = skipPoints;
    configIn.chamber(chNum).(gasType).fit_exp.deadBand = deadBand;
    configIn.chamber(chNum).(gasType).fit_exp.pointsToTest = pointsToTest;
    switch gasType
        case 'co2'            
            adjustDeadBand = configIn.chamber(chNum).(gasType).fit_exp.deadBand;
        case 'ch4'            
            adjustDeadBand = configIn.chamber(chNum).(gasType).fit_exp.deadBand/4;
    end
    maxPointsAvailableToFit = configIn.sampleTime ...
                    - configIn.chamber(chNum).(gasType).fit_exp.skipPoints ...
                    - adjustDeadBand ...
                    - configIn.chamber(chNum).(gasType).fit_exp.pointsToTest;
    if pointsToFit == 9999
        % by default use all the points available for the fits
        configIn.chamber(chNum).(gasType).fit_exp.timePeriodToFit =  maxPointsAvailableToFit;
    else
        % otherwise use the minimum between the requested pointsToFit and maxPointsAvailableToFit
        configIn.chamber(chNum).(gasType).fit_exp.timePeriodToFit =  min(maxPointsAvailableToFit,pointsToFit);
    end
                    
end

%===============================================================
% get_fit_parameters  - setup exponential fit parameters
%                       Note: these settings are date dependant
%===============================================================

function configIn = set_lin_fit_parameters(configIn,chNum,gasType,skipPoints,deadBand,pointsToTest,pointsToFit)
    arg_default('pointsToFit',9999)
    configIn.chamber(chNum).(gasType).fit_lin.skipPoints = skipPoints;
    configIn.chamber(chNum).(gasType).fit_lin.deadBand = deadBand;
    configIn.chamber(chNum).(gasType).fit_lin.pointsToTest = pointsToTest;
    maxPointsAvailableToFit = configIn.sampleTime ...
                    - configIn.chamber(chNum).(gasType).fit_lin.skipPoints ...
                    - configIn.chamber(chNum).(gasType).fit_lin.deadBand ...
                    - configIn.chamber(chNum).(gasType).fit_lin.pointsToTest;
    if pointsToFit == 9999
        % by default use all the points available for the fits
        configIn.chamber(chNum).(gasType).fit_lin.timePeriodToFit =  maxPointsAvailableToFit;
    else
        % otherwise use the minimum between the requested pointsToFit and maxPointsAvailableToFit
        configIn.chamber(chNum).(gasType).fit_lin.timePeriodToFit =  min(maxPointsAvailableToFit,pointsToFit);
    end
                    
end

%===============================================================
% get_fit_parameters  - setup quadratic fit parameters
%                       Note: these settings are date dependant
%===============================================================

function configIn = set_quad_fit_parameters(configIn,chNum,gasType,skipPoints,deadBand,pointsToTest,pointsToFit)
    arg_default('pointsToFit',9999)
    configIn.chamber(chNum).(gasType).fit_quad.skipPoints = skipPoints;
    configIn.chamber(chNum).(gasType).fit_quad.deadBand = deadBand;
    configIn.chamber(chNum).(gasType).fit_quad.pointsToTest = pointsToTest;
    maxPointsAvailableToFit = configIn.sampleTime ...
                    - configIn.chamber(chNum).(gasType).fit_quad.skipPoints ...
                    - configIn.chamber(chNum).(gasType).fit_quad.deadBand ...
                    - configIn.chamber(chNum).(gasType).fit_quad.pointsToTest;
    if pointsToFit == 9999
        % by default use all the points available for the fits
        configIn.chamber(chNum).(gasType).fit_quad.timePeriodToFit =  maxPointsAvailableToFit;
    else
        % otherwise use the minimum between the requested pointsToFit and maxPointsAvailableToFit
        configIn.chamber(chNum).(gasType).fit_quad.timePeriodToFit =  min(maxPointsAvailableToFit,pointsToFit);
    end
                    
end

function configIn = get_fit_parameters(configIn,dateIn) %#ok<*INUSD>
    defaultPointsToExpFitCO2  = [];
    defaultPointsToLinFitCO2  = 60;
    defaultPointsToQuadFitCO2 = 60;
    defaultPointsToExpFitCH4  = [];
    defaultPointsToLinFitCH4  = [];
    defaultPointsToQuadFitCH4 = [];
    chNum = 1;
        a = 35; b = 40; c = 20;
        % input parameters               (configIn,chNum,gasType,skipPoints,deadBand,pointsToTest,pointsToFit)
        configIn = set_exp_fit_parameters(configIn,chNum,'co2'  ,a         ,b       ,c           ,defaultPointsToExpFitCO2);
        configIn = set_exp_fit_parameters(configIn,chNum,'ch4'  ,a         ,b       ,c           ,defaultPointsToExpFitCH4);
        configIn = set_lin_fit_parameters(configIn,chNum,'co2'  ,a         ,b       ,c           ,defaultPointsToLinFitCO2);    
        configIn = set_lin_fit_parameters(configIn,chNum,'ch4'  ,a         ,b       ,c           ,defaultPointsToLinFitCH4);
        configIn = set_quad_fit_parameters(configIn,chNum,'co2'  ,a         ,b       ,4*c           ,defaultPointsToQuadFitCO2);    
        configIn = set_quad_fit_parameters(configIn,chNum,'ch4'  ,a         ,b       ,4*c           ,defaultPointsToQuadFitCH4);
    chNum = 2;
        a = 35; b = 40; c = 20;
        % input parameters               (configIn,chNum,gasType,skipPoints,deadBand,pointsToTest,pointsToFit)
        configIn = set_exp_fit_parameters(configIn,chNum,'co2'  ,a         ,b       ,c           ,defaultPointsToExpFitCO2);
        configIn = set_lin_fit_parameters(configIn,chNum,'co2'  ,a         ,b       ,c           ,defaultPointsToLinFitCO2);
        configIn = set_exp_fit_parameters(configIn,chNum,'ch4'  ,a         ,b       ,c           ,defaultPointsToExpFitCH4);
        configIn = set_lin_fit_parameters(configIn,chNum,'ch4'  ,a         ,b       ,c           ,defaultPointsToLinFitCH4);
        configIn = set_quad_fit_parameters(configIn,chNum,'co2'  ,a         ,b       ,c           ,defaultPointsToQuadFitCO2);    
        configIn = set_quad_fit_parameters(configIn,chNum,'ch4'  ,a         ,b       ,c           ,defaultPointsToQuadFitCH4);        
    chNum = 3;
        a = 40; b = 40; c = 20;
        % input parameters               (configIn,chNum,gasType,skipPoints,deadBand,pointsToTest,pointsToFit)
        configIn = set_exp_fit_parameters(configIn,chNum,'co2'  ,a         ,b       ,c           ,defaultPointsToExpFitCO2);
        configIn = set_lin_fit_parameters(configIn,chNum,'co2'  ,a         ,b       ,c           ,defaultPointsToLinFitCO2);
        configIn = set_exp_fit_parameters(configIn,chNum,'ch4'  ,a         ,b       ,c           ,defaultPointsToExpFitCH4);
        configIn = set_lin_fit_parameters(configIn,chNum,'ch4'  ,a         ,b       ,c           ,defaultPointsToLinFitCH4);
        configIn = set_quad_fit_parameters(configIn,chNum,'co2'  ,a         ,b       ,c           ,defaultPointsToQuadFitCO2);    
        configIn = set_quad_fit_parameters(configIn,chNum,'ch4'  ,a         ,b       ,c           ,defaultPointsToQuadFitCH4);
     chNum = 4;
        a = 40; b = 40; c = 20;
        % input parameters               (configIn,chNum,gasType,skipPoints,deadBand,pointsToTest,pointsToFit)
        configIn = set_exp_fit_parameters(configIn,chNum,'co2'  ,a         ,b       ,c           ,defaultPointsToExpFitCO2);
        configIn = set_lin_fit_parameters(configIn,chNum,'co2'  ,a         ,b       ,c           ,defaultPointsToLinFitCO2);
        configIn = set_exp_fit_parameters(configIn,chNum,'ch4'  ,a         ,b       ,c           ,defaultPointsToExpFitCH4);
        configIn = set_lin_fit_parameters(configIn,chNum,'ch4'  ,a         ,b       ,c           ,defaultPointsToLinFitCH4);
        configIn = set_quad_fit_parameters(configIn,chNum,'co2'  ,a         ,b       ,c           ,defaultPointsToQuadFitCO2);    
        configIn = set_quad_fit_parameters(configIn,chNum,'ch4'  ,a         ,b       ,c           ,defaultPointsToQuadFitCH4);
    chNum = 5;
        a = 40; b = 40; c = 20;
        % input parameters               (configIn,chNum,gasType,skipPoints,deadBand,pointsToTest,pointsToFit)
        configIn = set_exp_fit_parameters(configIn,chNum,'co2'  ,a         ,b       ,c           ,defaultPointsToExpFitCO2);
        configIn = set_lin_fit_parameters(configIn,chNum,'co2'  ,a         ,b       ,c           ,defaultPointsToLinFitCO2);
        configIn = set_exp_fit_parameters(configIn,chNum,'ch4'  ,a         ,b       ,c           ,defaultPointsToExpFitCH4);
        configIn = set_lin_fit_parameters(configIn,chNum,'ch4'  ,a         ,b       ,c           ,defaultPointsToLinFitCH4);
        configIn = set_quad_fit_parameters(configIn,chNum,'co2'  ,a         ,b       ,c           ,defaultPointsToQuadFitCO2);    
        configIn = set_quad_fit_parameters(configIn,chNum,'ch4'  ,a         ,b       ,c           ,defaultPointsToQuadFitCH4);
    chNum = 6;
        a = 40; b = 40; c = 20;
        % input parameters               (configIn,chNum,gasType,skipPoints,deadBand,pointsToTest,pointsToFit)
        configIn = set_exp_fit_parameters(configIn,chNum,'co2'  ,a         ,b       ,c           ,defaultPointsToExpFitCO2);
        configIn = set_lin_fit_parameters(configIn,chNum,'co2'  ,a         ,b       ,c           ,defaultPointsToLinFitCO2);
        configIn = set_exp_fit_parameters(configIn,chNum,'ch4'  ,a         ,b       ,c           ,defaultPointsToExpFitCH4);
        configIn = set_lin_fit_parameters(configIn,chNum,'ch4'  ,a         ,b       ,c           ,defaultPointsToLinFitCH4);
        configIn = set_quad_fit_parameters(configIn,chNum,'co2'  ,a         ,b       ,c           ,defaultPointsToQuadFitCO2);    
        configIn = set_quad_fit_parameters(configIn,chNum,'ch4'  ,a         ,b       ,c           ,defaultPointsToQuadFitCH4);
    chNum = 7;
		if dateIn < datenum(2021,1,1)
			a = 35; b = 40; c = 20;   % settings for 2019
		else
			a = 40; b = 40; c = 20;   % settings for 2021
		end
		
        % input parameters               (configIn,chNum,gasType,skipPoints,deadBand,pointsToTest,pointsToFit)
        configIn = set_exp_fit_parameters(configIn,chNum,'co2'  ,a         ,b       ,c           ,defaultPointsToExpFitCO2);
        configIn = set_lin_fit_parameters(configIn,chNum,'co2'  ,a         ,b       ,c           ,defaultPointsToLinFitCO2);
        configIn = set_exp_fit_parameters(configIn,chNum,'ch4'  ,a         ,b       ,c           ,defaultPointsToExpFitCH4);
        configIn = set_lin_fit_parameters(configIn,chNum,'ch4'  ,a         ,b       ,c           ,defaultPointsToLinFitCH4);
        configIn = set_quad_fit_parameters(configIn,chNum,'co2'  ,a         ,b       ,c           ,defaultPointsToQuadFitCO2);    
        configIn = set_quad_fit_parameters(configIn,chNum,'ch4'  ,a         ,b       ,c           ,defaultPointsToQuadFitCH4);
    chNum = 8;
        a = 40; b = 40; c = 20;
        % input parameters               (configIn,chNum,gasType,skipPoints,deadBand,pointsToTest,pointsToFit)
        configIn = set_exp_fit_parameters(configIn,chNum,'co2'  ,a         ,b       ,c           ,defaultPointsToExpFitCO2);
        configIn = set_lin_fit_parameters(configIn,chNum,'co2'  ,a         ,b       ,c           ,defaultPointsToLinFitCO2);
        configIn = set_exp_fit_parameters(configIn,chNum,'ch4'  ,a         ,b       ,c           ,defaultPointsToExpFitCH4);
        configIn = set_lin_fit_parameters(configIn,chNum,'ch4'  ,a         ,b       ,c           ,defaultPointsToLinFitCH4);
        configIn = set_quad_fit_parameters(configIn,chNum,'co2'  ,a         ,b       ,c           ,defaultPointsToQuadFitCO2);    
        configIn = set_quad_fit_parameters(configIn,chNum,'ch4'  ,a         ,b       ,c           ,defaultPointsToQuadFitCH4);
    chNum = 9;
        a = 40; b = 40; c = 20;
        % input parameters               (configIn,chNum,gasType,skipPoints,deadBand,pointsToTest,pointsToFit)
        configIn = set_exp_fit_parameters(configIn,chNum,'co2'  ,a         ,b       ,c           ,defaultPointsToExpFitCO2);
        configIn = set_lin_fit_parameters(configIn,chNum,'co2'  ,a         ,b       ,c           ,defaultPointsToLinFitCO2);
        configIn = set_exp_fit_parameters(configIn,chNum,'ch4'  ,a         ,b       ,c           ,defaultPointsToExpFitCH4);
        configIn = set_lin_fit_parameters(configIn,chNum,'ch4'  ,a         ,b       ,c           ,defaultPointsToLinFitCH4);
        configIn = set_quad_fit_parameters(configIn,chNum,'co2'  ,a         ,b       ,c           ,defaultPointsToQuadFitCO2);    
        configIn = set_quad_fit_parameters(configIn,chNum,'ch4'  ,a         ,b       ,c           ,defaultPointsToQuadFitCH4);
    chNum = 10;
		if dateIn < datenum(2021,1,1)
			a = 45; b = 40; c = 20;   % settings for 2019
		else
			a = 55; b = 40; c = 20;   % settings for 2021
		end 
        % input parameters               (configIn,chNum,gasType,skipPoints,deadBand,pointsToTest,pointsToFit)
        configIn = set_exp_fit_parameters(configIn,chNum,'co2'  ,a         ,b       ,c           ,defaultPointsToExpFitCO2);
        configIn = set_lin_fit_parameters(configIn,chNum,'co2'  ,a         ,b       ,c           ,defaultPointsToLinFitCO2);
        configIn = set_exp_fit_parameters(configIn,chNum,'ch4'  ,a         ,b       ,c           ,defaultPointsToExpFitCH4);
        configIn = set_lin_fit_parameters(configIn,chNum,'ch4'  ,a         ,b       ,c           ,defaultPointsToLinFitCH4);
        configIn = set_quad_fit_parameters(configIn,chNum,'co2'  ,a         ,b       ,4*c           ,defaultPointsToQuadFitCO2);    
        configIn = set_quad_fit_parameters(configIn,chNum,'ch4'  ,a         ,b       ,4*c           ,defaultPointsToQuadFitCH4);
    chNum = 11;
        a = 35; b = 40; c = 20;
        % input parameters               (configIn,chNum,gasType,skipPoints,deadBand,pointsToTest,pointsToFit)
        configIn = set_exp_fit_parameters(configIn,chNum,'co2'  ,a         ,b       ,c           ,defaultPointsToExpFitCO2);
        configIn = set_lin_fit_parameters(configIn,chNum,'co2'  ,a         ,b       ,c           ,defaultPointsToLinFitCO2);
        configIn = set_exp_fit_parameters(configIn,chNum,'ch4'  ,a         ,b       ,c           ,defaultPointsToExpFitCH4);
        configIn = set_lin_fit_parameters(configIn,chNum,'ch4'  ,a         ,b       ,c           ,defaultPointsToLinFitCH4);
        configIn = set_quad_fit_parameters(configIn,chNum,'co2'  ,a         ,b       ,c           ,defaultPointsToQuadFitCO2);    
        configIn = set_quad_fit_parameters(configIn,chNum,'ch4'  ,a         ,b       ,c           ,defaultPointsToQuadFitCH4);
    chNum = 12;
        a = 35; b = 40; c = 20;
        % input parameters               (configIn,chNum,gasType,skipPoints,deadBand,pointsToTest,pointsToFit)
        configIn = set_exp_fit_parameters(configIn,chNum,'co2'  ,a         ,b       ,c           ,defaultPointsToExpFitCO2);
        configIn = set_lin_fit_parameters(configIn,chNum,'co2'  ,a         ,b       ,c           ,defaultPointsToLinFitCO2);
        configIn = set_exp_fit_parameters(configIn,chNum,'ch4'  ,a         ,b       ,c           ,defaultPointsToExpFitCH4);
        configIn = set_lin_fit_parameters(configIn,chNum,'ch4'  ,a         ,b       ,c           ,defaultPointsToLinFitCH4);
        configIn = set_quad_fit_parameters(configIn,chNum,'co2'  ,a         ,b       ,c           ,defaultPointsToQuadFitCO2);    
        configIn = set_quad_fit_parameters(configIn,chNum,'ch4'  ,a         ,b       ,c           ,defaultPointsToQuadFitCH4);
    chNum = 13;
        a = 35; b = 40; c = 20;
        % input parameters               (configIn,chNum,gasType,skipPoints,deadBand,pointsToTest,pointsToFit)
        configIn = set_exp_fit_parameters(configIn,chNum,'co2'  ,a         ,b       ,c           ,defaultPointsToExpFitCO2);
        configIn = set_lin_fit_parameters(configIn,chNum,'co2'  ,a         ,b       ,c           ,defaultPointsToLinFitCO2);
        configIn = set_exp_fit_parameters(configIn,chNum,'ch4'  ,a         ,b       ,c           ,defaultPointsToExpFitCH4);
        configIn = set_lin_fit_parameters(configIn,chNum,'ch4'  ,a         ,b       ,c           ,defaultPointsToLinFitCH4);
        configIn = set_quad_fit_parameters(configIn,chNum,'co2'  ,a         ,b       ,c           ,defaultPointsToQuadFitCO2);    
        configIn = set_quad_fit_parameters(configIn,chNum,'ch4'  ,a         ,b       ,c           ,defaultPointsToQuadFitCH4);
    chNum = 14;
        a = 35; b = 40; c = 20;
        % input parameters               (configIn,chNum,gasType,skipPoints,deadBand,pointsToTest,pointsToFit)
        configIn = set_exp_fit_parameters(configIn,chNum,'co2'  ,a         ,b       ,c           ,defaultPointsToExpFitCO2);
        configIn = set_lin_fit_parameters(configIn,chNum,'co2'  ,a         ,b       ,c           ,defaultPointsToLinFitCO2);
        configIn = set_exp_fit_parameters(configIn,chNum,'ch4'  ,a         ,b       ,c           ,defaultPointsToExpFitCH4);
        configIn = set_lin_fit_parameters(configIn,chNum,'ch4'  ,a         ,b       ,c           ,defaultPointsToLinFitCH4);
        configIn = set_quad_fit_parameters(configIn,chNum,'co2'  ,a         ,b       ,c           ,defaultPointsToQuadFitCO2);    
        configIn = set_quad_fit_parameters(configIn,chNum,'ch4'  ,a         ,b       ,c           ,defaultPointsToQuadFitCH4);
    chNum = 15;
		if dateIn < datenum(2021,1,1)
			a = 45; b = 40; c = 20;   % settings for 2019
		else
			a = 55; b = 40; c = 20;   % settings for 2021
		end
        % input parameters               (configIn,chNum,gasType,skipPoints,deadBand,pointsToTest,pointsToFit)
        configIn = set_exp_fit_parameters(configIn,chNum,'co2'  ,a         ,b       ,c           ,defaultPointsToExpFitCO2);
        configIn = set_lin_fit_parameters(configIn,chNum,'co2'  ,a         ,b       ,c           ,defaultPointsToLinFitCO2);
        configIn = set_exp_fit_parameters(configIn,chNum,'ch4'  ,a         ,b       ,c           ,defaultPointsToExpFitCH4);
        configIn = set_lin_fit_parameters(configIn,chNum,'ch4'  ,a         ,b       ,c           ,defaultPointsToLinFitCH4);
        configIn = set_quad_fit_parameters(configIn,chNum,'co2'  ,a         ,b       ,c           ,defaultPointsToQuadFitCO2);    
        configIn = set_quad_fit_parameters(configIn,chNum,'ch4'  ,a         ,b       ,c           ,defaultPointsToQuadFitCH4);
    chNum = 16;
		if dateIn < datenum(2021,1,1)
			a = 40; b = 40; c = 20;   % settings for 2019
		else
			a = 35; b = 40; c = 20;   % settings for 2021
		end	
        
        % input parameters               (configIn,chNum,gasType,skipPoints,deadBand,pointsToTest,pointsToFit)
        configIn = set_exp_fit_parameters(configIn,chNum,'co2'  ,a         ,b       ,c           ,defaultPointsToExpFitCO2);
        configIn = set_lin_fit_parameters(configIn,chNum,'co2'  ,a         ,b       ,c           ,defaultPointsToLinFitCO2);
        configIn = set_exp_fit_parameters(configIn,chNum,'ch4'  ,a         ,b       ,c           ,defaultPointsToExpFitCH4);
        configIn = set_lin_fit_parameters(configIn,chNum,'ch4'  ,a         ,b       ,c           ,defaultPointsToLinFitCH4);
        configIn = set_quad_fit_parameters(configIn,chNum,'co2'  ,a         ,b       ,c           ,defaultPointsToQuadFitCO2);    
        configIn = set_quad_fit_parameters(configIn,chNum,'ch4'  ,a         ,b       ,c           ,defaultPointsToQuadFitCH4);
    chNum = 17;
        a = 40; b = 40; c = 20;
        % input parameters               (configIn,chNum,gasType,skipPoints,deadBand,pointsToTest,pointsToFit)
        configIn = set_exp_fit_parameters(configIn,chNum,'co2'  ,a         ,b       ,c           ,defaultPointsToExpFitCO2);
        configIn = set_lin_fit_parameters(configIn,chNum,'co2'  ,a         ,b       ,c           ,defaultPointsToLinFitCO2);
        configIn = set_exp_fit_parameters(configIn,chNum,'ch4'  ,a         ,b       ,c           ,defaultPointsToExpFitCH4);
        configIn = set_lin_fit_parameters(configIn,chNum,'ch4'  ,a         ,b       ,c           ,defaultPointsToLinFitCH4);
        configIn = set_quad_fit_parameters(configIn,chNum,'co2'  ,a         ,b       ,c           ,defaultPointsToQuadFitCO2);    
        configIn = set_quad_fit_parameters(configIn,chNum,'ch4'  ,a         ,b       ,c           ,defaultPointsToQuadFitCH4);
    chNum = 18;
        a = 35; b = 40; c = 20;
        % input parameters               (configIn,chNum,gasType,skipPoints,deadBand,pointsToTest,pointsToFit)
        configIn = set_exp_fit_parameters(configIn,chNum,'co2'  ,a         ,b       ,c           ,defaultPointsToExpFitCO2);
        configIn = set_lin_fit_parameters(configIn,chNum,'co2'  ,a         ,b       ,c           ,defaultPointsToLinFitCO2);
        configIn = set_exp_fit_parameters(configIn,chNum,'ch4'  ,a         ,b       ,c           ,defaultPointsToExpFitCH4);
        configIn = set_lin_fit_parameters(configIn,chNum,'ch4'  ,a         ,b       ,c           ,defaultPointsToLinFitCH4);                                               
        configIn = set_quad_fit_parameters(configIn,chNum,'co2'  ,a         ,b       ,c           ,defaultPointsToQuadFitCO2);    
        configIn = set_quad_fit_parameters(configIn,chNum,'ch4'  ,a         ,b       ,c           ,defaultPointsToQuadFitCH4);
end


%=======================================================
% get_traces
%=======================================================
function configIn = get_traces(configIn,dateIn)
    %**********************************************************
    % There is no Pbar recorded here.  Use a constant.
    % (in the future - consider how to automatically get it
    % from the EC system)
    % 
    %**********************************************************
    configIn.Pbar_default = 101300;          % Pa
    
    % If Tair is missing for a chamber, a default of 20 deg C will be used instead
    configIn.Tair_default = 20 + 273.15;     % Tair default

    % first define the common traces for all chambers:
    % {'matlab trace name',  'analyzer/logger', 'inst. name', 'original trace name'}
    for i=1:configIn.chNbr
        configIn.chamber(i).traces = { ...
            'h2o_ppm',          'analyzer', 'PICARRO' ,    'H2O_ppm';...
            'co2_dry',          'analyzer', 'PICARRO' ,    'CO2_dry';...
            'ch4_dry',          'analyzer', 'PICARRO' ,    'CH4_dry';...
            'n2o_dry',          'analyzer', 'PICARRO' ,    'N2O_dry';...
            'pressureInlet',            [],         [],           [];...
            'pressureOutlet',           [],         [],           [];...
            'airTemperature',   'logger',    'CH_CTRL', sprintf('Tc_%d',i);...
            };
    end

    % then define each chamber's individual traces
    configIn.chamber(1).traces = [configIn.chamber(1).traces;
        {
        'PAR_in',                [],         [],              [];...
        'soilTemperature_in',   'logger',   'CH_AUX_30min',  'CHMBR1_SoilTemp_Avg';...
        'soilVWC_in',           'logger',   'CH_AUX_30min',  'CHMBR1_VWC_Avg';...
        'EC_in',                   'logger',   'CH_AUX_30min',  'CHMBR1_EC_Avg';...
        'permittivity_in',      'logger'    'CH_AUX_30min',  'CHMBR1_Permittivity_Avg';...
        }
        ];

    configIn.chamber(2).traces = [configIn.chamber(2).traces;
        {
        'PAR_in',                [],         [],              [];...
        'soilTemperature_in',   [],          [],            [];...
        'soilVWC_in',           [],          [],            [];...
        'EC_in',                   [],          [],            [];...
        'permittivity_in',      [],          [],            [];...
        }
        ];

    configIn.chamber(3).traces = [configIn.chamber(3).traces;
        {
        'PAR_in',                [],         [],              [];...
        'soilTemperature_in',   'logger',   'CH_AUX_30min',  'CHMBR3_SoilTemp_Avg';...
        'soilVWC_in',           'logger',   'CH_AUX_30min',  'CHMBR3_VWC_Avg';...
        'EC_in',                   'logger',   'CH_AUX_30min',  'CHMBR3_EC_Avg';...
        'permittivity_in',      'logger'    'CH_AUX_30min',  'CHMBR3_Permittivity_Avg';...
        }
        ];
    configIn.chamber(4).traces = [configIn.chamber(4).traces;
        {
        'PAR_in',                [],         [],              [];...
        'soilTemperature_in',   'logger',   'CH_AUX_30min',  'CHMBR4_SoilTemp_Avg';...
        'soilVWC_in',           'logger',   'CH_AUX_30min',  'CHMBR4_VWC_Avg';...
        'EC_in',                   'logger',   'CH_AUX_30min',  'CHMBR4_EC_Avg';...
        'permittivity_in',      'logger'    'CH_AUX_30min',  'CHMBR4_Permittivity_Avg';...
        }
        ];

    configIn.chamber(5).traces = [configIn.chamber(5).traces;
        {
        'PAR_in',                [],         [],              [];...
        'soilTemperature_in',   [],          [],            [];...
        'soilVWC_in',           [],          [],            [];...
        'EC_in',                   [],          [],            [];...
        'permittivity_in',      [],          [],            [];...
        }
        ];
    configIn.chamber(6).traces = [configIn.chamber(6).traces;
        {
        'PAR_in',                [],         [],              [];...
        'soilTemperature_in',   'logger',   'CH_AUX_30min',  'CHMBR6_SoilTemp_Avg';...
        'soilVWC_in',           'logger',   'CH_AUX_30min',  'CHMBR6_VWC_Avg';...
        'EC_in',                   'logger',   'CH_AUX_30min',  'CHMBR6_EC_Avg';...
        'permittivity_in',      'logger'    'CH_AUX_30min',  'CHMBR6_Permittivity_Avg';...
        }
        ];
    configIn.chamber(7).traces = [configIn.chamber(7).traces;
        {
        'PAR_in',                [],         [],              [];...
        'soilTemperature_in',   [],          [],            [];...
        'soilVWC_in',           [],          [],            [];...
        'EC_in',                   [],          [],            [];...
        'permittivity_in',      [],          [],            [];...
        }
        ];
    configIn.chamber(8).traces = [configIn.chamber(8).traces;
        {
        'PAR_in',                [],         [],              [];...
        'soilTemperature_in',   'logger',   'CH_AUX_30min',  'CHMBR8_SoilTemp_Avg';...
        'soilVWC_in',           'logger',   'CH_AUX_30min',  'CHMBR8_VWC_Avg';...
        'EC_in',                   'logger',   'CH_AUX_30min',  'CHMBR8_EC_Avg';...
        'permittivity_in',      'logger'    'CH_AUX_30min',  'CHMBR8_Permittivity_Avg';...
        }
        ];
    configIn.chamber(9).traces = [configIn.chamber(9).traces;
        {
        'PAR_in',                [],         [],              [];...
        'soilTemperature_in',   [],          [],            [];...
        'soilVWC_in',           [],          [],            [];...
        'EC_in',                   [],          [],            [];...
        'permittivity_in',      [],          [],            [];...
        }
        ];
    configIn.chamber(10).traces = [configIn.chamber(10).traces;
        {
        'PAR_in',                [],         [],              [];...
        'soilTemperature_in',   'logger',   'CH_AUX_30min',  'CHMBR10_SoilTemp_Avg';...
        'soilVWC_in',           'logger',   'CH_AUX_30min',  'CHMBR10_VWC_Avg';...
        'EC_in',                   'logger',   'CH_AUX_30min',  'CHMBR10_EC_Avg';...
        'permittivity_in',      'logger'    'CH_AUX_30min',  'CHMBR10_Permittivity_Avg';...
        }
        ];
    configIn.chamber(11).traces = [configIn.chamber(11).traces;
        {
        'PAR_in',                [],         [],              [];...
        'soilTemperature_in',   [],          [],            [];...
        'soilVWC_in',           [],          [],            [];...
        'EC_in',                   [],          [],            [];...
        'permittivity_in',      [],          [],            [];...
        }
        ];
    configIn.chamber(12).traces = [configIn.chamber(12).traces;
        {
        'PAR_in',                [],         [],              [];...
        'soilTemperature_in',   'logger',   'CH_AUX_30min',  'CHMBR12_SoilTemp_Avg';...
        'soilVWC_in',           'logger',   'CH_AUX_30min',  'CHMBR12_VWC_Avg';...
        'EC_in',                   'logger',   'CH_AUX_30min',  'CHMBR12_EC_Avg';...
        'permittivity_in',      'logger'    'CH_AUX_30min',  'CHMBR12_Permittivity_Avg';...
        }
        ];
end

%====================================================================
% get_chamber_size  - set and/or calculate chamber area and volume
%                       Note: these settings are date dependant
%====================================================================
function configIn = calc_chamber_volume(configIn,chNum,chamberRadius,ChamberHeight,domeVolume,chamberSlope)
    arg_default('chamberSlope',0);                                  % chamber slope in degrees (default)
    chArea   = chamberRadius^2 * pi * cos(chamberSlope/180*pi);     % m^2 (corrected for slope)
    
    configIn.chamber(chNum).chArea = chArea;            % (m^2) chamber area
    CylinderVolume     =ChamberHeight * chArea;         % (m^3) for cylinder part of the chamber
    configIn.chamber(chNum).chVolume = ...
                        CylinderVolume + domeVolume;    % (m^3) Total volume for the chamber

end

function configIn = get_chamber_size(configIn,dateIn)
    % Default chamber diameter
    chamberRadius = (22.05-2*0.632)*0.0254/2;   % m (calculated based on the specified pipe dimensions)
    chamberSlope    = 0;                        % degrees of chamber tilt (default 0 deg)
    domeVolume = 0.030;                         %(m3) chamber dome average of two measurements (29.4 and 30.6L). Last done Mar 2, 2020 (by Zoran)
    
    if dateIn < datenum(2021,1,1)	
		chNum = 1;
			chamberHeight = 0.0595;                 % updated by Carolina for 2021 measurements
			configIn = calc_chamber_volume(configIn,chNum,chamberRadius,chamberHeight,domeVolume,chamberSlope);
		chNum = 2;
			chamberHeight = 0.0650;                 % updated by Carolina for 2021 measurements
			configIn = calc_chamber_volume(configIn,chNum,chamberRadius,chamberHeight,domeVolume,chamberSlope);
		chNum = 3;
			chamberHeight = 0.0270;                 % updated by Carolina for 2021 measurements
			configIn = calc_chamber_volume(configIn,chNum,chamberRadius,chamberHeight,domeVolume,chamberSlope);
		chNum = 4;
			chamberHeight = 0.0630;                 % updated by Carolina for 2021 measurements
			configIn = calc_chamber_volume(configIn,chNum,chamberRadius,chamberHeight,domeVolume,chamberSlope);
		chNum = 5;
			chamberHeight = 0.0320;                 % updated by Carolina for 2021 measurements
			configIn = calc_chamber_volume(configIn,chNum,chamberRadius,chamberHeight,domeVolume,chamberSlope);
		chNum = 6;
			chamberHeight = 0.0290;                 % updated by Carolina for 2021 measurements
			configIn = calc_chamber_volume(configIn,chNum,chamberRadius,chamberHeight,domeVolume,chamberSlope);
		chNum = 7;
			chamberHeight = 0.0505;                 % updated by Carolina for 2021 measurements
			configIn = calc_chamber_volume(configIn,chNum,chamberRadius,chamberHeight,domeVolume,chamberSlope);
		chNum = 8;
			chamberHeight = 0.0460;                 % updated by Carolina for 2021 measurements
			configIn = calc_chamber_volume(configIn,chNum,chamberRadius,chamberHeight,domeVolume,chamberSlope);
		chNum = 9;
			chamberHeight = 0.0275;                 % updated by Carolina for 2021 measurements
			configIn = calc_chamber_volume(configIn,chNum,chamberRadius,chamberHeight,domeVolume,chamberSlope);
		chNum = 10;
			chamberHeight = 0.0065;                 % updated by Carolina for 2021 measurements
			configIn = calc_chamber_volume(configIn,chNum,chamberRadius,chamberHeight,domeVolume,chamberSlope);
		chNum = 11;
			chamberHeight = 0.0265;                 % updated by Carolina for 2021 measurements
			configIn = calc_chamber_volume(configIn,chNum,chamberRadius,chamberHeight,domeVolume,chamberSlope);
		chNum = 12;
			chamberHeight = 0.0460;                 % updated by Carolina for 2021 measurements
			configIn = calc_chamber_volume(configIn,chNum,chamberRadius,chamberHeight,domeVolume,chamberSlope);
		chNum = 13;
			chamberHeight = 0.0160;                 % updated by Carolina for 2021 measurements
			configIn = calc_chamber_volume(configIn,chNum,chamberRadius,chamberHeight,domeVolume,chamberSlope);
		chNum = 14;
			chamberHeight = 0.0635;                 % updated by Carolina for 2021 measurements
			configIn = calc_chamber_volume(configIn,chNum,chamberRadius,chamberHeight,domeVolume,chamberSlope);
		chNum = 15;
			chamberHeight = 0.0200;                 % updated by Carolina for 2021 measurements
			configIn = calc_chamber_volume(configIn,chNum,chamberRadius,chamberHeight,domeVolume,chamberSlope);
		chNum = 16;
			chamberHeight = 0.0260;                 % updated by Carolina for 2021 measurements
			configIn = calc_chamber_volume(configIn,chNum,chamberRadius,chamberHeight,domeVolume,chamberSlope);
		chNum = 17;
			chamberHeight = 0.0340;                 % updated by Carolina for 2021 measurements
			configIn = calc_chamber_volume(configIn,chNum,chamberRadius,chamberHeight,domeVolume,chamberSlope);
		chNum = 18;
			chamberHeight = 0.0055;                 % updated by Carolina for 2021 measurements
			configIn = calc_chamber_volume(configIn,chNum,chamberRadius,chamberHeight,domeVolume,chamberSlope);
	else
	        
		chNum = 1;
			chamberHeight = 0.0615;                 % from Carolina's email 20200220 for year 2019
			configIn = calc_chamber_volume(configIn,chNum,chamberRadius,chamberHeight,domeVolume,chamberSlope);
		chNum = 2;
			chamberHeight = 0.0670;                 % from Carolina's email 20200220 for year 2019
			configIn = calc_chamber_volume(configIn,chNum,chamberRadius,chamberHeight,domeVolume,chamberSlope);
		chNum = 3;
			chamberHeight = 0.0355;                 % from Carolina's email 20200220 for year 2019
			configIn = calc_chamber_volume(configIn,chNum,chamberRadius,chamberHeight,domeVolume,chamberSlope);
		chNum = 4;
			chamberHeight = 0.0450;                 % from Carolina's email 20200220 for year 2019
			configIn = calc_chamber_volume(configIn,chNum,chamberRadius,chamberHeight,domeVolume,chamberSlope);
		chNum = 5;
			chamberHeight = 0.0435;                 % from Carolina's email 20200220 for year 2019
			configIn = calc_chamber_volume(configIn,chNum,chamberRadius,chamberHeight,domeVolume,chamberSlope);
		chNum = 6;
			chamberHeight = 0.0320;                 % from Carolina's email 20200220 for year 2019
			configIn = calc_chamber_volume(configIn,chNum,chamberRadius,chamberHeight,domeVolume,chamberSlope);
		chNum = 7;
			chamberHeight = 0.0455;                 % from Carolina's email 20200220 for year 2019
			configIn = calc_chamber_volume(configIn,chNum,chamberRadius,chamberHeight,domeVolume,chamberSlope);
		chNum = 8;
			chamberHeight = 0.0515;                 % from Carolina's email 20200220 for year 2019
			configIn = calc_chamber_volume(configIn,chNum,chamberRadius,chamberHeight,domeVolume,chamberSlope);
		chNum = 9;
			chamberHeight = 0.0460;                 % from Carolina's email 20200220 for year 2019
			configIn = calc_chamber_volume(configIn,chNum,chamberRadius,chamberHeight,domeVolume,chamberSlope);
		chNum = 10;
			chamberHeight = 0.0195;                 % from Carolina's email 20200220 for year 2019
			configIn = calc_chamber_volume(configIn,chNum,chamberRadius,chamberHeight,domeVolume,chamberSlope);
		chNum = 11;
			chamberHeight = 0.0285;                 % from Carolina's email 20200220 for year 2019
			configIn = calc_chamber_volume(configIn,chNum,chamberRadius,chamberHeight,domeVolume,chamberSlope);
		chNum = 12;
			chamberHeight = 0.0505;                 % from Carolina's email 20200220 for year 2019
			configIn = calc_chamber_volume(configIn,chNum,chamberRadius,chamberHeight,domeVolume,chamberSlope);
		chNum = 13;
			chamberHeight = 0.0230;                 % from Carolina's email 20200220 for year 2019
			configIn = calc_chamber_volume(configIn,chNum,chamberRadius,chamberHeight,domeVolume,chamberSlope);
		chNum = 14;
			chamberHeight = 0.0480;                 % from Carolina's email 20200220 for year 2019
			configIn = calc_chamber_volume(configIn,chNum,chamberRadius,chamberHeight,domeVolume,chamberSlope);
		chNum = 15;
			chamberHeight = 0.0200;                 % from Carolina's email 20200220 for year 2019
			configIn = calc_chamber_volume(configIn,chNum,chamberRadius,chamberHeight,domeVolume,chamberSlope);
		chNum = 16;
			chamberHeight = 0.0380;                 % from Carolina's email 20200220 for year 2019
			configIn = calc_chamber_volume(configIn,chNum,chamberRadius,chamberHeight,domeVolume,chamberSlope);
		chNum = 17;
			chamberHeight = 0.0415;                 % from Carolina's email 20200220 for year 2019
			configIn = calc_chamber_volume(configIn,chNum,chamberRadius,chamberHeight,domeVolume,chamberSlope);
		chNum = 18;
			chamberHeight = -0.001;                 % from Carolina's email 20200220 for year 2019
			configIn = calc_chamber_volume(configIn,chNum,chamberRadius,chamberHeight,domeVolume,chamberSlope);
	 end  
end

function configIn = get_23x_variable_names(configIn,dateIn)
    configIn.varNames.tableID_101 = {'tableID','Year_RTM','Day_RTM','Hour_Minute_RTM','Seconds_RTM',...
            'ChNum','Tc_1','Tc_2','Tc_3','Tc_4','Tc_5','Tc_6',...
            'Tc_7','Tc_8','Tc_9','Tc_10','Tc_11','Tc_12','Tc_13',...
            'Tc_14','Tc_15','Tc_16','Tc_17','Tc_18','Tc_19','Tc_20',...
            'Tc_21','Tc_22','Tc_23','Tc_24','Tc_25'};
    configIn.varNames.tableID_102 = {'tableID','Year_RTM','Day_RTM','Hour_Minute_RTM','BattV_AVG',...
                'PanelT_AVG','PumpBoxT_AVG','BattV_MAX','PanelT_MAX','PumpBoxT_MAX',...
                'BattV_MIN','PanelT_MIN','PumpBoxT_MIN','BattV_STD','PanelT_STD',...
                'PumpBoxT_STD','Tc_1_AVG','Tc_2_AVG','Tc_3_AVG','Tc_4_AVG',...
                'Tc_5_AVG','Tc_6_AVG','Tc_7_AVG','Tc_8_AVG','Tc_9_AVG',...
                'Tc_10_AVG','Tc_11_AVG','Tc_12_AVG','Tc_13_AVG','Tc_14_AVG',...
                'Tc_15_AVG','Tc_16_AVG','Tc_17_AVG','Tc_18_AVG','Tc_19_AVG',...
                'Tc_20_AVG','Tc_21_AVG','Tc_22_AVG','Tc_23_AVG','Tc_24_AVG',...
                'Tc_25_AVG','Tc_1_MAX','Tc_2_MAX','Tc_3_MAX','Tc_4_MAX','Tc_5_MAX',...
                'Tc_6_MAX','Tc_7_MAX','Tc_8_MAX','Tc_9_MAX','Tc_10_MAX','Tc_11_MAX',...
                'Tc_12_MAX','Tc_13_MAX','Tc_14_MAX','Tc_15_MAX','Tc_16_MAX','Tc_17_MAX',...
                'Tc_18_MAX','Tc_19_MAX','Tc_20_MAX','Tc_21_MAX','Tc_22_MAX','Tc_23_MAX',...
                'Tc_24_MAX','Tc_25_MAX','Tc_MIN','Tc_2_MIN','Tc_3_MIN','Tc_4_MIN','Tc_5_MIN',...
                'Tc_6_MIN','Tc_7_MIN','Tc_8_MIN','Tc_9_MIN','Tc_10_MIN','Tc_11_MIN',...
                'Tc_12_MIN','Tc_13_MIN','Tc_14_MIN','Tc_15_MIN','Tc_16_MIN','Tc_17_MIN',...
                'Tc_18_MIN','Tc_19_MIN','Tc_20_MIN','Tc_21_MIN','Tc_22_MIN','Tc_23_MIN',...
                'Tc_24_MIN','Tc_25_MIN','Tc_STD','Tc_2_STD','Tc_3_STD','Tc_4_STD','Tc_5_STD',...
                'Tc_6_STD','Tc_7_STD','Tc_8_STD','Tc_9_STD','Tc_10_STD','Tc_11_STD','Tc_12_STD',...
                'Tc_13_STD','Tc_14_STD','Tc_15_STD','Tc_16_STD','Tc_17_STD','Tc_18_STD',...
                'Tc_19_STD','Tc_20_STD','Tc_21_STD','Tc_22_STD','Tc_23_STD','Tc_24_STD',...
                'Tc_25_STD','VWC_1_AVG','Ts_1_AVG','VWC_2_AVG','Ts_2_AVG','VWC_3_AVG','Ts_3_AVG',...
                'VWC_4_AVG','Ts_4_AVG','VWC_5_AVG','Ts_5_AVG','VWC_6_AVG','Ts_6_AVG','VWC_7_AVG',...
                'Ts_7_AVG','VWC_8_AVG','Ts_8_AVG','VWC_9_AVG','Ts_9_AVG','VWC_10_AVG','Ts_10_AVG',...
                'VWC_11_AVG','Ts_11_AVG','VWC_12_AVG','Ts_12_AVG','VWC_13_AVG','Ts_13_AVG',...
                'VWC_14_AVG','Ts_14_AVG','VWC_15_AVG','Ts_15_AVG','VWC_16_AVG','Ts_16_AVG',...
                'VWC_17_AVG','Ts_17_AVG','VWC_18_AVG','Ts_18_AVG','VWC_19_AVG','Ts_19_AVG',...
                'VWC_20_AVG','Ts_20_AVG','VWC_21_AVG','Ts_21_AVG','VWC_22_AVG','Ts_22_AVG','VWC_23_AVG',...
                'Ts_23_AVG','VWC_24_AVG','Ts_24_AVG','VWC_1_MAX','Ts_1_MAX','VWC_2_MAX','Ts_2_MAX',...
                'VWC_3_MAX','Ts_3_MAX','VWC_4_MAX','Ts_4_MAX','VWC_5_MAX','Ts_5_MAX','VWC_6_MAX',...
                'Ts_6_MAX','VWC_7_MAX','Ts_7_MAX','VWC_8_MAX','Ts_8_MAX','VWC_9_MAX','Ts_9_MAX',...
                'VWC_10_MAX','Ts_10_MAX','VWC_11_MAX','Ts_11_MAX','VWC_12_MAX','Ts_12_MAX',...
                'VWC_13_MAX','Ts_13_MAX','VWC_14_MAX','Ts_14_MAX','VWC_15_MAX','Ts_15_MAX','VWC_16_MAX',...
                'Ts_16_MAX','VWC_17_MAX','Ts_17_MAX','VWC_18_MAX','Ts_18_MAX','VWC_19_MAX','Ts_19_MAX',...
                'VWC_20_MAX','Ts_20_MAX','VWC_21_MAX','Ts_21_MAX','VWC_22_MAX','Ts_22_MAX','VWC_23_MAX',...
                'Ts_23_MAX','VWC_24_MAX','Ts_24_MAX','VWC_1_MIN','Ts_1_MIN','VWC_2_MIN','Ts_2_MIN',...
                'VWC_3_MIN','Ts_3_MIN','VWC_4_MIN','Ts_4_MIN','VWC_5_MIN','Ts_5_MIN','VWC_6_MIN',...
                'Ts_6_MIN','VWC_7_MIN','Ts_7_MIN','VWC_8_MIN','Ts_8_MIN','VWC_9_MIN','Ts_9_MIN',...
                'VWC_10_MIN','Ts_10_MIN','VWC_11_MIN','Ts_11_MIN','VWC_12_MIN','Ts_12_MIN','VWC_13_MIN',...
                'Ts_13_MIN','VWC_14_MIN','Ts_14_MIN','VWC_15_MIN','Ts_15_MIN','VWC_16_MIN','Ts_16_MIN',...
                'VWC_17_MIN','Ts_17_MIN','VWC_18_MIN','Ts_18_MIN','VWC_19_MIN','Ts_19_MIN','VWC_20_MIN',...
                'Ts_20_MIN','VWC_21_MIN','Ts_21_MIN','VWC_22_MIN','Ts_22_MIN','VWC_23_MIN','Ts_23_MIN',...
                'VWC_24_MIN','Ts_24_MIN','VWC_1_STD','Ts_1_STD','VWC_2_STD','Ts_2_STD','VWC_3_STD',...
                'Ts_3_STD','VWC_4_STD','Ts_4_STD','VWC_5_STD','Ts_5_STD','VWC_6_STD','Ts_6_STD',...
                'VWC_7_STD','Ts_7_STD','VWC_8_STD','Ts_8_STD','VWC_9_STD','Ts_9_STD','VWC_10_STD',...
                'Ts_10_STD','VWC_11_STD','Ts_11_STD','VWC_12_STD','Ts_12_STD','VWC_13_STD','Ts_13_STD',...
                'VWC_14_STD','Ts_14_STD','VWC_15_STD','Ts_15_STD','VWC_16_STD','Ts_16_STD','VWC_17_STD',...
                'Ts_17_STD','VWC_18_STD','Ts_18_STD','VWC_19_STD','Ts_19_STD','VWC_20_STD','Ts_20_STD',...
                'VWC_21_STD','Ts_21_STD','VWC_22_STD','Ts_22_STD','VWC_23_STD','Ts_23_STD','VWC_24_STD',...
                'Ts_24_STD','PanelT2_AVG','PumpBoxT2_AVG','PicarroT2_AVG','PanelT2_MAX','PumpBoxT2_MAX',...
                'PicarroT2_MAX','PanelT2_MIN','PumpBoxT2_MIN','PicarroT2_MIN','Pbar2_AVG','Pbar2_MAX','Pbar2_MIN',...
                'Pbar2_STD','ACPowerON2_AVG','ACPowerON2_MAX','ACPowerON2_MIN','ACPowerON2_STD','VWC_CH03_AVG',...
                'Ts_CH03_AVG','VWC_CH04_AVG','Ts_CH04_AVG','VWC_CH05_AVG','Ts_CH05_AVG','VWC_CH06_AVG',...
                'Ts_CH06_AVG','VWC_CH11_AVG','Ts_CH11_AVG','VWC_CH12_AVG','Ts_CH12_AVG','VWC_CH03_MAX',...
                'Ts_CH03_MAX','VWC_CH04_MAX','Ts_CH04_MAX','VWC_CH05_MAX','Ts_CH05_MAX','VWC_CH06_MAX',...
                'Ts_CH06_MAX','VWC_CH11_MAX','Ts_CH11_MAX','VWC_CH12_MAX','Ts_CH12_MAX','VWC_CH03_MIN',...
                'Ts_CH03_MIN','VWC_CH04_MIN','Ts_CH04_MIN','VWC_CH05_MIN','Ts_CH05_MIN','VWC_CH06_MIN',...
                'Ts_CH06_MIN','VWC_CH11_MIN','Ts_CH11_MIN','VWC_CH12_MIN','Ts_CH12_MIN','VWC_CH03_STD',...
                'Ts_CH03_STD','VWC_CH04_STD','Ts_CH04_STD','VWC_CH05_STD','Ts_CH05_STD','VWC_CH06_STD',...
                'Ts_CH06_STD','VWC_CH11_STD','Ts_CH11_STD','VWC_CH12_STD','Ts_CH12_STD'};
 
end


