function convert_raw_logger_covariances_to_fluxes(year,SiteID)

% Compute EC fluxes from raw hhour covariances output from the CSI logger 
%  program. Could be used e.g. to gap fill EC fluxes calculated from HF data (the new_calc_and_save
% (matlab) code) 

% Procedure:
% 1. rotate and apply WPL corrections to raw covariances calculated by the
%    EC logger program
% 2. convert CO2 and H2O molar densities to mixing ratios and save avg, max
%    min and stdev for each to permit cleaning of the associated fluxes
% 3. Calculate ustar because we need to gapfill the ustar calculated from
%   HF data
% 4. Calculate fluxes based on the code in fr_calc_eddy
% 5. Save all traces to db so they can be loaded in FirstStage.ini and
%   cleaned and used in gapfilling

% Revisions
% Feb 19, 2014
%   -modified Hs calculation to correct wTs (buoyancy flux) to dry air
%   temperature flux. Used derivation of Liu et al. 2001, neglecting
%   crosswind term which is done internally in both the CSAT-3 and Gill R3-50
% March 4, 2013
%  - remove -999's (missing data due to IRGA downtime) and save wT so that H can be calculated with h2o mixing ratio from HMP
% Jan 16, 2012
%   -added Tsonic conversion to Tair, added removal of -999 values from
%   logger traces.

warning off;

UBC_biomet_constants;

pthFl   = biomet_path(year,SiteID,'Flux_Logger'); 

try
    tv      = read_bor(fullfile(biomet_path(year,SiteID),'Flux_Logger\TimeVector'),8);

    %load mean wind vector

    u = read_bor(fullfile(pthFl, 'u_wind_Avg'));
    v = read_bor(fullfile(pthFl, 'v_wind_Avg'));
    w = read_bor(fullfile(pthFl, 'w_wind_Avg'));

    meansIn = [u v w];

    % load raw covariances

    % c, H, u, v, w
    c_c = read_bor(fullfile(pthFl, 'CO2_cov_Cov1'));
    c_H = read_bor(fullfile(pthFl,'CO2_cov_Cov2'));
    c_u = read_bor(fullfile(pthFl,'CO2_cov_Cov3'));
    c_v = read_bor(fullfile(pthFl,'CO2_cov_Cov4'));
    c_w = read_bor(fullfile(pthFl,'CO2_cov_Cov5'));
    H_H = read_bor(fullfile(pthFl,'CO2_cov_Cov6'));
    H_u = read_bor(fullfile(pthFl,'CO2_cov_Cov7'));
    H_v = read_bor(fullfile(pthFl,'CO2_cov_Cov8'));
    H_w = read_bor(fullfile(pthFl,'CO2_cov_Cov9'));
    u_u = read_bor(fullfile(pthFl,'CO2_cov_Cov10'));
    u_v = read_bor(fullfile(pthFl,'CO2_cov_Cov11'));
    u_w = read_bor(fullfile(pthFl,'CO2_cov_Cov12'));
    v_v = read_bor(fullfile(pthFl,'CO2_cov_Cov13'));
    v_w = read_bor(fullfile(pthFl,'CO2_cov_Cov14'));
    w_w = read_bor(fullfile(pthFl,'CO2_cov_Cov15'));

    % % Tsonic, u, v, w
    T_T = read_bor(fullfile(pthFl,'Tsonic_cov_Cov1'));
    T_u = read_bor(fullfile(pthFl,'Tsonic_cov_Cov2'));
    T_v = read_bor(fullfile(pthFl,'Tsonic_cov_Cov3'));
    T_w = read_bor(fullfile(pthFl,'Tsonic_cov_Cov4'));


    co2_avg = read_bor(fullfile(pthFl,'CO2_Avg'));
    co2_std = read_bor(fullfile(pthFl,'CO2_Std'));
    co2_max = read_bor(fullfile(pthFl,'CO2_Max'));
    co2_min = read_bor(fullfile(pthFl,'CO2_Min'));

    h2o_avg = read_bor(fullfile(pthFl,'H2O_Avg'));
    h2o_std = read_bor(fullfile(pthFl,'H2O_Std'));
    h2o_max = read_bor(fullfile(pthFl,'H2O_Max'));
    h2o_min = read_bor(fullfile(pthFl,'H2O_Min'));

    Tsonic = read_bor(fullfile(pthFl,'Tsonic_Avg'));
    pbar = read_bor(fullfile(pthFl,'Irga_P_Avg'));
    
	% remove -999's (missing data due to IRGA downtime)
    IRGAOff=(h2o_avg==-999 | co2_avg==-999);
    iIRGAOff= find(IRGAOff);
    pbar(iIRGAOff) = NaN;
    co2_avg(iIRGAOff) = NaN;
	co2_std(iIRGAOff) = NaN;
	co2_max(iIRGAOff) = NaN;
	co2_min(iIRGAOff) = NaN;
	h2o_avg(iIRGAOff) = NaN;
	h2o_std(iIRGAOff) = NaN;
	h2o_max(iIRGAOff) = NaN;
	h2o_min(iIRGAOff) = NaN;
    
    % 1. ROTATION and WPL correction
    % rotation of raw covariances
    C1 = [u_u  u_v  v_v  u_w  v_w  w_w  c_u  c_v  c_w  c_c  H_u  H_v  H_w  c_H  H_H ];
    C2 = [u_u  u_v  v_v  u_w  v_w  w_w  T_u  T_v  T_w  T_T];

    disp(sprintf('%%%%%% Computing EC fluxes from raw logger covariances for %s, %s %%%%%%',SiteID,num2str(year)));
    disp(sprintf('....Rotating raw logger covariances'));
    [wT_rot,wH_rot,wc_rot,uw_rot,vw_rot] = rotate_cov_matrices(meansIn,C1,C2,T_w);

    % WPL for LI-7500 data, flux calc
    if ~strcmp(upper(SiteID),'HP11') & ~strcmp(upper(SiteID),'SQM')
        disp(sprintf('....applying WPL correction'));
        [Tair,rho_a] = Ts2Ta_using_density(Tsonic,pbar,h2o_avg); % calculate Tair from Tsonic and water vapour density
        %[Fc_wpl, E_wpl] = apply_WPL_correction(c_w,H_w,T_w,co2_avg,h2o_avg,Tair,pbar);  %unrotated
        [Fc_rot, E_rot] = apply_WPL_correction(wc_rot,wH_rot,wT_rot,co2_avg,h2o_avg,Tair,pbar);  %rotated
    else % HP11, SQM fluxes caluclated using mixing ratios output from LI7200--no WPL
        chi = h2o_avg./(1+h2o_avg/1000);
        if strcmp(upper(SiteID),'SQM'), Tsonic=Tsonic-ZeroK; end
        Tair = (Tsonic+ZeroK)./ (1 + 0.32 .* chi ./ 1000) - ZeroK; % calculate Tair from Tsonic and water vapour mixing ratio
        mol_density_dry_air   = (pbar./(1+h2o_avg/1000)).*(1000./(R*(Tair+ZeroK)));
        convC = mol_density_dry_air;             % convert umol co2/mol dry air -> umol co2/m3 dry air (refer to Pv = nRT)
        Fc_rot    = wc_rot .* convC;                      % CO2 flux (umol m-2 s-1)  
    end
    
    % 2. CONVERT molar densities to MIXING RATIOS for LI-7500 sites (avg,stdev,max,min)

    if ~strcmp(upper(SiteID),'HP11') & ~strcmp(upper(SiteID),'SQM') % HP11 and SQM have the LI-7200 which outputs mixing ratios
        disp(sprintf('....converting molar densities to mixing ratios'));
        [Cmix_avg, Hmix_avg,Cmolfr_avg, Hmolfr_avg] = fr_convert_open_path_irga(co2_avg,h2o_avg,Tair,pbar);
        [Cmix_std,Hmix_std,junk,junk]               = fr_convert_open_path_irga(co2_std,h2o_std,Tair,pbar);
        [Cmix_max,Hmix_max,junk,junk]               = fr_convert_open_path_irga(co2_max,h2o_max,Tair,pbar);
        [Cmix_min,Hmix_min,junk,junk]               = fr_convert_open_path_irga(co2_min,h2o_min,Tair,pbar);
    else
        Cmix_avg = co2_avg;
        Hmix_avg = h2o_avg;
        Cmix_std = co2_std;
        Hmix_std = h2o_std;
        Cmix_min = co2_min;
        Hmix_min = h2o_min;
        Cmix_max = co2_max;
        Hmix_max = h2o_max;
        Hmolfr_avg = Hmix_avg./(1+Hmix_avg/1000); % back calculate H2O mol fraction for Hsens calculation
    end
  
    %3. CALCULATE Fluxes

    % (a) Fc done above
	% *** Note that for LI-7200, no removal of delays is done on the logger prior to calculating the covariances
	%     The delay is ~ 1 sample at 5 Hz (1/5 s) and 3 samples for H2O (0.6 s) so the logger derived Fc and LE will need to be corrected if used.
 
    % (b) LE is calculated as follows (see fr_calc_eddy)
    R     = 8.31451;
    ZeroK = 273.15;

    mol_density_dry_air   = (pbar./(1+Hmix_avg/1000)).*(1000./(R*(Tair+ZeroK)));

    disp(sprintf('....calculating LE from wH'));
    if ~strcmp(upper(SiteID),'HP11') & ~strcmp(upper(SiteID),'SQM')
       %LE_rot = E_rot.*mol_density_dry_air;
       L_v      = Latent_heat_vaporization(Tair)./1000;    % J/g latent heat of vaporization Stull (1988)
	   LE_rot   = E_rot.*L_v.*(Mw./1000);
    else
       L_v      = Latent_heat_vaporization(Tair)./1000;    % J/g latent heat of vaporization Stull (1988)
       convH    = mol_density_dry_air.*Mw./1000;
       wH_g     = wH_rot .* convH;                                  % convert m/s(mmol/mol) -> m/s(g/m^3)
       LE_rot   = wH_g .* L_v;                                  % LE LICOR   
    end

    % (c) Sensible Heat is calculated as follows (see fr_calc_eddy)
    
    rho_moist_air = rho_air_wet(Tair,[],pbar,Hmolfr_avg);
    Cp_moist = spe_heat(Hmix_avg);

    disp(sprintf('....calculating H from wT'));
     %Hsens_rot  = wT_rot .* rho_moist_air .* Cp_moist;
        % use derivation of Liu et al. 2001 to calculate sensible heat flux from
        % Tsonic "buoyancy flux", with the modification that the crosswind term is taken care of internally by the CSAT.
        % Liu, H., Peters, G., and Foken, T.: 2001, ?New Equations for Sonic
        %    Temperature Variance and Buoyancy Heat Flux with an Omnidirectional
        %    Sonic Anemometer?, Boundary-Layer Meteorol., 100, 459-468. 
	    % ____   _____        _ ____
	    % w'T' = w'Ts' - 0.51*T w'q'  where q is the specific humidity--mass of
	    % water vapour div by total mass of air per unit vol.
    if ~strcmp(upper(SiteID),'HP11') & ~strcmp(upper(SiteID),'SQM') 
       wT_corr = wT_rot - (0.51*(Mw/Ma).*(Tair+ZeroK).*E_rot/1000)./rho_a;
    else % HP11, SQM
       wT_corr = wT_rot - (0.51*(Mw/Ma).*(Tair+ZeroK).*(wH_rot/1000))./mol_density_dry_air;
    end
        
    Hsens_rot = wT_corr .* rho_moist_air .* Cp_moist;
   

    % (d) Ustar

    disp(sprintf('....calculating Ustar from uw and vw'));
    ustar_rot=NaN.*ones(length(T_w),1); for i=1:length(uw_rot),ustar_rot(i)=(uw_rot(i)^2 + vw_rot(i)^2)^0.25; end

    % (e) convert IRGA h2o to RH for saving to db
    
    e   = (Hmolfr_avg./1000).*pbar; 
    es = sat_vp(Tsonic);
    RH_licor  = (e./es) .*100;
    
    % save all traces to local db

    pth_db = db_pth_root;

    disp(sprintf('....saving computed fluxes to %s',fullfile(biomet_path(year,SiteID),'Flux_logger\computed_fluxes')));
    save_bor(fullfile(biomet_path(year,SiteID),'Flux_logger\computed_fluxes','TimeVector'),8,tv);
    save_bor(fullfile(biomet_path(year,SiteID),'Flux_logger\computed_fluxes','co2_avg_irga_op_logger'),[],Cmix_avg);
    save_bor(fullfile(biomet_path(year,SiteID),'Flux_logger\computed_fluxes','h2o_avg_irga_op_logger'),[],Hmix_avg);
    save_bor(fullfile(biomet_path(year,SiteID),'Flux_logger\computed_fluxes','co2_std_irga_op_logger'),[],Cmix_std);
    save_bor(fullfile(biomet_path(year,SiteID),'Flux_logger\computed_fluxes','h2o_std_irga_op_logger'),[],Hmix_std);
    save_bor(fullfile(biomet_path(year,SiteID),'Flux_logger\computed_fluxes','co2_max_irga_op_logger'),[],Cmix_max);
    save_bor(fullfile(biomet_path(year,SiteID),'Flux_logger\computed_fluxes','h2o_max_irga_op_logger'),[],Hmix_max);
    save_bor(fullfile(biomet_path(year,SiteID),'Flux_logger\computed_fluxes','co2_min_irga_op_logger'),[],Cmix_min);
    save_bor(fullfile(biomet_path(year,SiteID),'Flux_logger\computed_fluxes','h2o_min_irga_op_logger'),[],Hmix_min);

    save_bor(fullfile(biomet_path(year,SiteID),'Flux_logger\computed_fluxes','sonic_temperature_logger'),[],Tsonic);
    save_bor(fullfile(biomet_path(year,SiteID),'Flux_logger\computed_fluxes','sonic_air_temperature'),[],Tair);
    save_bor(fullfile(biomet_path(year,SiteID),'Flux_logger\computed_fluxes','barometric_pressure_logger'),[],pbar);
    save_bor(fullfile(biomet_path(year,SiteID),'Flux_logger\computed_fluxes','relative_humidity_irga'),[],RH_licor);

    sitestr=SiteID(1:2);
    switch upper(sitestr)
        case 'HP'
            save_bor(fullfile(biomet_path(year,SiteID),'Flux_logger\computed_fluxes','fc_blockavg_rotated_5m_op_logger'),[],Fc_rot);
            save_bor(fullfile(biomet_path(year,SiteID),'Flux_logger\computed_fluxes','le_blockavg_rotated_5m_op_logger'),[],LE_rot);
            save_bor(fullfile(biomet_path(year,SiteID),'Flux_logger\computed_fluxes','ustar_rotated_5m_op_logger'),[],ustar_rot);
            save_bor(fullfile(biomet_path(year,SiteID),'Flux_logger\computed_fluxes','h_sonic_blockavg_rotated_5m_logger'),[],Hsens_rot);
			save_bor(fullfile(biomet_path(year,SiteID),'Flux_logger\computed_fluxes','wT_sonic_blockavg_rotated_5m_logger'),[],wT_rot);
        case 'MP'
            save_bor(fullfile(biomet_path(year,SiteID),'Flux_logger\computed_fluxes','fc_blockavg_rotated_26m_op_logger'),[],Fc_rot);
            save_bor(fullfile(biomet_path(year,SiteID),'Flux_logger\computed_fluxes','le_blockavg_rotated_26m_op_logger'),[],LE_rot);
            save_bor(fullfile(biomet_path(year,SiteID),'Flux_logger\computed_fluxes','ustar_rotated_26m_op_logger'),[],ustar_rot);
            save_bor(fullfile(biomet_path(year,SiteID),'Flux_logger\computed_fluxes','h_sonic_blockavg_rotated_26m_logger'),[],Hsens_rot);
			save_bor(fullfile(biomet_path(year,SiteID),'Flux_logger\computed_fluxes','wT_sonic_blockavg_rotated_26m_logger'),[],wT_rot);
        case {'UT','LT','BF'} % RWDI sites
		    save_bor(fullfile(biomet_path(year,SiteID),'Flux_logger\computed_fluxes','fc_blockavg_rotated_3m_op_logger'),[],Fc_rot);
            save_bor(fullfile(biomet_path(year,SiteID),'Flux_logger\computed_fluxes','le_blockavg_rotated_3m_op_logger'),[],LE_rot);
            save_bor(fullfile(biomet_path(year,SiteID),'Flux_logger\computed_fluxes','ustar_rotated_3m_op_logger'),[],ustar_rot);
            save_bor(fullfile(biomet_path(year,SiteID),'Flux_logger\computed_fluxes','h_sonic_blockavg_rotated_3m_logger'),[],Hsens_rot);
            save_bor(fullfile(biomet_path(year,SiteID),'Flux_logger\computed_fluxes','wT_sonic_blockavg_rotated_3m_logger'),[],wT_rot);
		case 'SQ'
            save_bor(fullfile(biomet_path(year,SiteID),'Flux_logger\computed_fluxes','fc_blockavg_rotated_50cm_ep_logger'),[],Fc_rot);
            save_bor(fullfile(biomet_path(year,SiteID),'Flux_logger\computed_fluxes','le_blockavg_rotated_50cm_ep_logger'),[],LE_rot);
            save_bor(fullfile(biomet_path(year,SiteID),'Flux_logger\computed_fluxes','ustar_rotated_50cm_logger'),[],ustar_rot);
            save_bor(fullfile(biomet_path(year,SiteID),'Flux_logger\computed_fluxes','h_sonic_blockavg_rotated_50cm_logger'),[],Hsens_rot);
			save_bor(fullfile(biomet_path(year,SiteID),'Flux_logger\computed_fluxes','wT_sonic_blockavg_rotated_50cm_logger'),[],wT_rot);
    end
catch
    disp(lasterr);
    disp(['... conversion/archiving of raw logger covariances to fluxes failed']);
end