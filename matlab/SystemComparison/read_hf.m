function xsite_plt_hf(currentDate,SiteId)

if isempty(currentDate)
    currentDate = now - 1/48;
end

close all

%--------------------------------------------------------------------------
% Read data
%--------------------------------------------------------------------------
oldPath = pwd;

cd(['C:\UBC_PC_Setup\Site_specific\' SiteId])
[Stats_bs,HF_bs] = yf_calc_module_main(currentDate,fr_current_siteid,2);

cd C:\UBC_PC_Setup\Site_specific\XSITE
[Stats_xs,HF_xs] = yf_calc_module_main(currentDate,'xsite',2);

cd(oldPath)

%--------------------------------------------------------------------------
% Resample by interpolation
%--------------------------------------------------------------------------
tv_bs = [0:length(HF_bs.System(1).EngUnits(:,4))-1]./20.83;
tv_xs = [0:length(HF_xs.System(1).EngUnits(:,4))-1]./20;
tv_xs_op = [0:length(HF_xs.System(2).EngUnits(:,4))-1]./20;
tv_max = min([tv_bs(end) tv_xs(end) tv_xs_op(end)]);
tv = linspace(0,tv_max,tv_max*20);

EngUnits_bs    = interp1(tv_bs,HF_bs.System(1).EngUnits,tv);
EngUnits_xs    = interp1(tv_xs,HF_xs.System(1).EngUnits,tv);
EngUnits_xs_op = interp1(tv_xs_op,HF_xs.System(2).EngUnits,tv);

%--------------------------------------------------------------------------
% Remove delay
%--------------------------------------------------------------------------
d = delay(EngUnits_bs(:,4),EngUnits_xs(:,4));
[EngUnits_bs,EngUnits_xs] = fr_remove_delay(EngUnits_bs',EngUnits_xs',d,d);
EngUnits_bs = EngUnits_bs'; EngUnits_xs = EngUnits_xs';

d_op = delay(EngUnits_bs(:,4),EngUnits_xs_op(:,4));
[EngUnits_bs,EngUnits_xs_op_dm] = fr_remove_delay(EngUnits_bs',EngUnits_xs_op',d_op,d_op);
[EngUnits_xs,dum]               = fr_remove_delay(EngUnits_xs',EngUnits_xs_op',d_op,d_op);

EngUnits_bs = EngUnits_bs'; EngUnits_xs = EngUnits_xs'; EngUnits_xs_op = EngUnits_xs_op_dm';

tv = [1:length(EngUnits_bs)]./20;

%--------------------------------------------------------------------------
% Prepare spectra
%--------------------------------------------------------------------------
Spec_bs    = Stats_bs.MainEddy.Spectra;
Spec_xs    = Stats_xs.XSITE_CP.Spectra;
Spec_xs_op = Stats_xs.XSITE_OP.Spectra;

%--------------------------------------------------------------------------
% Plot HF data
%--------------------------------------------------------------------------
figure(1)
plot(tv,detrend([EngUnits_bs(:,3),EngUnits_xs(:,3),EngUnits_xs_op(:,3)],0))

figure(2)
plot(tv,detrend([EngUnits_bs(:,4),EngUnits_xs(:,4),EngUnits_xs_op(:,4)],0))

figure(3)
plot(tv,detrend([EngUnits_bs(:,5),EngUnits_xs(:,5),EngUnits_xs_op(:,5)]))

figure(4)
plot(tv,detrend([EngUnits_bs(:,6),EngUnits_xs(:,6),EngUnits_xs_op(:,6)]))

%--------------------------------------------------------------------------
% Plot Spectra
%--------------------------------------------------------------------------
i = 3
semilogx(Spectra_bs.Flog,Spectra_bs.Flog.*Spectra_bs.Csd(:,i),...
    Spectra_xs.Flog,   Spectra_xs.Flog.*Spectra_xs.Csd(:,i),...
    Spectra_xs_op.Flog,Spectra_xs_op.Flog.*Spectra_xs_op.Csd(:,i));

i = 4;
semilogx(Spectra_bs.Flog,Spectra_bs.Flog.*Spectra_bs.Csd(:,i),...
    Spectra_xs.Flog,   Spectra_xs.Flog.*Spectra_xs.Csd(:,i),...
    Spectra_xs_op.Flog,Spectra_xs_op.Flog.*Spectra_xs_op.Csd(:,i));

i = 5;
semilogx(Spectra_bs.Flog,Spectra_bs.Flog.*Spectra_bs.Csd(:,i),...
    Spectra_xs.Flog,   Spectra_xs.Flog.*Spectra_xs.Csd(:,i),...
    Spectra_xs_op.Flog,Spectra_xs_op.Flog.*Spectra_xs_op.Csd(:,i));

return

