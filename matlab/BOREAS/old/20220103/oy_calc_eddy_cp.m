function [statsar, statsbr] = oy_calc_eddy_cp(stats);

%program to calculate open-path irga co2 and water vapour fluxes
%
% outputs: statsar - stats after rotation
%          statsbr - stats before rotation
%
% E.Humphreys Nov 22, 2001
%

% read in CONSTANTS
UBC_biomet_constants

for i = 1:2;
   statsOut = stats;
   
   switch i
   case 1;
      %do coordinate rotation (or not)
      [means3,covs3, scalcovsu3, scalcovsv3, scalcovsw3, angles] = ...
         oy_rotatN(stats.means,stats.covs,stats.scalcovsu,stats.scalcovsv,stats.scalcovsw);
      
      statsOut.means     = means3;
      statsOut.covs      = covs3;
      statsOut.scalcovsu = scalcovsu3;
      statsOut.scalcovsv = scalcovsv3;
      statsOut.scalcovsw = scalcovsw3;
   case 2;
   end
   
   %h2o_mmol_mol = statsOut.means(:,8).*...
   %   (8.314./(18/1000))./1000.*(statsOut.means(:,5)+273)./statsOut.Pbar(:,1);
   h2o_mmol_mol = statsOut.means(:,8)./(statsOut.means(:,8)./1000 + 1);
   h2o_mixratio = statsOut.means(:,8);
   
   
   % extract variables needed for the flux calculations
   Tair = statsOut.means(:,6)+ ZeroK;
   ind = find(Tair <-25+ZeroK | Tair > 45+ZeroK);
   if ~isempty(ind);
       Tair(ind) = statsOut.means(ind,5) + ZeroK;          % get the best Tair and convert to K
   end
      
   h2o_bar = statsOut.means(:,8);                % get the best h2o_bar
   WaterMoleFraction = h2o_bar./(1+h2o_bar./1000);               % get mmol/mol of wet air              
   BarometricP = statsOut.Pbar(:,1);
   
   rho_moist_air = rho_air_wet(Tair-ZeroK,[],BarometricP,WaterMoleFraction); % density of moist air
   L_v       = Latent_heat_vaporization(Tair-ZeroK)./1000;     % J/g latent heat of vaporization Stull (1988)             
   Cp_moist = spe_heat(WaterMoleFraction);                     %specific heat of moist air
   convC    = BarometricP.*1000./(R.*Tair);                    % convert umol co2/mol dry air -> umol co2/m3 dry air (refer to Pv = nRT)
   convH    = BarometricP.*1000./(Rv.*Tair);                   % convert mmol h2o/mol dry air -> g h2o/m3 (refer to Pv = nRT)
   
   %Sensible heat flux        
   H_sonic     =  statsOut.scalcovsw(:,2).* rho_moist_air .* Cp_moist; % Sensible heat (Sonic)
   H_fwtc      =  statsOut.scalcovsw(:,3).* rho_moist_air .* Cp_moist; %corrected W/m2
   
   %co2 flux
   F    = statsOut.scalcovsw(:,4) .* convC;                      % CO2 flux (umol m-2 s-1)
  
  %h2o flux 
  wh_g     = statsOut.scalcovsw(:,5) .* convH;                                  % convert m/s(mmol/mol) -> m/s(g/m^3)
  LE_licor  = wh_g .* L_v;
  
  
  %
  % Krypton WPL correction
  %
  
   LE_krypton   = NaN.*ones(size(statsOut.scalcovsw(:,1)));                  %corrected W/m2
   
  %
  % Ustar
  %  
   ustar = ( statsOut.covs(:,5).^2 + statsOut.covs(:,6).^2 ) .^ 0.25;  
    
   statsOut.fluxes = [LE_licor H_sonic H_fwtc F LE_krypton ustar];
   
   %add in standard deviation calculations
   statsOut.std   = sqrt(statsOut.var);
   
   %calculate misc variables:
   %2D windspeed
   statsOut.misc(:,5) = (statsOut.means(:,1).^2 + statsOut.means(:,2).^2).^0.5;
   %3D windspeed
   statsOut.misc(:,6) = (statsOut.means(:,1).^2 + statsOut.means(:,2).^2 + statsOut.means(:,3).^2).^0.5;
   %wind direction
   direction   =   fr_Sonic_wind_direction(statsOut.means(:,1:2)','GillR3')+5;
   statsOut.misc(:,10) = rem(direction,360);
   
   switch i
   case 1; statsar = statsOut;
   case 2; statsbr = statsOut;
   end
   clear statsOut;
end


