function [nep_filled,nep_fitted,eco_respiration,eco_photosynthesis,ind_filled,param] ...
   = fr_nep_analysis(ppfd_downwelling,soil_temperature,fc,co2_storage,...
                     ustar,radiation_downwelling_potential,analysis_info,growing_season)
% [nep_filled,nep_fitted,eco_respiration,eco_photosynthesis] ...
%    = fr_nep_analysis(ppfd_downwelling,soil_temperature,nee_unfilled,...
%                      ustar_main,radiation_downwelling_potential,analysis_info,growing_season)
%
% analysis_info is a structur that contains the information needed to carry out 
% the analysis using a certain combination of methods. The structur should look like this
% analysis_info.ebc_factor
%              .ustar_threshold
%              .photoinhibition_factor (subpression in % => * (1-photoinhibition_factor/100)
% growing_season - a vector that is 1 for all measurements during the growing season

% This analysis follows the scheme sketched in Kladde4, 8/8/2002

%-----------------------------------------------------------------
% EBC correction
%-----------------------------------------------------------------
fc = fc ./ analysis_info.ebc_factor;
nee_unfilled = fc+co2_storage;

%-----------------------------------------------------------------
% Select high ustar cases for analysis
%-----------------------------------------------------------------
ind_select = find( ustar < analysis_info.ustar_threshold & radiation_downwelling_potential == 0 );
nee_unfilled(ind_select) = NaN;

%-----------------------------------------------------------------
% Get ecosystem respiration
%-----------------------------------------------------------------
% Select observations
eco_respiration_measured = NaN .* ones(size(nee_unfilled));
ind_night = find(radiation_downwelling_potential == 0 | ~growing_season);
eco_respiration_measured(ind_night) = nee_unfilled(ind_night);

% Do regression
ind_fit_night = find(~isnan(soil_temperature) & ~isnan(eco_respiration_measured) ...
   & eco_respiration_measured > 0);
a = linregression(soil_temperature(ind_fit_night),log(eco_respiration_measured(ind_fit_night)));
[lin_R,lin_dR] = linprediction(a,soil_temperature);

eco_respiration_fitted       = exp(lin_R);

eco_respiration = eco_respiration_measured;
ind_nan_r = find(isnan(eco_respiration_measured));
eco_respiration(ind_nan_r) = eco_respiration_fitted(ind_nan_r);


% See Kladde4, 18/06/2002, 12/8/2002, and 25/11/2002 for details
% on conversion and error progression calculations
Q_10 = exp(a(1)*10);
R_10  = exp(a(2))*exp(a(1)*10);
dQ_10 =  10 * exp(10*a(1)) * a(5);
dR_10 = sqrt( (R_10*a(6))^2 + (10*R_10 * a(5))^2 );

%-----------------------------------------------------------------
% Apply photoinhibition factor to daytime respiration
%-----------------------------------------------------------------
% Select observations
ind_day = find(radiation_downwelling_potential > 0 & growing_season);
eco_respiration(ind_day) = eco_respiration(ind_day) .* (1-analysis_info.photoinhibition_factor/100);

%-----------------------------------------------------------------
% Calc ecosystem photosynthesis from measured NEEs
%-----------------------------------------------------------------
% Respiration is of course not measured...
% Select observations
ind_photosyn = find(~isnan(nee_unfilled) & ~isnan(eco_respiration)...
 & radiation_downwelling_potential > 0 & growing_season);

eco_photosynthesis_measured = zeros(size(eco_respiration));
eco_photosynthesis_measured(ind_photosyn) = -nee_unfilled(ind_photosyn) + eco_respiration(ind_photosyn);
% After this fill gaps in eco_respiration
ind_nan_r = find(isnan(eco_respiration));
eco_respiration(ind_nan_r) = 0;

ind_zero = find(eco_photosynthesis_measured==0 & radiation_downwelling_potential > 0);
eco_photosynthesis_measured(ind_zero) = NaN;

%-----------------------------------------------------------------
% Calc fit for Michelis Menten function
%-----------------------------------------------------------------
% Things needed in the fitting proceedure
f_michelis_menten = inline('p(1).*p(2).*x./(p(1).*x+p(2))','p','x');
options = optimset('maxiter', 10^3, 'maxfunevals', 10^3, 'tolx', 10^-3);

ind_fit_day = find(~isnan(eco_photosynthesis_measured) & ~isnan(ppfd_downwelling) ...
   & radiation_downwelling_potential > 0 & growing_season);
p_all = fr_function_fit(f_michelis_menten,[0.04 20],...
   eco_photosynthesis_measured(ind_fit_day),options,ppfd_downwelling(ind_fit_day));

eco_photosynthesis_fitted = f_michelis_menten(p_all,ppfd_downwelling);
ind_zero_fitted = find(~growing_season);
eco_photosynthesis_fitted(ind_zero_fitted) = 0;
ind_nan_p = find(isnan(eco_photosynthesis_fitted));
eco_photosynthesis_fitted(ind_nan_p) = 0;

eco_photosynthesis = eco_photosynthesis_measured;
ind_nan_p = find(isnan(eco_photosynthesis_measured));
eco_photosynthesis(ind_nan_p) = eco_photosynthesis_fitted(ind_nan_p);

if isfield(analysis_info,'error_estimates') & analysis_info.error_estimates == 1
   N = 100;
   p_test = NaN.*zeros(N,2);
   rand('state',0)
   for i = 1:N
      disp(['Fitting trial ' num2str(i)]);
      ind_rand = ceil(length(ind_fit_day).*rand(length(ind_fit_day),1));
      ind_test = ind_fit_day(ind_rand);
      p_test(i,:) = fr_function_fit(f_michelis_menten,[0.04 20],...
         eco_photosynthesis_measured(ind_test),[],ppfd_downwelling(ind_test));;
   end
   std_p = std(p_test);
   
   % Just for easiear reading
    alpha = p_all(1);     Amax = p_all(2);
   dalpha = std_p(1);    dAmax = std_p(2);
   
   %-----------------------------------------------------------------
   % Assemble fit parameters
   %-----------------------------------------------------------------
   param = [R_10 dR_10 Q_10 dQ_10 alpha dalpha Amax dAmax];
else
   param = NaN .* ones(1,8);
end

%-----------------------------------------------------------------
% Assemble output traces
%-----------------------------------------------------------------
nep_fitted  = eco_photosynthesis - eco_respiration;

nep_filled  = -nee_unfilled;
ind_filled	= isnan(nee_unfilled);
nep_filled(ind_filled) = nep_fitted(find(ind_filled));

return


