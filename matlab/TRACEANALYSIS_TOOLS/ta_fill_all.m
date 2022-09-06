function [nep_filled,eco_respiration,eco_photosynthesis,ind_filled,param] ...
   = ta_fill_all(SiteId,clean_tv,pth_in);

dv_now = datevec(now);
dv_ana = datevec(clean_tv(8000));
if dv_now(1) ~= dv_ana(1)
	Years = dv_ana(1);
   start_doy = 1;
else
	Years = [dv_now(1)-1];
   start_doy = floor(now)-datenum(dv_now(1),1,0);
end

analysis_info.ebc_correction = 0;
analysis_info.photoinhibition_factor = 0;
analysis_info.ustar_threshold = 0.3;

[tv,nep_filled_func,eco_respiration_func,eco_photosynthesis_func,...
      ind_filled_func,param] = nep_analysis(Years,'CR',analysis_info,0,start_doy,pth_in);

[tv_dum,ind_tv,ind_clean] = intersect(tv,clean_tv,'tv');

nep_filled         = NaN .* ones(size(clean_tv));
eco_respiration    = NaN .* ones(size(clean_tv));
eco_photosynthesis = NaN .* ones(size(clean_tv));
ind_filled         = NaN .* ones(size(clean_tv));

nep_filled(ind_clean)         = nep_filled_func(ind_tv);
eco_respiration(ind_clean)    = eco_respiration_func(ind_tv);
eco_photosynthesis(ind_clean) = eco_photosynthesis_func(ind_tv);
ind_filled(ind_clean)         = ind_filled_func(ind_tv);

return