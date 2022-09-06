% yf_calc_module_main_export_example
% 
% SCRIPT containing debug examples

fr_set_site('yf','n')
[Stats] = yf_calc_module_main(datenum(2004,8,26,0,0,0),'yf')
[Stats_ex1,HF_data_ex1] = yf_calc_module_main(datenum(2004,8,26,0,0,0),'yf',1)
[Stats_ex2,HF_data_ex2] = yf_calc_module_main(datenum(2004,8,26,0,0,0),'yf',2)

% The YF site uses sonic temperature through the LI7000 Aux

figure('Name','ExportFlag 1')
delay(HF_data_ex1.System(1).EngUnits(:,4),HF_data_ex1.System(1).EngUnits(:,5),[-100 100])

figure('Name','ExportFlag 2')
delay(HF_data_ex2.System(1).EngUnits(:,4),HF_data_ex2.System(1).EngUnits(:,5),[-100 100])