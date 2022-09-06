function test_rmy_yf

year = 2005;
[wind_direction,tv] = read_db(year,'yf','climate\clean','wind_direction_weighted_12m');
wind_speed_rmy = read_db(year,'yf','climate\clean','wind_speed_12m');
wind_speed_sonic = read_db(year,'yf','flux\clean','wind_speed_2d_before_rot_gill');
wind_dir_sonic = read_db(year,'yf','flux','Instrument_1.MiscVariables.WindDirection');

doy = tv - datenum(year,1,0);

subplot(2,1,1)
plot(doy,[wind_speed_sonic,wind_speed_rmy])
subplot(2,1,2)
plot(doy,[wind_dir_sonic,wind_direction])

zoom_together(gcf,'x','on')
