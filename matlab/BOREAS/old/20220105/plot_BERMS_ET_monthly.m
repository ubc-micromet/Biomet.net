function plot_BERMS_ET

kais_plotting_setup

Years = 2000:2003;

Sites = {'BS','JP','PA'};

for i = 1:3
   % Read data
   pth = biomet_path('yyyy',char(Sites(i)),'clean\thirdstage');
   
   % The variables named *_filled_with_fits are those from FCRN standard gap filling
   clean_tv        = read_bor([pth 'clean_tv'],8,[],Years,[],1);
   nep_filled(:,i) = read_bor([pth 'nep_filled_with_fits'],[],[],Years,[],1);
   gep_filled(:,i) = read_bor([pth 'eco_photosynthesis_filled_with_fits'],[],[],Years,[],1);
   et_filled(:,i)  = read_bor([pth 'le_mdv_main'],[],[],Years,[],1);
   Ta = read_bor([pth 'air_temperature_main'],[],[],Years,[],1);
   
   % Convert LE to E
   L = lambda(Ta);
   et_filled(:,i) = et_filled(:,i)./L;
   
	% Calculate monthly averages
   [tv_mon,N_avg(:,i),N_std(:,i),N_N(:,i)] = monthlystat(clean_tv,nep_filled(:,i));
	[tv_mon,P_avg(:,i),P_std(:,i),P_N(:,i)] = monthlystat(clean_tv,gep_filled(:,i));
   [tv_mon,E_avg(:,i),E_std(:,i),E_N(:,i)] = monthlystat(clean_tv,et_filled(:,i));
	[tv_mon,tv_avg,tv_std,tv_N] = monthlystat(clean_tv,clean_tv); % Gives tv_N - the no of hhour in a month
   
	% Calculate monthly totals
   N_tot(:,i) = N_avg(:,i) .* tv_N .*12e-6*1800;
   P_tot(:,i) = P_avg(:,i) .* tv_N .*12e-6*1800;
   E_tot(:,i) = E_avg(:,i) .* tv_N .*1800;
   
end

[tick_val,tick_label] = monthtick(tv_mon,4);

% Plot
figure
plot(tv_mon,N_tot,'.-')
set(gca,'XLim',tick_val([1 end]),'XTick',tick_val,'XTickLabel','');
yeargrid(gca);
position_labels(gca,tick_val,tick_label);

figure
plot(tv_mon,P_tot,'.-')
set(gca,'XLim',tick_val([1 end]),'XTick',tick_val,'XTickLabel','');
yeargrid(gca);
position_labels(gca,tick_val,tick_label);

figure
plot(tv_mon,E_tot,'.-')
set(gca,'XLim',tick_val([1 end]),'XTick',tick_val,'XTickLabel','');
yeargrid(gca);
position_labels(gca,tick_val,tick_label);

figure
plot(E_tot,P_tot,'.')

return
