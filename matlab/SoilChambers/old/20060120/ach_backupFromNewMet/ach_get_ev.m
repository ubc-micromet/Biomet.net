function [evOut] = ach_get_ev(SiteFlag,slopeData,HH_climate_stats,Time_vector_HH_HH,c,Stats,recalc);
%[evOut] = ach_get_ev(slopeData,HH_climate_stats,Time_vector_HH_HH,c,Stats,recalc)
%
%Input varibales:    SiteFlag
%                    slopeData
%                    HH_climate_stats
%                    Time_vector_HH_HH
%                    c
%                    Stats (from eddy covariance output) 
%						 recalc
%
%Output variables: output structure evOut that contains all the information about effective volume stats     
%
%Function that computes daily effective volume for automated respiration chamber systems
%Called within: ach_calc_flux
%
%(c) dgg                
%Created:  Nov 26, 2003
%Revision: none
warning off;
R = 8.3144; %in J mol-1 K-1 or Pa m3 mol-1 K-1

%get gas concentration during gas injection
cCal = c.chamber.effectiveVolGas; %in %
cCal = cCal .* 10^6; %in umol mol-1           
cCal = cCal .* 0.97; %in umol mol-1, 0.97 is the correction factor for 10% CO2 - see MFC manual

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
if recalc == 1
	pBar = Stats.pBarTmp;
	tv   = Stats.tvTmp;
	[Int,a,b]  = intersect(fr_round_hhour(Time_vector_HH_HH),fr_round_hhour(tv),'tv'); 
	pBar = mean(pBar(b(evClimateInd)));
	pBar = pBar .* 1000; %in pascals
else
	pBar = squeeze(Stats.BeforeRot.AvgMinMax(1,20,:));
	pBar = mean(pBar(evClimateInd));
	pBar = pBar .* 1000; %in pascals
end

if isnan(pBar)
	pBar = 94500;
end

for ch = 1:c.chamber.chNbr

%get indexes for each chamber
chInd = ch+(ch-1):ch+(ch-1)+1;

%get air temperature from HH_climate_stats data
airT = mean(HH_climate_stats.temp_air(evClimateInd,ch));

%calculate daily effective volume for each chamber
Da = pBar ./ (R .* (airT + 273.15) .* (1 + (evData(chInd(1),6)./1000))); %density of dry air in mol m-3
flowRate = (evData(chInd(2),5) ./ 60) .* 10^-6; 					 		 %flow rate during gas injection in m3 s-1 
I = Da .* flowRate .* cCal; 											 		 %injection rate in umol CO2 s-1
evTmp = I ./ (Da .* (evData(chInd(2),2) - evData(chInd(1),2))); 		 %effective volume in m3

%create extended matrix (48 hhours) for effective volume
for j = 1:48
   ev(j,ch) = evTmp; 
end

%store results in output structure evOut
evOut.flowRate(:,ch) = evData(chInd,5);
evOut.dcdt(:,ch) = evData(chInd,2); 
evOut.r2(:,ch)   = evData(chInd,3);
evOut.se(:,ch)   = evData(chInd,4);
evOut.ev(:,ch)   = ev(:,ch);

end
