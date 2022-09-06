u =          [  1   1  0  -1    -1    -1     0     1     0];
v =          [  0   1  1   1     0    -1    -1    -1     0];
dir_GillR2 = [330  15 60 105   150   195   240   285     0];
dir_GillR3 = [150 105 60  15   330   285   240   195     0];
dir_csat =   [  0  45 90 135   180   225   270   315     0];

sonic='csat3';
dir1=fr_Sonic_wind_direction([u;v],sonic);
plot([dir1 - dir_csat]);
title(sonic)
figure(1)

pause

sonic='Gillr3';
dir1=fr_Sonic_wind_direction([u;v],sonic);
plot([dir1 - dir_GillR3]);
title(sonic)
figure(1)

pause

sonic='Gillr2';
dir1=fr_Sonic_wind_direction([u;v],sonic);
plot([dir1 - dir_GillR2]);
title(sonic)
figure(1)
