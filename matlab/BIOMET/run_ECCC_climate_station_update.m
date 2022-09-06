function run_ECCC_climate_station_update(yearsIn,monthsIn)
% run_ECCC_climate_station_update(yearsIn,monthsIn)
%
% Process ECCC climate station data. The station ID numbers are currently hard
% codded (49088)
%
% yearsIn   - range of years to process (default current year)
% monthsIn  - range of months to process (default previous and the current
%             month.
%
% Zoran Nesic                   File created:               2022
%                               Last modification: July 14, 2022

% Revisions
%

[yearNow,monthNow,~]= datevec(now);
monthRange = monthNow-1:monthNow;
arg_default('yearsIn',yearNow)
arg_default('monthsIn',monthRange)
db_ECCC_climate_station(yearsIn,monthsIn,49088,fullfile(biomet_database_default,'yyyy\BB\MET\ECCC'),60);