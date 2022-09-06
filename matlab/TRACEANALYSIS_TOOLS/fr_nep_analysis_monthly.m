function [p_all,std_p]  = fr_nep_analysis_monthly(clean_tv,ppfd_downwelling,soil_temperature,fc,co2_storage,...
                     ustar,radiation_downwelling_potential,analysis_info,plot_flag,growing_season)
% analysis_info is a structur that contains the information needed to carry out 
% the analysis using a certain combination of methods. The structur should look like this
% analysis_info.ebc_factor
%              .ustar_threshold
%              .photoinhibition_factor (subpression in % => * (1-photoinhibition_factor/100)

% This analysis follows the scheme sketched in Kladde4, 8/8/2002

if ~exist('plot_flag') | isempty(plot_flag)
   plot_flag = 0;
end

%-----------------------------------------------------------------------
% First of all, get respiration
%-----------------------------------------------------------------------
[nep_filled,nep_fitted,eco_respiration,eco_photosynthesis] ...
   = fr_nep_analysis(ppfd_downwelling,soil_temperature,fc,co2_storage,...
   ustar,radiation_downwelling_potential,analysis_info,growing_season);

%-----------------------------------------------------------------
% EBC correction
%-----------------------------------------------------------------
fc = fc ./ analysis_info.ebc_factor;
nee_unfilled = fc+co2_storage;

%-----------------------------------------------------------------
% EBC correction
%-----------------------------------------------------------------
fc = fc ./ analysis_info.ebc_factor;
nee_unfilled = fc+co2_storage;

%-----------------------------------------------------------------
% Calc ecosystem photosynthesis from measured NEEs
%-----------------------------------------------------------------
% Respiration is of course not measured...
% Select observations
ind_photosyn = find(~isnan(nee_unfilled) & ~isnan(eco_respiration)...
   & radiation_downwelling_potential > 0 & growing_season);

eco_photosynthesis_measured = zeros(size(eco_respiration));
eco_photosynthesis_measured(ind_photosyn) = -nee_unfilled(ind_photosyn) + eco_respiration(ind_photosyn);

ind_zero = find(eco_photosynthesis_measured==0 & radiation_downwelling_potential > 0);
eco_photosynthesis_measured(ind_zero) = NaN;

%-----------------------------------------------------------------
% Calc fit for Michelis Menten function for each month
%-----------------------------------------------------------------
% Things needed in the fitting proceedure
f_michelis_menten = inline('p(1).*p(2).*x./(p(1).*x+p(2))','p','x');
options = optimset('maxiter', 10^3, 'maxfunevals', 10^3, 'tolx', 10^-3);

tv_vec = datevec(clean_tv);
MM = tv_vec(:,1)*12 + tv_vec(:,2);
months = unique(MM);

p_all = NaN .* ones(length(months),2);
std_p = NaN .* ones(length(months),2);
for i = 1:length(months);
   ind_fit_day = find(isnan(nee_unfilled)==0 & ~isnan(ppfd_downwelling) ...
      & radiation_downwelling_potential > 0 & MM == months(i) & growing_season);
   p_all(i,:) = fr_function_fit(f_michelis_menten,[0.04 20],...
      eco_photosynthesis_measured(ind_fit_day),options,ppfd_downwelling(ind_fit_day));
   
   if nargout > 1
      N = 100;
      p_test = NaN.*zeros(N,2);
      rand('state',0)
      for j = 1:N
         disp(['Fitting trial ' num2str(j)]);
         ind_rand = ceil(length(ind_fit_day).*rand(length(ind_fit_day),1));
         ind_test = ind_fit_day(ind_rand);
         p_test(j,:) = fr_function_fit(f_michelis_menten,[0.04 20],...
            eco_photosynthesis_measured(ind_test),options,ppfd_downwelling(ind_test));;
      end
      std_p(i,:) = std(p_test);
      
   end
   
   if plot_flag==1
      plot(ppfd_downwelling(ind_fit_day),eco_photosynthesis_measured(ind_fit_day),'o','Markersize',2)
      hold on
      plot(0:100:2000,f_michelis_menten(p_all(i,:),0:100:2000),'r-','Linewidth',1.25)
      axis([0 2000 0 40])
   end
   
end


return

