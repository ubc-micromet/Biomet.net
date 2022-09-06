function k = db_Flux_update_all_sites(dateIn)

% Updating the Eddy data
db_flux_daily_update(dateIn,'HJP02','MainEddy');
db_flux_daily_update(dateIn,'OY','MainEddy');
db_flux_daily_update(dateIn,'YF','MainEddy');

db_flux_daily_update(dateIn,'BS','OldEddy');
db_flux_daily_update(dateIn,'CR','OldEddy');
db_flux_daily_update(dateIn,'JP','OldEddy');
db_flux_daily_update(dateIn,'PA','OldEddy');

exit;
