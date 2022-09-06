function run_SQ_footprint_hhourly(siteId,dateIn,pthOut)

% runs footprint

dateIn=fr_round_time(dateIn,[],3);
dv=datevec(dateIn);
year=dv(1);
pthfl = biomet_path(year,siteId,'Flux_logger\computed_fluxes');
pthlgr = biomet_path(year,siteId,'Flux_logger');

SiteInfo.tv = dateIn;
SiteInfo.h_c = 0.5; %canopy height in meter
SiteInfo.z_m = 1; %EC sensor height in meter
pbar = read_bor(fullfile(pthfl,'barometric_pressure_logger'));  %barometric pressure

u         = read_bor([pthlgr 'u_wind_Avg']);
% u_max     = read_bor([pth 'u_wind_Max']);
% u_min     = read_bor([pth 'u_wind_Min']);
% u_std     = read_bor([pth 'u_wind_Std']);

v         = read_bor([pthlgr 'v_wind_Avg']);
% v_max     = read_bor([pth 'v_wind_Max']);
% v_min     = read_bor([pth 'v_wind_Min']);
% v_std     = read_bor([pth 'v_wind_Std']);

wdir   = FR_Sonic_wind_direction([u'; v'],'RMY');
wdir= wdir';
wdir_cor = mod(wdir +30,360); % +30 to correct sonic orientation wrt N, 
wdir_rot = mod(wdir_cor +90,360); % rotate +90 because we want the footprint plot to have N where E usually is 
wspd = (u.^2 + v.^2).^0.5;

% daytime
tv           = read_bor(fullfile(pthfl,'TimeVector'),8);
indfp = find(tv==dateIn);

SiteInfo.p_bar = pbar(indfp);
SiteInfo.u     = wspd(indfp); %3, in m/s_a
SiteInfo.wd    = wdir_rot(indfp); %25, in degrees, **Note this is a bogus wdir to make the plot work with NS oriented horizontally
Tair           = read_bor(fullfile(pthfl,'sonic_air_temperature')); %20, air temperature at z_m in oC
RH             = read_bor(fullfile(pthfl,'relative_humidity_irga')); % 50, air relative humidity at z_m in %
Hs             = read_bor(fullfile(pthfl,'h_sonic_blockavg_rotated_50cm_logger')); % 200,  % sensible heat flux in w/m^2
LE             = read_bor(fullfile(pthfl,'le_blockavg_rotated_50cm_ep_logger')); %75; %latent heat flux in w/m^2
Fc             = read_bor(fullfile(pthfl,'Fc_blockavg_rotated_50cm_ep_logger')); 
uSt            = read_bor(fullfile(pthfl,'ustar_rotated_50cm_logger'));

SiteInfo.T_a   =  Tair(indfp);    %20, air temperature at z_m in oC
SiteInfo.RH    =  RH(indfp);      % 50, air relative humidity at z_m in %
SiteInfo.H     =  Hs(indfp);      % 200,  % sensible heat flux in w/m^2
SiteInfo.LE    =  LE(indfp);      %75; %latent heat flux in w/m^2
SiteInfo.Fc    =  Fc(indfp);
SiteInfo.uSt   =  uSt(indfp);

disp(sprintf('\n K+M footprint input for half-hour ending %s\n',datestr(dateIn)));
disp(sprintf('Windspeed: %4.2g m/s',SiteInfo.u));
disp(sprintf('u_{*}: %4.2g m/s',SiteInfo.uSt));
disp(sprintf('Wind direction: %4.0f degrees',wdir_cor(indfp)));
disp(sprintf('Air Temperature: %4.2f degC',SiteInfo.T_a));
disp(sprintf('Relative Humidity: %4.2f %%',SiteInfo.RH));
disp(sprintf('Sensible Heat Flux: %5.2f W/m2',SiteInfo.H));
disp(sprintf('Latent Heat Flux: %5.2f W/m2',SiteInfo.LE));

try
calc_ShellQuest_footprint(SiteInfo);
catch
    disp(sprintf('KM footprint failed for %s',datestr(tv(indfp))));
    return
end
% FileName_p = FR_DateToFileName(fr_round_time(dateIn,'30min',3)); GMT
% filenames
GMToffset=6/24;
dv_loc=datevec(dateIn-GMToffset);
hhmm_loc = dv_loc(4)*100+dv_loc(5);
hhmmstr = num2str(hhmm_loc);
if length(hhmmstr)==1
    hhmmstr='2400';
elseif length(hhmmstr)==2
    hhmmstr=['00' hhmmstr];
elseif length(hhmmstr)==3
    hhmmstr=['0' hhmmstr];
end

FileName_p = FR_DateToFileName(fr_round_time(dateIn-GMToffset,'30min',3));
A = getframe(gcf);
imwrite(A.cdata, fullfile(pthOut,[FileName_p(1:6) '_' hhmmstr '_SQM_flux_footprint.jpeg']));
copyfile(fullfile(pthOut,[FileName_p(1:6) '_' hhmmstr '_SQM_flux_footprint.jpeg']),fullfile(pthOut,['Current_SQM_flux_footprint.jpeg']));
fullfile(pthOut,['SQM_flux_footprint_' FileName_p '.jpeg'])
%print('-djpeg',fullfile(pthOut,['SQM_flux_footprint_' FileName_p '.jpeg']));
%close;