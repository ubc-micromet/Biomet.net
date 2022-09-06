function [statsar, statsbr] = oy_calc_eddy(stats);

%program to calculate open-path irga co2 and water vapour fluxes
%
% outputs: statsar - stats after rotation
%          statsbr - stats before rotation
%
% E.Humphreys Aug 29, 2000
%



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
   h2o_mmol_mol = statsOut.means(:,8);
   h2o_mixratio = h2o_mmol_mol./(1-h2o_mmol_mol./1000);
   
   
   % 28.96 g air/mol   (molecular weight for mean condition of air, Stull, 1995)
	% 18.02 g water/mol (molecular weight for water, Stull, 1995)
   mu     = 28.96/18.02;                     %ratio of molecular masses for dry air and water
   rho_a  = rho_air(statsOut.means(:,5)).*1000.*1000;        %mg/m3
   mg2umol= 10^6./1000./44;
   L_v    = Lv(statsOut.means(:,5))./1000;                   %J/g
   T      = statsOut.means(:,5) + 273.15;                    %K
   rho_v  = statsOut.means(:,8).*statsOut.Pbar(:,1).*1000./...
      (8.314.*(statsOut.means(:,5)+273)).*18./1000;          %g/m3
   rho_c  = statsOut.means(:,7).*statsOut.Pbar(:,1)./...
      (8.314.*(statsOut.means(:,5)+273)).*44;                %mg/m3
   sigma  = rho_v.*1000./rho_a;
   
   %sensible heat flux
   rho_a2      = statsOut.Pbar(:,1).*...
      (29.*(1-h2o_mixratio./1000)+18.*h2o_mixratio./1000).*...
      1000./T./(8.314.*1.004);
   H_cor       = 0.51.*T.*statsOut.scalcovsw(:,5).*(T*0.622./(2165.*statsOut.Pbar(:,1)));
                  %where w_h2o is now in m/s * g water vapour/g moist air
   
   H_sonic     = (statsOut.scalcovsw(:,2)-H_cor).*rho_a2; %corrected W/m2
   H_fwtc      =  statsOut.scalcovsw(:,3).*rho_a2; %corrected W/m2

   
   %co2 flux correction terms for sensible heat fluxes and water vapour mg/m2/s
   F_cor_terms = rho_c.*(mu.*statsOut.scalcovsw(:,5).*1000./rho_a+...
      (1+mu.*(sigma)).*statsOut.scalcovsw(:,2)./T);  
   
   F           = statsOut.scalcovsw(:,4) + F_cor_terms;    %corrected mg/m2/s
   F           = F.*mg2umol;                               %corrected umol/m2/s
   
   %h2o flux correction for sensible heat fluxes and water vapour mg/m2/s
   LE_licor    = (1+mu.*(sigma)).*...
      (statsOut.scalcovsw(:,5) + statsOut.scalcovsw(:,2).*rho_v./T);              
   %corrected g/m2/s
   
   LE_licor    = L_v.*LE_licor;                             %corrected W/m2
   
   %
   % Krypton WPL correction
   %
   wkh2o       = (1 + mu.*sigma).*...
      (statsOut.scalcovsw(:,1) + statsOut.scalcovsw(:,2).*rho_v./T);
   oxygen_corr = 2.542.*abs(-6.3981)./T.*H_sonic;
   LE_krypton   = L_v.*wkh2o + oxygen_corr;                  %corrected W/m2
   
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
   direction   =   fr_Sonic_wind_direction([statsOut.means(:,1) -statsOut.means(:,2)]','CSAT3')+100;
   statsOut.misc(:,10) = rem(direction,360);
   
   switch i
   case 1; statsar = statsOut;
   case 2; statsbr = statsOut;
   end
   clear statsOut;
end


