function cumNEP_analysis(siteID,year,numdays,fig_beg,hard_copy)

%year = 2000:2005;
%siteID = 'pa';
arg_default('hard_copy',0);
arg_default('fig_beg',1);
fig = fig_beg;
for i=1:length(year)
  pth_bs = biomet_path(year(i),siteID);
  tv_bs  = read_bor(fullfile(pth_bs,'clean\ThirdStage\clean_tv'),8);
  doy_bs = tv_bs - 6/24 - datenum(year(i),1,0);

  NEP = read_bor(fullfile(pth_bs,'clean\ThirdStage\nep_filled_with_fits'));
  GEP = read_bor(fullfile(pth_bs,'clean\ThirdStage\eco_photosynthesis_filled_with_fits'));
  R   = read_bor(fullfile(pth_bs,'clean\ThirdStage\eco_respiration_filled_with_fits'));

% averaging

  [GEP_mean,ind_avg] = runmean(GEP,numdays*48,numdays*48);
  [R_mean,ind_avg]   = runmean(R,numdays*48,numdays*48);
 % cumNEP             = cumsum(1800*12e-6*NEP);
% plot R and GEP together 
  
 
  figure(fig);
  plot(doy_bs(ind_avg),GEP_mean,'g-',doy_bs(ind_avg),R_mean,'b-','Linewidth',2); 
  title([upper(siteID) ' ' num2str(year(i)) ': GEP and R']); zoom on;
  axis([ 0 366 0 ceil(max(max(GEP_mean),max(R_mean)))]);
  %axis([ 0 366 0 7]);
  set(gca,'XTickLabel',[0 50 100 150 200 250 300 350])
  set(gca,'XTick',[0 50 100 150 200 250 300 350])
  xlabel('DOY');
  ylabel('Carbon Flux (g C m^{-2} s^{-1})');
  legend('GEP','R');
  
  if hard_copy
      print('-dmeta',[upper(siteID) '_GEPvsR_fig' num2str(fig)]);
  end
  fig=fig+1;
%  figure;
%  plot(doy_bs,cumNEP,'r-'); zoom on;

end