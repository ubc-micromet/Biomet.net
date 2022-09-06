tv_tst = datenum(2005,2,16);

fr_set_site('yf','l');
c = fr_get_init('yf',tv_tst);

Stats.tvTmp   = tv_tst + [1:48]./48;
Stats.pBarTmp = 98 .* ones(size(Stats.tvTmp));

[stats] = ach_calc('yf',tv_tst,Stats,c,1);
