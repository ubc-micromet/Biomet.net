function [p_all,std_p]  = fr_nee_analysis_monthly(clean_tv,ppfd_downwelling,soil_temperature,nee_unfilled,...
                     ustar,radiation_downwelling_potential,analysis_info)
% analysis_info is a structur that contains the information needed to carry out 
% the analysis using a certain combination of methods. The structur should look like this
% analysis_info.ebc_factor
%              .ustar_threshold
%              .photoinhibition_factor (subpression in % => * (1-photoinhibition_factor/100)

% This analysis follows the scheme sketched in Kladde4, 8/8/2002

%-----------------------------------------------------------------------
% First of all, get respiration
%-----------------------------------------------------------------------
[nep_filled,nep_fitted,eco_respiration,eco_photosynthesis] ...
   = fr_nep_analysis(ppfd_downwelling,soil_temperature,nee_unfilled,...
   ustar,radiation_downwelling_potential,analysis_info);

%-----------------------------------------------------------------
% Calc ecosystem photosynthesis from measured NEEs
%-----------------------------------------------------------------
% Respiration is of course not measured...
% Select observations
ind_photosyn = find(~isnan(nee_unfilled) & ~isnan(eco_respiration)...
   & radiation_downwelling_potential > 0);

eco_photosynthesis_measured = zeros(size(eco_respiration));
eco_photosynthesis_measured(ind_photosyn) = -nee_unfilled(ind_photosyn) + eco_respiration(ind_photosyn);

ind_zero = find(eco_photosynthesis_measured==0 & radiation_downwelling_potential > 0);
eco_photosynthesis_measured(ind_zero) = NaN;

%-----------------------------------------------------------------
% Calc fit for Michelis Menten function for each month
%-----------------------------------------------------------------
% Things needed in the fitting proceedure
f_michelis_menten = inline('p(1).*p(2).*x./(p(1).*x+p(2))-p(3)','p','x');
options = optimset('maxiter', 10^3, 'maxfunevals', 10^3, 'tolx', 10^-3);

tv_vec = datevec(clean_tv);
MM = tv_vec(:,1)*12 + tv_vec(:,2);
months = unique(MM);

p_all = NaN .* ones(length(months),3);
std_p = NaN .* ones(length(months),3);
for i = 1:length(months);
   ind_fit_day = find(isnan(nee_unfilled)==0 & ~isnan(ppfd_downwelling) ...
      & radiation_downwelling_potential > 0 & nee_unfilled < 10 & MM == months(i));
   p_all(i,:) = fr_function_fit(f_michelis_menten,[0.04 20 1],...
      -nee_unfilled(ind_fit_day),options,ppfd_downwelling(ind_fit_day));
   
   if nargout > 1
      N = 100;
      p_test = NaN.*zeros(N,3);
      rand('state',0)
      for j = 1:N
         disp(['Fitting trial ' num2str(j)]);
         ind_rand = ceil(length(ind_fit_day).*rand(length(ind_fit_day),1));
         ind_test = ind_fit_day(ind_rand);
         p_test(j,:) = fr_function_fit(f_michelis_menten,[0.04 20 1],...
            -nee_unfilled(ind_test),options,ppfd_downwelling(ind_test));;
      end
      std_p(i,:) = std(p_test);
   end
   
   %figure;
   plot(ppfd_downwelling(ind_fit_day),-nee_unfilled(ind_fit_day),'.')
   hold on
   plot(0:100:2000,f_michelis_menten(p_all(i,:),0:100:2000),'r-')
   axis([0 2000 -10 40]);
end

return

