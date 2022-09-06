function [] = get_flags(SiteID,years,pthout);

pth = biomet_path(years,SiteID,'fl');

switch upper(SiteID)
case 'OY'   
    ini.avgar = fr_get_logger_ini('oy',years,[],'oy_avgar','fl');   % main flux-stats array
    ini.avgar = rmfield(ini.avgar,'LoggerName');
    ini.avgbr = fr_get_logger_ini('oy',years,[],'oy_avgbr','fl');   % main flux-stats array
    ini.avgbr = rmfield(ini.avgbr,'LoggerName');
    ini.covaa = fr_get_logger_ini('oy',years,[],'oy_covaa','fl');   % main flux-stats array
    ini.covaa = rmfield(ini.covaa,'LoggerName');
    ini.covba = fr_get_logger_ini('oy',years,[],'oy_covba','fl');   % main flux-stats array
    ini.covba = rmfield(ini.covba,'LoggerName');
otherwise
    ini = [];   
end
    

[sonic_flag] = get_sonic_flag(pth,years,[],ini);
[irga_flag] = get_irga_flag(pth,years,[],ini);
[stationarity_flag] = get_stationarity_flag(pth,years,[],ini);

save_bor([pthout 'misc.sonic_flag1'],1,sonic_flag);
save_bor([pthout 'misc.irga_flag1'],1,irga_flag);
save_bor([pthout 'misc.stationarity_flag1'],1,stationarity_flag);

