function [NEP,R,GEP,NEPgf,Rgf,GEPgf,RHat,GEPHat,RHat0,GEPHat0,cR,cGEP,bR,bGEP,bR_winter,t] = opsite_web_analysis(year,SiteId);

switch SiteId
   case {'HP09','HP11'}
      uStarTH = 0.12;
	  mSEBClosure = 1;
      dheight = [2.5];
   case {'MPB1','MPB2','MPB3'}  
      uStarTH = 0.3;
	  mSEBClosure = 1;
      dheight = [26];
   otherwise
	  disp('opsite_web_analysis: Site not recognized for production of graphs'); 
	  return
end
	  

%arg_default('Plots',[1:5]);

[PPFD,t] = read_db(year,SiteId,'clean\secondstage','ppfd_downwelling_main');
Ta       = read_db(year,SiteId,'clean\secondstage','air_temperature_main');
Ts       = read_db(year,SiteId,'clean\secondstage','soil_temperature_main');
NEE      = read_db(year,SiteId,'clean\secondstage','nee_main');
uStar    = read_db(year,SiteId,'clean\secondstage','ustar_main');

% load up logger traces for calculating NEE from Fc
Pbar_lgr       = read_db(year,SiteId,'Flux_Logger\computed_fluxes','barometric_pressure_logger');
co2_lgr = read_db(year,SiteId,'Flux_Logger\computed_fluxes','co2_avg_irga_op_logger');
h2o_lgr = read_db(year,SiteId,'Flux_Logger\computed_fluxes','h2o_avg_irga_op_logger');
Fc_lgr      = read_db(year,SiteId,'Flux_Logger\computed_fluxes','fc_blockavg_rotated_5m_op_logger');
uStar_lgr    = read_db(year,SiteId,'Flux_Logger\computed_fluxes','ustar_rotated_5m_op_logger');

 dheight = [2.5];
 co2_stor = calc_co2_storage_multi_level(t,co2_lgr,h2o_lgr,Ta, ...
                                         Pbar_lgr,dheight);
NEE_lgr =  Fc_lgr + co2_stor;

% quick and dirty despike/throw out unreasonable fluxes
ind_spk = find(NEE_lgr>50 | NEE_lgr<-50);
NEE_lgr(ind_spk)=NaN;

PPFDGF    = read_db(year,SiteId,'clean\thirdstage','TS.ppfd_downwelling_main');
TaGF       = read_db(year,SiteId,'clean\thirdstage','TS.air_temperature_main');
TsGF       = read_db(year,SiteId,'clean\thirdstage','TS.soil_temperature_main');
pot_rad       = read_db(year,SiteId,'clean\thirdstage','TS.radiation_downwelling_potential');

% splice most recent NEE data (calculated from logger Fc) onto 3rd stage
% NEE, also uStar
ind_max = max(find(~isnan(NEE_lgr)));
ind_fill = find( t<=t(ind_max) & t<now  & isnan(NEE) & ~isnan(NEE_lgr));
NEE(ind_fill)=NEE_lgr(ind_fill);

ind_max = max(find(~isnan(uStar_lgr)));
ind_fill = find(t<=t(ind_max) & t<now & isnan(uStar) & ~isnan(uStar_lgr));
uStar(ind_fill)=uStar_lgr(ind_fill);

isNight = pot_rad == 0;
       
[NEP,R,GEP,NEPgf,Rgf,GEPgf,RHat,GEPHat,RHat0,GEPHat0,cR,cGEP,bR,bGEP,bR_winter] = ...
    FCRN_CO2Flux2NEP_opsite_MovWin(t,NEE,uStar,PPFD,Ta,Ts,PPFDGF,TaGF,TsGF,isNight,uStarTH,mSEBClosure,[],[]); 

pth_out=fullfile(biomet_path(year,SiteId),'Flux_Logger\computed_fluxes\web_plot_traces');
save_bor(fullfile(pth_out,'nep_filled_with_fits'), [], NEPgf);
save_bor(fullfile(pth_out,'eco_photosynthesis_filled_with_fits'), [], GEPgf);
save_bor(fullfile(pth_out,'eco_respiration_filled_with_fits'), [], Rgf);
save_bor(fullfile(pth_out,'clean_tv'), 8, t);