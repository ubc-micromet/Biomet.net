function [HH_flux_stats] = ach_HH_flux_stats(startDate,Time_vector_HF,Time_vector_HH_HH,...
    HH_climate_stats,data_HF_reordered,co2_ppm,h2o_mmol,c,Stats);
%Function that computes half-hourly flux stats for automated respiration chamber systems
%Called within: ach_calc - Site independent
%
%[HH_flux_stats] = ach_HH_flux_stats(startDate,Time_vector_HF,Time_vector_HH_HH,...
%     HH_climate_stats,data_HF_reordered,co2_ppm,h2o_mmol,c,Stats);
%
%Input variables:    SiteFlag
%                    Time_vector_HF
%                    Time_vector_HH_HH
%                    HH_climate_stats
%                    data_HF_reordered
%                    co2_ppm (calibrated)
%                    h2o_mmol
%                    c
%                    Stats (from eddy covariance output or database)
%
%Output varibales:   output structure HH_flux_stats that contains all the information about flux and
%                    effective volume stats
%
%(c) dgg                
%Created:  Nov 26, 2003
%Revision: Mar 28, 2006

% Revisions:
%  March 28, 2006 (David)
%       - added initial CO2 concentration calculation for each slope
%  Nov 29, 2005 (Z&David)
%       - changed the RegTv calculation (see below)
%  Aug 29, 2005  (Making ACS programs site independent - Zoran)
%       - assumed that start of data and end of data are beginning and the
%       end of the day.
warning off;

%define start and end of day
sd = floor(startDate) + datenum(0,0,0,0,0,1);
ed = sd + 1 - datenum(0,0,0,0,0,1);

slopeInc = datenum(0,0,0,0,0,c.chamber.slopeLength);         %length of slope (one chamber measurement)

%process each slope from high frequency co2 data and store results in temporary matrix slopeData.
%Effluxes and effectives volumes are calculated with 2 different slope lengths. 1 = short slope (1 minute, 
%standard for each site) and 2 = long slope (full slope length, system dependent - see inifile).
for slopeCalc = 1:2 
    
    k = 0;
    for slopeTime = sd:slopeInc:ed
        
        k = k + 1;
        j = (k-1)/c.chamber.chNbr;
        j = floor(j);
        i = k-(j*c.chamber.chNbr);
        
        %get start and end period for each slope    
        slopeStart = c.chamber.slopeStartPeriod;
        if slopeCalc == 1	  %short slope
            slopeEnd   = c.chamber.slopeEndPeriodShort;
        elseif slopeCalc == 2 %long slope	
            slopeEnd   = c.chamber.slopeEndPeriodLong;	
        end
        
        %calculate dCO2/dt for each slope
        slopeInd = find(Time_vector_HF >= (slopeTime + datenum(0,0,0,0,0,slopeStart))...
            & Time_vector_HF <= (slopeTime + datenum(0,0,0,0,0,slopeEnd)));
        
%        plot(Time_vector_HF,co2_ppm);hold on;plot(Time_vector_HF(slopeInd),co2_ppm(slopeInd),'ro');axis([Time_vector_HF(1) Time_vector_HF(end) 300 700]);zoom on;
        
       if ~isempty('slopeInd') & length(slopeInd) >= 10 %minimum of 10 data points to perform the regression
            
            [y,m,d,h,m,regTv]=datevec(Time_vector_HF(slopeInd)-Time_vector_HF(slopeInd(1)));
            regTv = round(m*60+regTv);          % if time changes in steps less than a second this line needs to be removed (Z. Aug 29, 2005)
            regCO2     = co2_ppm(slopeInd);
            
            [p,r2,sigma,s,fval,regStats] = polyfit1(regTv,regCO2,1);
            
            %store results of regression
            slopeData(k,1) = ceil(slopeTime*48)/48;    %nearest (end of) half-hour
            slopeData(k,2) = p(1);                     %dcdt in umol CO2 mol-1 s-1 (ppm s-1)
            slopeData(k,3) = r2;                       %rsquare
            slopeData(k,4) = sigma;                    %standard error of the regression
            
            %calculate mean MFC flow rate, water vapor mixing ratio and initial CO2 concentration for each slope
            flowRateTmp    = data_HF_reordered(slopeInd,c.chamber.MFC.ChannelNum); 
            flowRate       = mean(flowRateTmp(~isnan(flowRateTmp)));
            waterVaporTmp  = h2o_mmol(slopeInd);
            waterVapor     = mean(waterVaporTmp(~isnan(waterVaporTmp)));
            initialCO2     = mean(regCO2(~isnan(regCO2(1:3)))); %average 3 first samples of the slope
            
            %transform flowRate data from mV to ccm for specific systems
            flowRate = flowRate * c.chamber.MFC.Gain;
            
            %store results
            slopeData(k,5) = flowRate;                 %flow rate (ml min-1 or cm3 min-1)
            slopeData(k,6) = waterVapor;               %mean water wapor mixing ratio in mmol H20 mol dry air-1
            slopeData(k,7) = initialCO2;               %initial CO2 concentration in umol CO2 mol dry air-1
            
        else
            slopeData(k,1) = ceil(slopeTime*48)/48;
            slopeData(k,2) = NaN;
            slopeData(k,3) = NaN;
            slopeData(k,4) = NaN;
            slopeData(k,5) = NaN;
            slopeData(k,6) = NaN;
            slopeData(k,7) = NaN;
            
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
[evOutShort] = ach_get_ev(slopeDataShort,HH_climate_stats,Time_vector_HH_HH,c,Stats);
[evOutLong]  = ach_get_ev(slopeDataLong,HH_climate_stats,Time_vector_HH_HH,c,Stats);

%calculate half-hourly fluxes for each chamber for two slope lengths
[fluxOutShort] = ach_get_flux(slopeDataShort,evOutShort,HH_climate_stats,Time_vector_HH_HH,c,Stats);
[fluxOutLong]  = ach_get_flux(slopeDataLong,evOutLong,HH_climate_stats,Time_vector_HH_HH,c,Stats);

%store results in output structure HH_flux_stats
HH_flux_stats.evOutShort = evOutShort;
HH_flux_stats.evOutLong = evOutLong;
HH_flux_stats.fluxOutShort = fluxOutShort;
HH_flux_stats.fluxOutLong = fluxOutLong;


