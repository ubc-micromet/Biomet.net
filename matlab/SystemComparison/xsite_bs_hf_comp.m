function xsite_bs_hf_comp(currentDate)

close all

%currentDate = datenum(2004,5,16)+80/96;
%currentDate = datenum(2004,5,18)+84/96;

oldPath = pwd;

cd C:\UBC_PC_Setup\Site_specific\BS_new_eddy
[Stats_bs,HF_bs] = yf_calc_module_main(currentDate,'BS',1);

cd C:\UBC_PC_Setup\Site_specific\XSITE
[Stats_xs,HF_xs] = yf_calc_module_main(currentDate,'xsite',1);

tv_bs = [0:length(HF_bs.System(1).EngUnits(:,4))-1]./20.83;
tv_xs = [0:length(HF_xs.System(1).EngUnits(:,4))-1]./20;
tv_xs_op = [0:length(HF_xs.System(2).EngUnits(:,4))-1]./20;
tv_max = min([tv_bs(end) tv_xs(end) tv_xs_op(end)]);
tv = linspace(0,tv_max,tv_max*20);

EngUnits_bs    = interp1(tv_bs,HF_bs.System(1).EngUnits,tv);
EngUnits_xs    = interp1(tv_xs,HF_xs.System(1).EngUnits,tv);
EngUnits_xs_op = interp1(tv_xs_op,HF_xs.System(2).EngUnits,tv);

d = delay(EngUnits_bs(:,4),EngUnits_xs(:,4));
[EngUnits_bs,EngUnits_xs] = fr_remove_delay(EngUnits_bs',EngUnits_xs',d,d);
EngUnits_bs = EngUnits_bs'; EngUnits_xs = EngUnits_xs';

d_op = delay(EngUnits_bs(:,4),EngUnits_xs_op(:,4));
[EngUnits_bs,EngUnits_xs_op_dm] = fr_remove_delay(EngUnits_bs',EngUnits_xs_op',d_op,d_op);
[EngUnits_xs,dum]               = fr_remove_delay(EngUnits_xs',EngUnits_xs_op',d_op,d_op);

EngUnits_bs = EngUnits_bs'; EngUnits_xs = EngUnits_xs'; EngUnits_xs_op = EngUnits_xs_op_dm';

tv = [1:length(EngUnits_bs)]./20;

cup_bs  = sqrt(sum(EngUnits_bs(:,1:2).^2,2));
cup_xs  = sqrt(sum(EngUnits_xs(:,1:2).^2,2));

EngUnits_xs_op = EngUnits_xs;

figure(1)
plot(tv,detrend([EngUnits_bs(:,3),EngUnits_xs(:,3),EngUnits_xs_op(:,3)],0))

figure(2)
plot(tv,detrend([EngUnits_bs(:,4),EngUnits_xs(:,4),EngUnits_xs_op(:,4)],0))

figure(3)
plot(tv,detrend([EngUnits_bs(:,5),EngUnits_xs(:,5),EngUnits_xs_op(:,5)]))

figure(4)
plot(tv,detrend([EngUnits_bs(:,6),EngUnits_xs(:,6),EngUnits_xs_op(:,6)]))

return

for i = 1:29
    ind = (i-1)*1200+1:(i)*1200;
    d(i)   = delay(EngUnits_bs(ind,3),EngUnits_xs(ind,3));
    u(i)   = sqrt(mean(EngUnits_bs(ind,1)).^2+mean(EngUnits_bs(ind,2)).^2);
    dir(i) = FR_Sonic_wind_direction(mean(EngUnits_bs(ind,1:3))','GillR3');
end

