function [tv,nep_filled_total,eco_respiration_total,eco_photosynthesis_total,ind_filled_total,param_total] = nep_analysis(Years,SiteId,analysis_info,sum_flag,start_doy,pth_in)
% [nep_filled_total,eco_respiration_total,eco_photosynthesis_total] = ...
% 										nep_analysis(Year,SiteId,analysis_info,sum_flag)
%
% Does the gap filling using functional relationships and criteria given in a strucuture
% with the following elements:
%
% analysis_info(i).ebc_factor
% analysis_info(i).ustar_threshold
% analysis_info(i).photoinhibition_factor
%
% The structure can be an array that will be cycled through and the answer for the
% various elements is stored in the last dimension of the output
% 
% If Years is an array the analysis will cycle and the second dimension contains the 
% results per year
% 
% If sum_flag is 1(the default) the output contains cumulative values in g C m^-2.

% kai* August 13, 2002

if ~exist('sum_flag') | isempty(sum_flag)
   sum_flag = 1;
end

if ~exist('start_doy') | isempty(start_doy)
   start_doy = 1; 
end

if ~exist('pth_in') | isempty(pth_in)
   pth_in = 'clean\secondstage'; 
end

tv                       = NaN .* ones(366*48,length(Years));
nep_filled_total         = NaN .* ones(366*48,length(Years),length(analysis_info));
eco_respiration_total    = NaN .* ones(366*48,length(Years),length(analysis_info));
eco_photosynthesis_total = NaN .* ones(366*48,length(Years),length(analysis_info));
ind_filled_total         = NaN .* ones(366*48,length(Years),length(analysis_info));
param_total              = NaN .* ones(8,length(Years),length(analysis_info));         

for j = 1:length(Years)
   
   if start_doy == 1;
      Year = Years(j);
   else
      Year = [Years(j) Years(j)+1];
   end
   
   %-----------------------------------------------------------------
   % Read data
   %-----------------------------------------------------------------
   pth_db_2 = biomet_path('yyyy',SiteId,pth_in);
   pth_db_3 = biomet_path('yyyy',SiteId,'clean\thirdstage');
   
   clean_tv 				 = read_bor([pth_db_2 'clean_tv'],8,[],Year,[],1);
	indOut = find(clean_tv > datenum(Year(1),1,start_doy) & clean_tv < datenum(Year(1),1,start_doy+365));
   clean_tv					 = clean_tv(indOut);
   fc_main				    = read_bor([pth_db_2 'fc_main'],[],[],Year,indOut,1);
   co2_avg_main		    = read_bor([pth_db_2 'co2_avg_main'],[],[],Year,indOut,1);
   h2o_avg_main		    = read_bor([pth_db_2 'h2o_avg_main'],[],[],Year,indOut,1);
   air_temperature_main  = read_bor([pth_db_2 'air_temperature_main'],[],[],Year,indOut,1);
   barometric_pressure   = read_bor([pth_db_2 'barometric_pressure_main'],[],[],Year,indOut,1);
   ustar_main				 = read_bor([pth_db_2 'ustar_main'],[],[],Year,indOut,1);
   ppfd_downwelling_main = read_bor([pth_db_2 'ppfd_downwelling_main'],[],[],Year,indOut,1);
   if strcmp(upper(SiteId),'CR')
      [soil_temperature_main] = get_soil_temperature_CR([],Year);
      soil_temperature_main = soil_temperature_main(indOut);
   else
	   soil_temperature_main = read_bor([pth_db_2 'soil_temperature_main'],[],[],Year,indOut,1);
   end
   
   radiation_downwelling_potential	= read_bor([pth_db_3 'radiation_downwelling_potential'],[],[],Year,indOut,1);
   
   [tv_doy yyyy] = convert_tv(clean_tv,'doy');
   
   %---------------------------------------------------------------------
   % Determine the growing season
   %---------------------------------------------------------------------
   switch upper(SiteId)
   case 'CR'
      growing_season = air_temperature_main > -1 | isnan(air_temperature_main);
   case 'PA'
      pth_db_berms = biomet_path('yyyy',SiteId,'BERMS\lai2');
      lai_hazel				 = read_bor([pth_db_berms 'Hazel_BestLAI'],[],[],Year,[],1);
      lai_hazel				 = ta_interp_points(lai_hazel,48);
      lai_aspen				 = read_bor([pth_db_berms 'Aspen_BestLAI'],[],[],Year,[],1);
      lai_aspen				 = ta_interp_points(lai_aspen,48);
      lai						 = lai_hazel+lai_aspen;
      growing_season = lai>0.3;
      
      % Absorbed PAR according to Tim after Peter Blanken
      i=find(lai_hazel < 0.0); lai_hazel(i)=0.0;
	   i=find(lai_hazel> 2.2);  lai_hazel(i)=2.2;
   
   	ka = 0.540; kh = 0.756; Awa=0.96; alpha = 0.03;
   
   	%Absorbed PAR BY CANOPY
      ppfd_downwelling_main = ppfd_downwelling_main ...
         .*[1-exp(lai_aspen.*-ka) + exp((lai_aspen + Awa).*-ka).*(1-exp(lai_hazel*-kh))].*[1-alpha];

   case 'JP'
   case 'BS'
   end
   
   %---------------------------------------------------------------------
   % Calculate storage
   %---------------------------------------------------------------------
   switch upper(SiteId)
   case 'CR'
      height = 43;
   case 'PA'
      height = 39;
   case 'JP'
      height = 25;
   case 'BS'
      height = 28;
   end
   co2_storage = calc_co2_storage_multi_level(clean_tv,co2_avg_main,...
      h2o_avg_main,air_temperature_main,barometric_pressure,height);

   %---------------------------------------------------------------------
   % Cycle through analysis
   %---------------------------------------------------------------------
   
   tv(1:length(clean_tv),j) = clean_tv;
   
   for i = 1:length(analysis_info)
      disp([SiteId ' ' num2str(Year) ' Analysis ' num2str(i)]);
      
      if analysis_info(i).ebc_correction == 1
         [analysis_info(i).ebc_factor] = energy_balance_factor_simple(Year,SiteId,analysis_info(i).ustar_threshold);
      else
         analysis_info(i).ebc_factor = 1;
      end
      
      if isfield(analysis_info(i),'fc_trace')
         if ~strcmp(analysis_info(i).fc_trace,'none')
            eval(['fc_main = ' analysis_info(i).fc_trace '(Year,SiteId);']);
            fc_main = fc_main(indOut);
         end
      end
            

      [nep_filled,nep_fitted,eco_respiration,eco_photosynthesis,ind_filled,param] ...
         = fr_nep_analysis(ppfd_downwelling_main,soil_temperature_main,fc_main,co2_storage,...
         ustar_main,radiation_downwelling_potential,analysis_info(i),growing_season);
      
      % Sum and save traces into matrix for later reference
      if sum_flag == 1                 
         nep_filled_total(1:length(clean_tv),j,i)         = cumsum(nep_filled) 			.* 12e-6*1800;
         eco_respiration_total(1:length(clean_tv),j,i)    = cumsum(eco_respiration)    .* 12e-6*1800;
         eco_photosynthesis_total(1:length(clean_tv),j,i) = cumsum(eco_photosynthesis) .* 12e-6*1800;
      else
         nep_filled_total(1:length(clean_tv),j,i)         = nep_filled;
         eco_respiration_total(1:length(clean_tv),j,i)    = eco_respiration;
         eco_photosynthesis_total(1:length(clean_tv),j,i) = eco_photosynthesis;
      end
      ind_filled_total(1:length(clean_tv),j,i) = ind_filled;
      param_total(:,j,i) = param;
   end
   
end

return