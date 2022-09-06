function [soil_temperature_al2,ppfd_downwelling_al2] = fr_get_al2(SiteId,clean_tv_in)

pth = biomet_path('yyyy',SiteId,'BERMS\al2');
[yy,mm,dd] = datevec(clean_tv_in);
%Year = unique(yy);
Year = yy(8000);

switch upper(SiteId)
case 'PA'
   clean_tv             = read_bor([pth 'clean_tv'],8,[],Year,[],1);
   ppfd_downwelling_al2 = read_bor([pth 'Down_PAR_AbvCnpy_37m'],[],[],Year,[],1);
   Soil_Temp_S_2cm      = read_bor([pth 'Soil_Temp_S_2cm'],[],[],Year,[],1);
   Soil_Temp_N_2cm      = read_bor([pth 'Soil_Temp_N_2cm'],[],[],Year,[],1);
   soil_temperature_al2 = calc_avg_trace(clean_tv,[Soil_Temp_S_2cm,Soil_Temp_N_2cm]);
   
   [tv_dum,ind_read,ind_in] = intersect(fr_round_hhour(clean_tv),fr_round_hhour(clean_tv_in));
   
   ppfd_downwelling_al2 = ppfd_downwelling_al2(ind_read);
   soil_temperature_al2 = soil_temperature_al2(ind_read);
case 'JP'
   clean_tv             = read_bor([pth 'clean_tv'],8,[],Year,[],1);
   ppfd_downwelling_al2 = read_bor([pth 'Down_PAR_AbvCnpy_28m'],[],[],Year,[],1);
   Soil_Temp_SW_2cm     = read_bor([pth 'Soil_Temp_SW_2cm'],[],[],Year,[],1);
   Soil_Temp_NW_2cm     = read_bor([pth 'Soil_Temp_NW_2cm'],[],[],Year,[],1);
   soil_temperature_al2 = calc_avg_trace(clean_tv,[Soil_Temp_SW_2cm,Soil_Temp_NW_2cm]);
   
   [tv_dum,ind_read,ind_in] = intersect(fr_round_hhour(clean_tv),fr_round_hhour(clean_tv_in));
   
   ppfd_downwelling_al2 = ppfd_downwelling_al2(ind_read);
   soil_temperature_al2 = soil_temperature_al2(ind_read);
case 'BS'
   clean_tv             = read_bor([pth 'clean_tv'],8,[],Year,[],1);
   ppfd_downwelling_al2 = read_bor([pth 'Down_PAR_AbvCnpy_25m'],[],[],Year,[],1);
   Soil_Temp_NE_2cm     = read_bor([pth 'Soil_Temp_NE_2cm'],[],[],Year,[],1);
   Soil_Temp_NW_2cm     = read_bor([pth 'Soil_Temp_NW_2cm'],[],[],Year,[],1);
   soil_temperature_al2 = calc_avg_trace(clean_tv,[Soil_Temp_NE_2cm,Soil_Temp_NW_2cm]);
   
   [tv_dum,ind_read,ind_in] = intersect(fr_round_hhour(clean_tv),fr_round_hhour(clean_tv_in));
   
   ppfd_downwelling_al2 = ppfd_downwelling_al2(ind_read);
   soil_temperature_al2 = soil_temperature_al2(ind_read);
case 'CR'
   pth = biomet_path('yyyy',SiteId,'clean\secondstage');
   [yy,mm,dd] = datevec(clean_tv_in);
   %Year = unique(yy);
   Year = yy(8000);
   
   clean_tv             = read_bor([pth 'clean_tv'],8,[],Year,[],1);
   ppfd_downwelling_al2 = read_bor([pth 'ppfd_downwelling_main'],[],[],Year,[],1);
   soil_temperature_al2 = read_bor([pth 'soil_temperature_main'],[],[],Year,[],1);
   
   [tv_dum,ind_read,ind_in] = intersect(fr_round_hhour(clean_tv),fr_round_hhour(clean_tv_in));
   
   ppfd_downwelling_al2 = ppfd_downwelling_al2(ind_read);
   soil_temperature_al2 = soil_temperature_al2(ind_read);
end

