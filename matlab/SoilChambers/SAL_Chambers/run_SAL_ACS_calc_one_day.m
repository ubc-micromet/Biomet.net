 function dataStruct = run_SAL_ACS_calc_one_day(currentDate,plotFlag,fullCalcFlag)
  
    % If the recalcs need to run on a non-site PC, then:
    % - Copy UBC_PC_Setup folder from the site PC to UdeM library folder (where this file lives)
    % - edit setup_UdeM_calc.m function to setup proper paths
    % - run: setup_UdeM_calc.m function
    %
    % The PC at the site is already setup to run the files properly
     
    siteID = 'SAL';
 
    arg_default('plotFlag',false);
    arg_default('fullCalcFlag',false);
    
    dataStruct = SAL_ACS_calc_one_day(currentDate,siteID,plotFlag,fullCalcFlag);