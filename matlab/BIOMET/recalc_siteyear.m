function st = recalc_siteyear(siteID,tv_recalc)
% st = recalc(siteID,tv_recalc)

c             = fr_get_init(siteID,now);
pth = c.hhour_path;

tv_recalc     = unique(floor(tv_recalc));
tv_vec        = datevec(tv_recalc);
tv_recalc_doy = fr_get_doy(tv_recalc,0);

if exist(fullfile(pth,'lst_days.mat'))
   x = load(fullfile(pth,'lst_days.mat'));
   [tv_recalc,ind_unique] = setdiff(tv_recalc(:),x.lst_days);      
   tv_vec = tv_vec(ind_unique,:);
   tv_recalc_doy = tv_recalc_doy(ind_unique);
else
   lst_days = [];
   save(fullfile(pth,'lst_days.mat'),'lst_days');
end

n = length(tv_recalc);
for i=1:n
   try
      stats = fr_calc_one_day_stats(siteID,tv_vec(i,1),1,tv_recalc_doy(i),0);
      
      % Save only if not all entries are NaN
      no_nozero = length(find(stats.Fluxes.AvgDtr(:,1)~=0));
      if no_nozero>0
         st = fr_save_hhour(siteID,stats,[]);
         x = load(fullfile(pth,'lst_days.mat'));
         lst_days = sort([x.lst_days; tv_recalc(i)]);
         save(fullfile(pth,'lst_days.mat'),'lst_days');
      end
   end
end	
