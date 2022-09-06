function tv = read_tv(data,year,indOut,override_1999);

tv = read_bor(data,8,[],year,indOut,override_1999);

tv = fr_round_hhour(tv);