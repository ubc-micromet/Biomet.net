function [HH_flux_stats] = ach_HH_flux_stats(SiteFlag,startDate,Time_vector_HF,Time_vector_HH_HH,...
                                             HH_climate_stats,data_HF_reordered,co2_ppm,h2o_mmol,...
                                             c,Stats,recalc);
%Function that computes half-hourly flux stats for automated respiration chamber systems
%Called within: ach_calc - Site independent
%
%[HH_flux_stats] = ach_HH_flux_stats(SiteFlag,Time_vector_HF,Time_vector_HH_HH,...
%                                    HH_climate_stats,data_HF_reordered,co2_ppm,...
%                                    c,Stats);
%
%Input variables:    SiteFlag
%                    Time_vector_HF
%                    Time_vector_HH_HH
%                    HH_climate_stats
%                    data_HF_reordered
%                    co2_ppm (calibrated)
%					    h2o_mmol
%                    c
%                    Stats (from eddy covariance output or database)
%						 recalc
%
%Output varibales:   output structure HH_flux_stats that contains all the information about flux and
%                    effective volume stats
%
%
%(c) dgg                
%Created:  Nov 26, 2003
%Revision: lots...
warning off;

%define start and end of day
sd = floor(startDate) + datenum(0,0,0,0,0,1);
if c.chamber.systemType == 1 
	ed = floor(startDate) + datenum(0,0,0,23,55,1);
elseif c.chamber.systemType == 2 
	ed = floor(startDate) + datenum(0,0,0,23,57,31);
end

slopeInc = datenum(0,0,0,0,0,c.chamber.slopeLength);         %length of slope (one chamber measurement)

%process each slope from high frequency co2 data and store results in temporary matrix slopeData.
%Effluxes and effectives volumes are calculated with 2 different slope lengths. 1 = short slope (1 minute, 
%standard for each site) and 2 = long slope (full slope length, system dependent).
for slopeCalc = 1:2 

k = 0;
for slopeTime = sd:slopeInc:ed

   k = k + 1;
   j = (k-1)/c.chamber.chNbr;
   j = floor(j);
   i = k-(j*c.chamber.chNbr);

   %get start and end period for each slope    
	if slopeCalc == 1	%short slope
   		slopeStart = c.chamber.slopeStartPeriod;
   		slopeEnd   = slopeStart + c.chamber.slopeEndPeriod;
	elseif slopeCalc == 2 %long slope	
   		slopeStart = c.chamber.slopeStartPeriod;
   		slopeEnd   = slopeStart + c.chamber.slopeLength - 50;	%remove 30 seconds at the end of the period
	end

   %calculate dCO2/dt for each slope
   slopeInd = find(Time_vector_HF >= (slopeTime + datenum(0,0,0,0,0,slopeStart))...
      & Time_vector_HF <= (slopeTime + datenum(0,0,0,0,0,slopeEnd)));

   if ~isempty('slopeInd') & length(slopeInd) == ((slopeEnd-slopeStart)./5)

      regTv      = 1:length(slopeInd);
      regTv      = regTv(:)*5;
      regCO2     = co2_ppm(slopeInd);
           
      [p,r2,sigma,s,fval,regStats] = polyfit1(regTv,regCO2,1);

      %store results of regression
      slopeData(k,1) = ceil(slopeTime*48)/48;    %nearest (end of) half-hour
      slopeData(k,2) = p(1);                     %dcdt in umol CO2 mol-1 s-1 (ppm s-1)
      slopeData(k,3) = r2;                       %rsquare
      slopeData(k,4) = sigma;                    %standard error of the regression

      %calculate mean MFC flow rate and water vapor mixing ratio for each slope
      flowRateTmp    = data_HF_reordered(slopeInd,11); 
      flowRate       = mean(flowRateTmp);
	   waterVaporTmp  = h2o_mmol(slopeInd);
      waterVapor     = mean(waterVaporTmp);

      %transform flowRate data from mV to ccm for specific systems
      if upper(SiteFlag) == 'YF' & c.chamber.systemType == 2 | (upper(SiteFlag) == 'BS' & c.chamber.systemType == 2)...
              | (upper(SiteFlag) == 'PA' & c.chamber.systemType == 2)
         flowRate = flowRate/250;
      end

      %store results
      slopeData(k,5) = flowRate;                 %flow rate (ml min-1 or cm3 min-1)
      slopeData(k,6) = waterVapor;               %mean water wapor mixing ratio in mmol H20 mol dry air-1

   else
      slopeData(k,1) = ceil(slopeTime*48)/48;
      slopeData(k,2) = NaN;
      slopeData(k,3) = NaN;
      slopeData(k,4) = NaN;
      slopeData(k,5) = NaN;
      slopeData(k,6) = NaN;

   end

end

	%separate matrices for short and long slopes
	if slopeCalc == 1
		slopeDataShort = slopeData(:,:);
	else
		slopeDataLong = slopeData(:,:);
	end

	clear slopeData;

end

%calculate daily effective volume for each chamber for two slope lengths
[evOutShort] = ach_get_ev(SiteFlag,slopeDataShort,HH_climate_stats,Time_vector_HH_HH,c,Stats,recalc);
[evOutLong]  = ach_get_ev(SiteFlag,slopeDataLong,HH_climate_stats,Time_vector_HH_HH,c,Stats,recalc);

%calculate half-hourly fluxes for each chamber for two slope lengths
[fluxOutShort] = ach_get_flux(SiteFlag,slopeDataShort,evOutShort,HH_climate_stats,Time_vector_HH_HH,c,Stats,recalc);
[fluxOutLong]  = ach_get_flux(SiteFlag,slopeDataLong,evOutLong,HH_climate_stats,Time_vector_HH_HH,c,Stats,recalc);

%store results in output structure HH_flux_stats
HH_flux_stats.evOutShort = evOutShort;
HH_flux_stats.evOutLong = evOutLong;
HH_flux_stats.fluxOutShort = fluxOutShort;
HH_flux_stats.fluxOutLong = fluxOutLong;


