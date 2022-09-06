function h = fcrn_plot_report(Stats_all,ind_exclude,system_names)
% h = fcrn_plot_report(Stats_all,ind_exclude,system_names)
%
% 

plotting_setup

if exist('ind_exclude') ~= 1 | isempty(ind_exclude)
   ind_exclude = [];
end

if exist('system_names') ~= 1 | isempty(system_names)
   system_names   = {'XSITE_CP','XSITE_OP'};
end

% For plotting replace the underscore
system_names_plt = strrep(system_names,'_','\_');

%----------------------------------------------------
% Define variables to be extracted for both systems
%----------------------------------------------------
% This is the list of variables that will be plotted, 
% four at a time in a four panel graph in the order 
% given below
% The three entries per variable are 
% the fieldName, the variableName and the variableUnit
if 1==1
 disp('Using LinDtr and Var');
variable_info = [...
     {'Three_Rotations.LinDtr.Fluxes.Hs','Hs','W m^{-2}'}',...
      {'Three_Rotations.LinDtr.Fluxes.LE_L','LE','W m^{-2}'}',...
      {'Three_Rotations.LinDtr.Fluxes.Fc','Fc','\fontname{Symbol}m\fontname{Arial}mol m^{-2} s^{-1}'}',...
      {'Three_Rotations.LinDtr.Fluxes.Ustar','Ustar','m/s'}',...
     {'Three_Rotations.Avg(1)','U_Avg','m/s'}',...
      {'Three_Rotations.LinDtr.Cov(1,1)','U_Var','m/s'}',...
      {'Three_Rotations.LinDtr.Cov(2,2)','V_Var','m/s'}',...
      {'Three_Rotations.LinDtr.Cov(3,3)','W_Var','m/s'}',...
     {'Three_Rotations.Angles.Eta','eta','deg'}',...
      {'Zero_Rotations.Avg(2)','w_Avg','m/s'}',...
      {'Three_Rotations.LinDtr.Cov(4,4)','Ta_Var','^oC'}',...
      {'Three_Rotations.Avg(4)','Ta_Avg','^oC'}',...
     {'Three_Rotations.Avg(5)','CO2_Avg','ppm'}',...
      {'Three_Rotations.LinDtr.Cov(5,5)','CO2_Var','ppm'}',...
   	  {'Three_Rotations.Avg(6)','H2O_Avg','mmol m^{-2} s^{-1}'}',...
      {'Three_Rotations.LinDtr.Cov(6,6)','H2O_Var','mmol m^{-2} s^{-1}'}',...
   ];
else
 disp('Using AvgDtr and Std');
variable_info = [...
     {'Three_Rotations.AvgDtr.Fluxes.Hs','Hs','W m^{-2}'}',...
      {'Three_Rotations.AvgDtr.Fluxes.LE_L','LE','W m^{-2}'}',...
      {'Three_Rotations.AvgDtr.Fluxes.Fc','Fc','\fontname{Symbol}m\fontname{Arial}mol m^{-2} s^{-1}'}',...
      {'Three_Rotations.AvgDtr.Fluxes.Ustar','Ustar','m/s'}',...
     {'Three_Rotations.Avg(1)','U_Avg','m/s'}',...
      {'Three_Rotations.Std(1)','U_Std','m/s'}',...
      {'Three_Rotations.Std(2)','V_Std','m/s'}',...
      {'Three_Rotations.Std(3)','W_Std','m/s'}',...
     {'Three_Rotations.Angles.Eta','eta','deg'}',...
      {'Zero_Rotations.Avg(2)','w_Avg','m/s'}',...
      {'Three_Rotations.Std(4)','Ta_Std','^oC'}',...
      {'Three_Rotations.Avg(4)','Ta_Avg','^oC'}',...
     {'Three_Rotations.Avg(5)','CO2_Avg','ppm'}',...
      {'Three_Rotations.Std(5)','CO2_Std','ppm'}',...
   	  {'Three_Rotations.Avg(6)','H2O_Avg','mmol m^{-2} s^{-1}'}',...
      {'Three_Rotations.Std(6)','H2O_Std','mmol m^{-2} s^{-1}'}',...
   ];
end
% For plotting replace the underscore
variable_info(4,:) = strrep(variable_info(2,:),'_','\_');

%----------------------------------------------------
% Extract variables for both systems
%----------------------------------------------------
[var_names] = fcrn_extract_var('Stats_all',system_names,variable_info);

%----------------------------------------------------
% Exclude indeces given in command line
%----------------------------------------------------
[dum,ind_name] = unique(var_names);
ind_include = setdiff(1:length(tv),ind_exclude);
for k = ind_name
   cmd = [char(var_names(k)) ' = ' char(var_names(k)) '(ind_include);'];
   eval(cmd);
end   
tv = tv(ind_include);

%----------------------------------------------------
% Do comparison plots
%----------------------------------------------------
fsize_txorg = get(0,'DefaultTextFontSize');
fsize_axorg = get(0,'DefaultAxesFontSize'); 
set(0,'DefaultAxesFontSize',10) 
set(0,'DefaultTextFontSize',10);

disp(sprintf('Variable:\tSlope\t\tIntercept\tr^2'))
j = 1;
for k = 1:round(length(variable_info)/4)*4
   i = mod(k-1,4)+1;
   if i == 1;
      if j>1
         select_datapoints(h(j-1).hand);
      end
      h(j).hand = figure;
      h(j).name = ['report_fig' num2str(j,'%02i')];
      top.tv = tv;
      top.SiteId = fr_current_siteid;
      set(gcf,'UserData',top);
      j = j+1;
   end
   
   subplot(2,2,i)
   cmd = ['plot_regression(' char(var_names(2*k-1)) ',' char(var_names(2*k)) ',[],[],''ortho'')'];   
   eval(cmd);
   cmd = ['xlabel(''' char(variable_info(4,k)) ' ' char(system_names_plt(1)) ' (' char(variable_info(3,k)) ')'');'];
   eval(cmd);
   cmd = ['ylabel(''' char(variable_info(4,k)) ' ' char(system_names_plt(2)) ' (' char(variable_info(3,k)) ')'');'];
   eval(cmd);
   
   cmd = ['a(k,:) = linregression_orthogonal(' char(var_names(2*k-1)) ',' char(var_names(2*k)) ');'];   
   eval(cmd);
%   zoom_together(gcf,'on')
   disp(sprintf('%s:\t\t%4.2f+/-%4.2f\t%4.2f+/-%4.2f\t%3.2f',char(variable_info(2,k)),a(k,[1 5 2 6 8])))
end

select_datapoints(h(j-1).hand);

set(0,'DefaultTextFontSize',fsize_txorg);
set(0,'DefaultAxesFontSize',fsize_axorg);

return