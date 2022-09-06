ws = read_db(2004,'cr','climate\clean','wind_speed_40m');
wd = read_db(2004,'cr','climate\clean','wind_direction_weighted_40m');
ws_sonic = read_db(2004,'cr','flux\clean','wind_speed_2d_before_rot_gill');
plot(wd,(ws_sonic-ws)./ws,'.')

ws = read_db(2004,'pa','climate\clean','wind_speed_38m');
wd = read_db(2004,'pa','BERMS\al1','Wind_Dir_AbvCnpy_38m');
ws_sonic = read_db(2004,'pa','flux\clean','wind_speed_u_avg_after_rot_gill');
plot(wd,(ws_sonic-ws)./ws,'.')


ws = read_db(2004,'oy','climate\clean','wind_speed_2_5m');
wd = read_db(2004,'oy','climate\clean','wind_direction_weighted_2_5m');
ws_sonic = read_db(2004,'oy','flux\clean','wind_speed_2d_before_rot_sonic_pc');
plot(wd,(ws_sonic-ws)./ws,'.')

