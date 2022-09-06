% read 1996
t_96   = read_bor('h:\zoran\bor96\bor96_dt');
co2_96 = read_bor('h:\zoran\bor96\bor96_9.1_2');

% remove spikes
ind = find(co2_96 > 300 & co2_96 <600);
t_96 = t_96(ind);
co2_96 = co2_96(ind);

% read 1994
t_94   = read_bor('v:\data\ffaes\ffaes_dt') - 153;
co2_94 = read_bor('v:\data\ffaes\ffaes.4');
ind    = find(t_94 >= 0);
t_94   = t_94(ind);
co2_94 = co2_94(ind);

% remove spikes
ind = find(co2_94 > 300 & co2_94 <600);
t_94 = t_94(ind);
co2_94 = co2_94(ind);

plot(t_96,co2_96,t_94,co2_94);
grid
axis([0 360 300 500])

