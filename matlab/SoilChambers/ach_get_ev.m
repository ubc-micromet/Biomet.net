function [evOut] = ach_get_ev(slopeData,HH_climate_stats,Time_vector_HH_HH,c,Stats);
%[evOut] = ach_get_ev(slopeData,HH_climate_stats,Time_vector_HH_HH,c,Stats)
%
%Function that computes daily effective volume for automated respiration chamber systems
%Called within: ach_HH_flux_stats
%
%Input varibales:    SiteFlag
%                    slopeData
%                    HH_climate_stats
%                    Time_vector_HH_HH
%                    c
%                    Stats (from eddy covariance output) 
%
%Output variables: output structure evOut that contains all the information about effective volume stats     
%
%(c) dgg                
%Created:  Nov 26, 2003
%Revision: Nov 30, 2005
%
% Nov 30, 2005
%   - changed the way air temperature is used in the program to account for MFC
% Aug 29, 2005
%   - reformated the text. (Z)
%   - remove SiteID parameter. The function is now site independent
warning off;
R = 8.3144; %in J mol-1 K-1 or Pa m3 mol-1 K-1

%get gas concentration during gas injection
cCal = c.chamber.effectiveVolGas; 
cCal = cCal .* c.chamber.GasCorrFactor;
%cCal = cCalTmp .* 10^6; %in umol mol-1           

%index effective volume calibration period of flux data and store results in temporary matrix evData
tvSlopeData = datevec(slopeData(:,1));
if c.chamber.evCalHour+1 == 24
    endEvCal = 0;
else
    endEvCal = c.chamber.evCalHour+1;
end

evSlopeInd  = find((tvSlopeData(:,4) == c.chamber.evCalHour & tvSlopeData(:,5) == 30) | ...
                   (tvSlopeData(:,4) == endEvCal & tvSlopeData(:,5) == 0));        
evData = slopeData(evSlopeInd,:);

%index effective volume calibration period of climate data
tvHHData    = datevec(Time_vector_HH_HH);
evClimateInd = find((tvHHData(:,4) == c.chamber.evCalHour & tvHHData(:,5) == 30) | ...
                    (tvHHData(:,4) == endEvCal & tvHHData(:,5) == 0));    

%get barometric pressure data from eddy covariance output
pBar = Stats.pBarTmp;
tv   = Stats.tvTmp;
[Int,a,b]  = intersect(fr_round_hhour(Time_vector_HH_HH),fr_round_hhour(tv),'tv'); 
pBar = mean(pBar(b(evClimateInd)));
pBar = pBar .* 1000; %in pascals

if isnan(pBar)
	pBar = 94500;
end

for ch = 1:c.chamber.chNbr

	%get indexes for each chamber
	chInd = ch+(ch-1):ch+(ch-1)+1;
	
	%get air temperature from HH_climate_stats data
	airT = mean(HH_climate_stats.temp_air(evClimateInd,ch));
    % In case the measurement is missing (NaN) use the mean of all "good" measurements
    if isnan(airT)
        airTTemp = HH_climate_stats.temp_air(evClimateInd,:);
        airT = mean(airTTemp(~isnan(airTTemp)));
    end 
	
	%calculate daily effective volume for each chamber
  	airDensity   = pBar ./ (R .* (airT + 273.15) .* (1 + (evData(chInd(1),6)./1000)));   %density of dry air in the chamber (mol m-3)
	massFlowRate = (evData(chInd(2),5) ./ 60) .* (101.3e3 ./ (R * 273.15));              %mass flow rate at STP during gas injection (umol s-1) 
    injRate      = massFlowRate .* cCal; 											     %gas injection rate in the chamber (umol CO2 s-1)
	evTmp        = injRate ./ (airDensity .* (evData(chInd(2),2) - evData(chInd(1),2))); %effective volume (m3)

    %The MASS flow rate is derived from the VOLUME flow rate as outputed
    %from the mass flow controler. Since the VOLUME flow rate is given in
    %sccm (STANDARD cubic centimeter per minute), we have to calculate the MASS
    %flow rate at STP (STANDARD pressure and temperature), i.e. at 0C (273.15K) 
    %and 101.3 kPa (see mass flow controller manual).
    
	%create extended matrix (48 hhours) for effective volume
    ev(1:48,ch) = evTmp; 
	
	%store results in output structure evOut
	evOut.flowRate(:,ch) = evData(chInd,5);
	evOut.dcdt(:,ch) = evData(chInd,2); 
	evOut.r2(:,ch)   = evData(chInd,3);
	evOut.se(:,ch)   = evData(chInd,4);
	evOut.ev(:,ch)   = ev(:,ch);
	
end
