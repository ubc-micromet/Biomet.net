function [Licor_EC_out,Licor_Prof_out] = fr_profile_HF_plot(dateIn,flag_erase)

if ~exist('dateIn') | isempty(dateIn)
   dateIn = now;
end

if ~exist('flag_erase') | isempty(flag_erase) | flag_erase == 1
   close all
end

SiteId = fr_current_siteid;            
c          = fr_get_init(SiteId,dateIn);
FileName_p = FR_DateToFileName(fr_round_hhour(dateIn,2));

RawData_DAQ                 = FR_read_data_files(c.path,FileName_p,c,[]);
[EngUnits_DAQ,chi,test_var] = FR_convert_to_eng_units(RawData_DAQ,2,c);
Licor_EC = EngUnits_DAQ(6:9,:)';

profVolt = (RawData_DAQ(fr_reorder_chans(c.Profile.DAQ_chans,c),:)' - mean(RawData_DAQ(5,:)) )*5000/2^15;

[co2,h2o,Tbench,Plicor] = fr_profile_licor_calc(profVolt,c.Profile);

Licor_Prof = [co2 h2o Tbench Plicor];

Licor_ProfTitle = 'Profile 6262';
Licor_ECTitle = 'Eddy 6262';

t = [1:length(Licor_EC)]' ./ 20.83;

figure;
plot(t,Licor_EC(:,1),t,Licor_Prof(:,1))
zoom on
legend(Licor_ECTitle,Licor_ProfTitle)
title(['CO_2 - ' datestr(dateIn)])

figure;
plot(t,Licor_EC(:,2),t,Licor_Prof(:,2))
zoom on
legend(Licor_ECTitle,Licor_ProfTitle)
title('H_2O')

if nargout>0
   Licor_EC_out 	= Licor_EC;
   Licor_Prof_out = Licor_Prof;
else
   c.span_conc
   c.Profile.Licor.CO2_cal
end

return

figure;
plot(t,Licor_EC(:,3),t,Licor_Prof(:,3))
zoom on
legend(Licor_ECTitle,Licor_ProfTitle)
title('T_{bench}')

figure;
plot(t,Licor_EC(:,4),t,Licor_Prof(:,4))
zoom on
legend(Licor_ECTitle,Licor_ProfTitle)
title('P_{licor}')



            