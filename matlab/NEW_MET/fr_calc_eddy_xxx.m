function Eddy_results = fr_calc_eddy(Eddy_HF_data_IN, Eddy_delays, RotationType, BarometricP, Krypton, Tair)
% fr_calc_eddy  - calculation of eddy correlation values from raw data for ONE data period (usually 1/2 hour)
%                 
%=================================================================================
%
%   Inputs:
%       Eddy_HF_data_IN -  high frequency data in engineering units
%                          Matrix has the following columns:
%                           - U V W T CO2 H2O TC1 TC2 Aux1 Aux2 ... AuxN
%                          where Aux1..N are auxilary SCALAR inputs (like Krypton)
%       Eddy_delays     - a vector of delays for each channel (in units of samples)
%                         (default a vector of zeros - no delays)
%       RotationType    - a character: 'N' for Natural or 'C' for canopy rotation
%       BarometricP     - the value for barometric pressure (the mean for this hhour)
%                         (default 94.5kPa - good for BERMS)
%       Krypton         - krypton channel number (one of the AUX inputs). Default is 0
%                         which means that there isn't any krypton measurements
%       Tair            - air temperature (hhour mean). Default is the mean Sonic temp.
%
%
% References: Stull, R.B., 1995.  Meteorology Today for Scientists and Engineers, 
%                 West Publ. Co.
%             Stull, R.B., 1988.  Boundary Layer Meteorology, Kluwer Academic Publ.
%             Wallace and Hobbs(1977) Atmospheric Science - An Introductory Survey,
%                 Academic Press Inc.
%=================================================================================
%
% (c) Zoran Nesic               File created:       Jun  4, 2000
%                               Last modification:  Sept 27, 2001
%

%       -   The Eddy_results structure has the
%           following components:
%               Stats.BeforeRot.AvgMinMax
%                              .Cov.LinDtr
%                                  .AvgDtr
%                    .AfterRot.AvgMinMax
%                             .Cov.LinDtr
%                                 .AvgDtr
%                    .Fluxes.LinDtr ->|
%                           .AvgDtr ->|->
%                                         [ 1. LELicor
%                                           2. SensibleSonic
%                                           3. SensibleTc1
%                                           4. SensibleTc2
%                                           5. Fc
%                                           6. LEKrypton 
%                                           7. BowenRatioLICOR
%                                           8. WaterUseEfficiency
%                                           9. Ustar
%                                          10. Penergy
%                                          11. HRcoeff
%                                          12. BowenRatioKrypton  ]
%                    .Angles.LinDtr->|
%                           .AvgDtr->|
%                                    |-> [  1. eta
%                                           2. theta
%                                           3. beta  ]
%
%
% Revisions: 04.05.01 E.Humphreys - added fr_rotatc as an option, added in 
%            26.09.01 E.Humphreys - increased precision on constants, added documentation, references



% read in CONSTANTS
UBC_biomet_constants;


% INPUT parameter defaults

if exist('RotationType') ~= 1 | isempty(RotationType)
    RotationType = 'N';                             % default rotation type is 'natural'
end 
if exist('BarometricP') ~= 1 | isempty(BarometricP) | BarometricP < 89 | BarometricP > 105 
     BarometricP = 94.5;                            % check if the pressure makes sense
end                                                 % default pressure is 94.5kPa
if exist('Krypton') ~= 1 | isempty(Krypton)
    Krypton = 0;                                    % default Krypton channel is 0 (no Krypton measurements)
end 
if exist('Tair') ~= 1 
    Tair = [];                                      % if Tair is empty Sonic temp. will be used
end 


[Eddy_results.DataLen,m]  = size(Eddy_HF_data_IN);  % save the number of data points
                                                    % in the original data set
if exist('Eddy_delays') ~= 1 | isempty(Eddy_delays)
    Eddy_delays = zeros(1,m);
end 

Eddy_HF_data            = fr_shift(Eddy_HF_data_IN, ...
                                     Eddy_delays);  % remove the delay times from Eddy_HF_data_IN
[n,nVariables]          = size(Eddy_HF_data);



%----------------------------------------------------------------------
%             Basic statistics before rotation
%                (means, max, min, and std)
%----------------------------------------------------------------------

Eddy_results.BeforeRot.AvgMinMax ...
                        = zeros(4,m);               % reserve the storage space

Eddy_results.BeforeRot.AvgMinMax(1,:) ...
                        = mean(Eddy_HF_data);       % mean
Eddy_results.BeforeRot.AvgMinMax(2,:) ...
                        = min(Eddy_HF_data);        % min
Eddy_results.BeforeRot.AvgMinMax(3,:) ...
                        = max(Eddy_HF_data);        % max
Eddy_results.BeforeRot.AvgMinMax(4,:) ...
                        = std(Eddy_HF_data);        % std

detrendVal              = detrend(Eddy_HF_data);    % linear detrending
Eddy_results.BeforeRot.Cov.LinDtr ...
                        = cov(detrendVal);

detrendVal              = detrend(Eddy_HF_data,0);  % block-average detrending 
Eddy_results.BeforeRot.Cov.AvgDtr ...
                        = cov(detrendVal);



%----------------------------------------------------------------------
%                   Rotation
%----------------------------------------------------------------------

Eddy_results.AfterRot.Cov   = [];                            % init. a field
Eddy_results.Angles         = [];                            % init. a field

for detrendType = [{'AvgDtr'},{'LinDtr'}]                    % do calculations for both LinDtr and AvgDtr
    % --- using line-detrended data ---
    if strcmp(upper(RotationType),'N') | strcmp(upper(RotationType),'THREE')
        [meansSr,statsSr,angles] = fr_rotatn( ...
           Eddy_results.BeforeRot.AvgMinMax(1,1:3),...
           getfield(Eddy_results.BeforeRot.Cov,char(detrendType)));% perform rotation
    elseif strcmp(upper(RotationType),'C') | strcmp(upper(RotationType),'TWO')
        [meansSr,statsSr,angles] = fr_rotatc( ...
           Eddy_results.BeforeRot.AvgMinMax(1,1:3),...
           getfield(Eddy_results.BeforeRot.Cov,char(detrendType)));% perform rotation
    elseif strcmp(upper(RotationType),'ONE')
        [meansSr,statsSr,angles] = fr_rotat_one( ...
           Eddy_results.BeforeRot.AvgMinMax(1,1:3),...
           getfield(Eddy_results.BeforeRot.Cov,char(detrendType)));% perform rotation
    else
       disp('This rotation-type is unsupported'); 
    end 
    Eddy_results.AfterRot.AvgMinMax         = Eddy_results.BeforeRot.AvgMinMax;
    Eddy_results.AfterRot.AvgMinMax(1,1:3)  = meansSr;          % change only vector mean values
    Eddy_results.AfterRot.Cov               = setfield(Eddy_results.AfterRot.Cov,...
                                                    char(detrendType), ...
                                                    statsSr);   % and all the covariances
    Eddy_results.Angles                     = setfield(Eddy_results.Angles,...
                                                    char(detrendType),...
                                                    angles);    % store the rotation angles
end


%-----------------------------------------------------------------------
%                   FLUX calculations
%-----------------------------------------------------------------------

% extract all the flux-calculation variables

% The air temperature is used for the air density calculations
% The old versions of Eddy flux calculations used to use the average temperatures
% measured by the sensors themself when Tair was needed (Tsonic for sonic H, Tc1 for Htc1...)
% This would introduce errors when comparing Sonic to a thermocouple sensible heat.
%
if isempty(Tair)                                            % this should be the "best" Tair temp.
    Tair    = Eddy_results.AfterRot.AvgMinMax(1,4) + ZeroK; % use Sonic if nothing else is available
else
    Tair    = Tair + ZeroK;                                 % convert to Kelvins
end
h2o_bar = Eddy_results.AfterRot.AvgMinMax(1,6);             % mmol / mol of dry air
WaterMoleFraction = h2o_bar/(1+h2o_bar/1000);               % get mmol/mol of wet air              


for rotation = [{'AfterRot'}, {'BeforeRot'}]
   
    tmpResults = getfield(Eddy_results, char(rotation), 'Cov');
      
    for detrendType = [{'AvgDtr'},{'LinDtr'}]                   % do calculations for both LinDtr and AvgDtr
        tmpCov = getfield(tmpResults,char(detrendType));% extract either LinDtr or AvgDtr covariance matrix
        uw      = tmpCov(1,3);                                  % covariance u^w
        vw      = tmpCov(2,3);                                  % covariance v^w   
        wT      = tmpCov(3,4);                                  % covariance w^T (sonic temp)
    
        %
        % Ustar calculations
        %
        Ustar   = ( uw.^2 + vw.^2 ) ^ 0.25;                         % Ustar
    
        %variables 
        rho_moist_air = rho_air_wet(Tair-ZeroK,[],BarometricP,WaterMoleFraction); % density of moist air
        L_v       = Latent_heat_vaporization(Tair-ZeroK)./1000;    % J/g latent heat of vaporization Stull (1988)             
        
        %
        % Sensible heat calculations
        %
        Cp_moist = spe_heat(WaterMoleFraction); %specific heat of moist air
        
        SensibleSonic  = wT * rho_moist_air * Cp_moist;             % Sensible heat (Sonic)

        if nVariables>6
            wTc1    = tmpCov(3,7);                                  % covariance w^Tc1 (first thermocouple)
            SensibleTc1    = wTc1 * rho_moist_air * Cp_moist;       % Sensible heat (Tc1)
        else
            SensibleTc1    = 0; 
        end 
        if nVariables>7
            wTc2    = tmpCov(3,8);                                  % covariance w^Tc2 (second thermocouple)
            SensibleTc2    = wTc2 * rho_moist_air * Cp_moist;       % Sensible heat (Tc2)
        else
            SensibleTc2    = 0; 
        end 
    

        if nVariables > 4
            wc      = tmpCov(3,5);                                  % covariance w^C
        else
            wc      = 0;                                            % if it doesn't exist set to 0
        end
        %
        % CO2 flux calculations
        %
        convC = BarometricP*1000/(R*Tair);       % convert umol co2/mol dry air -> umol co2/m3 dry air (refer to Pv = nRT)
        Fc    = wc * convC;                      % CO2 flux (umol m-2 s-1)
    
    
        %
        % P energy calculation
        %
        Penergy = -10.47 * wc;                                      % Penergy
    

        if nVariables > 5
            wh      = tmpCov(3,6);                                  % covariance w^h
            hh      = tmpCov(6,6);                                  % variance h^h
        else
            wh = 0;
            hh = 0;
        end
        %
        % Water-use efficiency
        %
        if wh == 0
            WaterUseEfficiency = 1e38;
        else
            WaterUseEfficiency = - wc / wh;                         % WaterUseEfficiency
        end
        %
        % Latent heat calculations
        %
        convH    = BarometricP*1000 / (Rv*Tair);                % convert mmol h2o/mol dry air -> g h2o/m3 (refer to Pv = nRT)
        wh_g     = wh * convH;                                  % convert m/s(mmol/mol) -> m/s(g/m^3)
        LELicor  = wh_g * L_v;                                  % LE LICOR
        mu       = Ma/Mw;                                       % ratio of the molecular weight of air to water

        if Krypton ~= 0                                         % if Krypton channel exists
            wkh2o   = tmpCov(3,Krypton);                        % covariance w^kh2o    
            hr      = tmpCov(8,Krypton);                        % covariance h^kh2o
            rr      = tmpCov(Krypton,Krypton);                  % variance kh2o^kh2o
        
            % Krypton WPL correction        
            Pa = 1e6 * BarometricP/ Rd/ Tair;
            sigma = h2o_bar*convH/Pa;
            wkh2o = (1 + mu*sigma)*(wkh2o + h2o_bar*convH/Tair*wT);
            tmpCov(3,Krypton) = wkh2o;                          % correct w^kh2o values
            tmpCov(Krypton,3) = wkh2o;                          % in the covariance matrix
            if strcmp(detrendType,'LinDtr')                     % store the corrected cov matrix if LinDtr
                Eddy_results.AfterRot.Cov = ...
                    setfield(Eddy_results.AfterRot.Cov, ...
                    char(detrendType),...
                    tmpCov);                                    
            end
      
            oxygen_corr = 2.542 * abs(c.KH2O_poly(1))/Tair*SensibleSonic;
            LEKrypton   = wkh2o * L_v + oxygen_corr;              % LE Krypton
        
            if hh == 0 | rr == 0
                HRcoeff = 1e38;
            else
                HRcoeff = hr / abs( hh * rr ) ^ 0.5;              % h-r correlation coeff
            end
        else
            HRcoeff = 1e38;
            LEKrypton = 0; 
        end
    
        %
        % Bowen ratio calculations
        %
        if LELicor == 0
            BowenRatioLICOR = 1e38;
        else
            BowenRatioLICOR = SensibleSonic / LELicor;              % BowenRation LICOR
        end

        if LEKrypton == 0
            BowenRatioKrypton = 1e38;
        else
            BowenRatioKrypton = SensibleSonic / LEKrypton;          % BowenRation Krypton
        end


        %-----------------------------------------------------------------------
        % Store fluxes in the output array
        %-----------------------------------------------------------------------
    
        FluxesX = [ LELicor ...
                    SensibleSonic ...
                    SensibleTc1 ...
                    SensibleTc2 ...
                    Fc ...
                    LEKrypton ...
                    BowenRatioLICOR ...
                    WaterUseEfficiency ...
                    Ustar ...
                    Penergy ...
                    HRcoeff ...
                    BowenRatioKrypton  ];
        if ~isfield(Eddy_results,'Fluxes')
            Eddy_results.Fluxes = [];                   % init the field if needed
        end
        Eddy_results.Fluxes = ...
                setfield(Eddy_results.Fluxes, ...
                char(detrendType),...
                char(rotation),...
                FluxesX);                                      
             
    end % of detrendType
end