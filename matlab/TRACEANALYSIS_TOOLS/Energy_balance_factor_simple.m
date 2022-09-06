function [ebc_correction,a_ebc] = energy_balance_factor_simple(Year,SiteId,ustar_threshold)
% ebc_correction = energy_balance_factor_simple(Year,SiteId,ustar_threshold)
%
% Reads energy balance terms for given years and site and determines the correction
% to be applied by doing an orthogonal regression of H+lE against Rn-G for each year
% requested.
% Returns a correction factor for each individual hhour.
%
% Inputs:
% Year,SiteId           - Characterizing data to be used, Year can be a vector;
% ustar_threshold       - data below this are not used in the analysis
%
% Outputs:
% ebc_correction  - hhour correction factor
% a_ebc				- regression parameters for the individual years

% kai* October 3, 2002

%-----------------------------------------------------------------------
% Default arguments
%-----------------------------------------------------------------------
if exist('ustar_threshold')~=1 | isempty(ustar_threshold)
   ustar_threshold = 0.3;
end

%-----------------------------------------------------------------------
% Read data
%-----------------------------------------------------------------------
pth_db = biomet_path('yyyy',SiteId,'clean\secondstage');

clean_tv 				= read_bor([pth_db 'clean_tv'],8,[],Year,[],1);
radiation_net_main	= read_bor([pth_db 'radiation_net_main'],[],[],Year,[],1);
energy_storage_main	= read_bor([pth_db 'energy_storage_main'],[],[],Year,[],1);
h_main					= read_bor([pth_db 'h_main'],[],[],Year,[],1);
le_main					= read_bor([pth_db 'le_main'],[],[],Year,[],1);
ustar_main				= read_bor([pth_db 'ustar_main'],[],[],Year,[],1);
nee_main					= read_bor([pth_db 'nee_main'],[],[],Year,[],1);
soil_temperature_main= read_bor([pth_db 'soil_temperature_main'],[],[],Year,[],1);
air_temperature_main = read_bor([pth_db 'air_temperature_main'],[],[],Year,[],1);
precipitation			= read_bor([pth_db 'precipitation'],[],[],Year,[],1);

pth_db = biomet_path('yyyy','cr','clean\thirdstage');
radiation_downwelling_potential	= read_bor([pth_db 'radiation_downwelling_potential'],[],[],Year,[],1);
radiation_downwelling_potential = radiation_downwelling_potential(1:length(clean_tv));

[tv_doy yyyy] = convert_tv(clean_tv,'doy',8);

available_energy = radiation_net_main - energy_storage_main;
turbulent_flux   = h_main + le_main;

%-----------------------------------------------------------------------
% Exclude flues before and after precip
%-----------------------------------------------------------------------
ind = find(precipitation ~= 0 | air_temperature_main < 1);
ind = ind(2:end-1); % so the next line works
ind_precip = unique([ind ind+1 ind-1]);
turbulent_flux(ind_precip) = NaN;
available_energy(ind_precip) = NaN;

%-----------------------------------------------------------------------
% Energy balance closure total for the years
%-----------------------------------------------------------------------
m = length(Year);
m_spl = ceil(m/3);
for i = 1:length(Year)
   ind_yy = find(yyyy == Year(i) & ...
      ( (ustar_main > ustar_threshold & radiation_downwelling_potential == 0) ...
      | (radiation_downwelling_potential > 20) )  );
   a_ebc(i,:) = linregression_orthogonal(available_energy(ind_yy),turbulent_flux(ind_yy));
   
   % Plot if no output was requested
   if nargout==0
      figure
      plot_regression(available_energy(ind_yy),turbulent_flux(ind_yy),-200,1000);
      title(num2str(Year(i)));
   end
   
end

%-----------------------------------------------------------------------
% Create vector of correction factors
%-----------------------------------------------------------------------
ebc_correction = NaN .* ones(size(clean_tv));
for i = 1:length(Year)
   ind_yy = find(yyyy == Year(i));
   ebc_correction(ind_yy) = a_ebc(i,1);
end

return
