function plt_info = plt_ini_CR

plt_info(1).plotTopLeft     = {'air_temperature_hmp_ventilated_24m' 'temperature_avg_gill'};
%plt_info(1).plotTopLeft     = {'air_temperature_hmp_ventilated_24m'};
plt_info(1).plotTopRight    = 'relative_humidity_hmp_ventilated_24m';
plt_info(1).plotBottomLeft  = 'wind_speed_26m';
plt_info(1).plotBottomRight = 'radiation_net_20m';

plt_info(2).plotTopLeft     = 'internal_pressure_licor_eddy';
plt_info(2).plotTopRight    = 'bench_temperature_licor_eddy';
plt_info(2).plotBottomLeft  = 'co2_avg_licor_profile_25m';
plt_info(2).plotBottomRight = 'co2_avg_licor_eddy';

return