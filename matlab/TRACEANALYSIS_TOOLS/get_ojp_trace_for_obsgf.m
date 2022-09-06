function [trace_jp,ind] = get_ojp_trace_for_obsgf(tv,year,trace_in,met_type,doy_begin,doy_end);

doy_bs_local = tv - datenum(year,1,0) - 6/24;
pth_jp_meas  = [biomet_path(2005,'JP') 'Clean\SecondStage']; 
switch met_type
    case 'temp'
        trace_jp     = read_bor(fullfile(pth_jp_meas,'air_temperature_main'));
    case  'RH'
        trace_jp     = read_bor(fullfile(pth_jp_meas,'relative_humidity_main'));
    case 'PAR'
        trace_jp     = read_bor(fullfile(pth_jp_meas,'ppfd_downwelling_main'));
end
ind         = find((doy_bs_local >= doy_begin & doy_bs_local <= doy_end) &...
                     (isnan(trace_in) & ~isnan(trace_jp)));

return