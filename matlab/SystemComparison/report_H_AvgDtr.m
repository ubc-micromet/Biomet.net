function variable_info = report_cpop_AvgDtr
% variable_info = report_cpop_AvgDtr
%
% Generates fcrn_plot_comp setup:
% This is the list of variables that will be plotted, 
% four at a time in a four panel graph in the order 
% given in this function
% The three entries per variable are 
% the fieldName, the variableName and the variableUnit

disp('Using AvgDtr and Std');

% Four plots per panel
variable_info = [...
    {'Three_Rotations.AvgDtr.Fluxes.Hs','Hs)','W m^{-2}'}',...
      {'Three_Rotations.AvgDtr.Fluxes.Htc1','Htc','W m^{-2}'}',...
      {'Three_Rotations.Std(4)','Ta_Std','^oC'}',...
      {'Three_Rotations.Std(7)','Tc_Std','^oC'}'];

% For plotting replace the underscore
variable_info(4,:) = strrep(variable_info(2,:),'_','\_');

