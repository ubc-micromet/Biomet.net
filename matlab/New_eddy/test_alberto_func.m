function [H_hh,Fc_hh,LE_hh,tv,H_hf,Fc_hf,LE_hf,Ta] = test_alberto_func

UBC_Biomet_constants;

close all

H_hf = NaN .* ones(48,1);
H_hh = NaN .* ones(48,1);
LE_hf = NaN .* ones(48,1);
LE_hh = NaN .* ones(48,1);
Fc_hf = NaN .* ones(48,1);
Fc_hh = NaN .* ones(48,1);
Ta_bar = NaN .* ones(48,1);

pth_day = '\\annex002\fn_database\2003\BA\met-data\data\';

clim = dlmread([pth_day 'ALO_Clim.2003247'],',',1,0);
tv = datenum(clim(:,2),1,clim(:,3),floor(clim(:,4)/100),mod(clim(:,4),100),0);
tv = tv(1:end-20);
%for i = 19:length(tv)-20
for i = 1:length(tv)

   load([pth_day fr_datetofilename(tv(i)) '.DA1.mat']);
   
   LI7500 = Eddy_HF_data(:,5:end);
   GillR3 = Eddy_HF_data(:,1:4);;
   
    n = length(LI7500);
   if n<=1
      disp(['Could not evaluate file ' no]);
   else
      disp(['Evaluating file ' fr_datetofilename(tv(i))]);
      
      GillR3 = GillR3(1:n,:);
      LI7500 = LI7500(1:n,:);
      
%      Eddy_HF_data = [GillR3(:,1:4) LI7500(:,[2 1])];   Zoran changed this. See below
      Eddy_HF_data = [GillR3(:,1:4) LI7500(:,[1 2])];

      P = clim(i,end);       % kPa
      
      % Do three rotations
      [meansSr,statsSr,angles] = fr_rotatn( ...
         [mean(Eddy_HF_data(:,1:3))],cov(Eddy_HF_data));
      [Eddy_HF_data] = fr_rotatn_hf(Eddy_HF_data,angles);
      
      Ts     = Eddy_HF_data(:,4);       % degC
      rho_c  = Eddy_HF_data(:,5);       % mmol m^-3
      rho_v  = Eddy_HF_data(:,6);       % mmol m^-3

      % Conversion to air temperature and mole fractions
      [Ta,rho_a] = Ts2Ta_using_density(Ts,P,rho_v);
      
      co2 = rho_c ./ rho_a .* 1000; % ppm
      h2o = rho_v ./ rho_a;         % mmol/mol 
      
      % Calculations based on high frequency data
      rho_v_bar = mean(rho_v); 
      rho_c_bar = mean(rho_c);
      Ts_bar    = mean(Ts);
      Ta_bar(i) = mean(Ta)+ZeroK;
      rho_bar   = P.*1000./(R.*Ta_bar(i)); % mol/m^3
      rho_a_bar = rho_bar-rho_v_bar./1000;
      L = lambda(Ta_bar(i)-ZeroK);
      covs = cov([Eddy_HF_data(:,1:3) Ta co2 h2o],0);
%      covs = cov([Eddy_HF_data(:,1:3) Ta co2 h2o],1); Zoran changed to above.

      
      H_hf(i)  = (Cp.*rho_a_bar.*Ma+Cpv.*rho_v_bar./1000.*Mw) .* covs(3,4);
      LE_hf(i) = L .* Mw/1000 .*rho_a_bar .* covs(3,6)./1000;
      Fc_hf(i) = rho_a_bar .* covs(3,5);

if abs(tv(i)-datenum(2003,9,3,12,0,0))< .01
    disp('hit')
end
      
      % Calculations of hhourly stats
%      cov_hhs = cov(Eddy_HF_data,1);   Zoran Changed this with below
      cov_hhs = cov(Eddy_HF_data,0);

      [H_hhs(i),Fc_hhs(i),LE_hhs(i)] = WPL_LI7500(Ts_bar,rho_c_bar,rho_v_bar,P,cov_hhs,1);

      cov_hh  = cov([Eddy_HF_data(:,1:3) Ta Eddy_HF_data(:,5:6)],1);

      [H_hh(i),Fc_hh(i),LE_hh(i)] = WPL_LI7500(Ta_bar(i)-ZeroK,rho_c_bar,rho_v_bar,P,cov_hh,0);
      
   end
   
end


return

load D:\kai_data\ALO1
tv_new_eddy = get_stats_field(Stats_New,'TimeVector');
Fc_new = get_stats_field(Stats_New,'MainEddy.Zero_Rotations.AvgDtr.Fluxes.Fc');
LE_new = get_stats_field(Stats_New,'MainEddy.Zero_Rotations.AvgDtr.Fluxes.LE_L');
Hs_new = get_stats_field(Stats_New,'MainEddy.Zero_Rotations.AvgDtr.Fluxes.Hs');
Fc_wpl = get_stats_field(Stats_New,'MainEddy.WPLFluxes.Fc');
LE_wpl = get_stats_field(Stats_New,'MainEddy.WPLFluxes.LE_L');
Hs_wpl = get_stats_field(Stats_New,'MainEddy.WPLFluxes.Hs');

[tv_dum,ind_new,ind_tst] = intersect(fr_round_hhour(tv_new_eddy),fr_round_hhour(tv));

tv = tv - datenum(2003,1,0);
ind = 1:length(tv);

figure
subplot('Position',subplot_position(2,1,1));
plot(tv,[H_hh(ind) H_hf(ind) LE_hh(ind) LE_hf(ind)]);
axis([tv(1) tv(end) -100 400])

subplot('Position',subplot_position(2,1,2));
plot(tv,100.*[(H_hh(ind)-H_hf(ind))./H_hf(ind) ...
      (LE_hh(ind)-LE_hf(ind))./LE_hf(ind)]);
axis([tv(1) tv(end) -5 5])

figure
subplot('Position',subplot_position(2,1,1));
plot(tv,[Fc_hh(ind) Fc_hf(ind)]);
hold on
plot(tv(ind_tst),Fc_new(ind_new),'r',tv(ind_tst),Fc_wpl(ind_new),'m');
axis([tv(1) tv(end) -20 10])

subplot('Position',subplot_position(2,1,2));
plot(tv,100.*[(Fc_hh(ind)-Fc_hf(ind))./Fc_hf(ind)]);
axis([tv(1) tv(end) -0.5 0.5])

figure
subplot('Position',subplot_position(2,1,1));
plot(tv,[H_hf(ind) LE_hf(ind)],...
   tv(ind_tst),[Hs_new(ind_new) LE_new(ind_new)],...
   tv(ind_tst),[Hs_wpl(ind_new) LE_wpl(ind_new)]);
axis([tv(1) tv(end) -100 400])

return
