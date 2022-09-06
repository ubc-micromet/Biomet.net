function stats = ACH_Calc_main(dateIn)

if ~exist(dateIn) | isempty(dateIn)
        dateIn = now-1;
end

%fr_set_site('yf','l');
c = fr_get_init('yf',dateIn);

Stats.tvTmp   = tv_tst + [1:48]./48;
Stats.pBarTmp = 98 .* ones(size(Stats.tvTmp));

[stats] = ach_calc('yf',tv_tst,Stats,c,1);
