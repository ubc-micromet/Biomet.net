function [HH_climate_stats,HH_diag_stats,Time_vector_HH_HH,bVol,cTCHTemp,pTCHTemp] = ach_HH_climate_stats(SiteFlag,...
    data_HH_reordered,data_HF_reordered,Time_vector_HH,Time_vector_HF,...
    co2_ppm_short,temperature,pressure,c);
% [HH_climate_stats,HH_diag_stats,Time_vector_HH_HH,bVol,cTCHTemp,pTCHTemp] = ach_HH_climate_stats(SiteFlag,...
%     data_HH_reordered,data_HF_reordered,Time_vector_HH,Time_vector_HF,...
%     co2_ppm_short,temperature,pressure,c);
%
%Function that computes half-hourly climate and diagnostic stats for automated respiration chamber systems
%Called within: ach_calc
%
%Input variables:    SiteFlag
%                    data_HH_reordered
%                    data_HF_reordered
%                    Time_vector_HH
%                    Time_vector_HF
%                    co2_ppm_short
%                    temperature
%                    pressure
%                    c
%
%Output variables:   output structures HH_climate_stats and HH_diag_stats that contains all the 
%                       information about chamber climate and diagnostic stats
%                    Time_vector_HH_HH (48x1)
%                    battery voltage (bVol)
%                    control TCH temperature (cTCHTemp)
%                    pump TCH temperature (pTCHTemp)
%
%
%(c) dgg                
%Created:  Nov 26, 2003
%Revision: Dec  1, 2005 
%
% Dec  1, 2005 
%   - removed all the site dependencies
% Sep 10, 2005 (Zoran)
%   - made corrections to enable usage of "Chan_misc_climate" entry in the
%   ini file generic.  If that field is present, the program will try to
%   compute all the lines
%   - changed the way bVol, cTCHTemp and pTCHTemp are calculated.  It's
%   possible now to have the channels defined outside of this program
%   therefore making it more site-independent.  All sites should get
%   entries: c.chamber.Chan_bVol, c.chamber.Chan_cTCHTemp,
%   c.chamber.Chan_pTCHTemp.
warning off;

%Create time vector with 48 hhours if CR10 is used (data was recorded every minute with that datalogger (1440 values))
if c.chamber.systemType == 1
    Time_vector_HH_HH = floor(Time_vector_HH*48+8/60*48/60/24)/48; 
    HH_ind_HH = find(diff(Time_vector_HH_HH)>0)+1;
    if HH_ind_HH(1) ~= 1
        HH_ind_HH = [1 ;HH_ind_HH(:)];
    end
    Time_vector_HH_HH = Time_vector_HH_HH(HH_ind_HH(2:end));
    numOfHHours_HH = length(Time_vector_HH_HH);
    for i = 1:numOfHHours_HH;        
        ind = HH_ind_HH(i):HH_ind_HH(i+1);             
        if ~isempty(ind)
           data_HH_reorderedNew(i,:) = mean(data_HH_reordered(ind,:));
        end
    end
    data_HH_reordered = data_HH_reorderedNew;
else
    Time_vector_HH_HH = Time_vector_HH;
end

%Get the matrix size
[nRows, mCol] = size(data_HH_reordered);

%Chamber air temperatures
if isfield(c.chamber.Air_Temp,'Chan_Measured') & ~isempty(c.chamber.Air_Temp.Chan_Measured)
    nTc = size(c.chamber.Air_Temp.Chan_Measured,2);
    HH_climate_stats.temp_air = NaN * ones(nRows,c.chamber.chNbr);
    for nHHour = 1:nRows
        tempOut = NaN * ones(c.chamber.chNbr,nTc);
        for chNum = 1: size(c.chamber.Air_Temp.Chan_Measured,1)
            sumTemp = 0;
            countTemp = 0;
            for tcNum = 1 : size(tempOut,2)
                if c.chamber.Air_Temp.Chan_Measured(chNum,tcNum) > 0
                    tempOut(chNum,tcNum) = data_HH_reordered(nHHour,c.chamber.Air_Temp.Chan_Measured(chNum,tcNum));
                end
                if ~isnan(tempOut(chNum,tcNum))
                    sumTemp = sumTemp + tempOut(chNum,tcNum);
                    countTemp = countTemp + 1;
                end
            end
            if countTemp > 0 
        	    HH_climate_stats.temp_air(nHHour,c.chamber.Air_Temp.Chan_Stored(chNum)) = sumTemp/countTemp;
            else
                HH_climate_stats.temp_air(nHHour,c.chamber.Air_Temp.Chan_Stored(chNum)) = NaN;
            end
        end
        HH_climate_stats.all_thermocouples(nHHour).temp_air = tempOut;
    end
    % Make all measurements that are = "missing data code", usually -99999, be NaNs
    HH_climate_stats.temp_air(find(HH_climate_stats.temp_air == c.chamber.codeMissingData)) = NaN;
end

%Chamber soil temperatures
if isfield(c.chamber.Soil_Temp,'Chan_Measured') & ~isempty(c.chamber.Soil_Temp.Chan_Measured)
    nTc = size(c.chamber.Soil_Temp.Chan_Measured,2);
    HH_climate_stats.temp_soil = NaN * ones(nRows,c.chamber.chNbr);
    for nHHour = 1:nRows
        tempOut = NaN * ones(c.chamber.chNbr,nTc);
        for chNum = 1: size(c.chamber.Soil_Temp.Chan_Measured,1)
            sumTemp = 0;
            countTemp = 0;
            for tcNum = 1 : size(tempOut,2)
                if c.chamber.Soil_Temp.Chan_Measured(chNum,tcNum) > 0
                    tempOut(chNum,tcNum) = data_HH_reordered(nHHour,c.chamber.Soil_Temp.Chan_Measured(chNum,tcNum));
                end
                if ~isnan(tempOut(chNum,tcNum))
                    sumTemp = sumTemp + tempOut(chNum,tcNum);
                    countTemp = countTemp + 1;
                end
            end
            if countTemp > 0 
        	    HH_climate_stats.temp_soil(nHHour,c.chamber.Soil_Temp.Chan_Stored(chNum)) = sumTemp/countTemp;
            else
                HH_climate_stats.temp_soil(nHHour,c.chamber.Soil_Temp.Chan_Stored(chNum)) = NaN;
            end
        end
        HH_climate_stats.all_thermocouples(nHHour).temp_soil = tempOut;
    end
    % Make all measurements that are = "missing data code", usually -99999, be NaNs
    HH_climate_stats.temp_soil(find(HH_climate_stats.temp_soil == c.chamber.codeMissingData)) = NaN;
end

%chamber PAR 
if isfield(c.chamber.PAR,'Chan_Measured') & ~isempty(c.chamber.PAR.Chan_Measured)
    HH_climate_stats.ppfd = NaN * ones(nRows,c.chamber.chNbr);
    HH_climate_stats.ppfd(:,c.chamber.PAR.Chan_Stored) = data_HH_reordered(:,c.chamber.PAR.Chan_Measured); %
    HH_climate_stats.ppfd(find(HH_climate_stats.ppfd == c.chamber.codeMissingData)) = NaN;
end

%chamber VWC 
if isfield(c.chamber.VWC,'Chan_Measured') & ~isempty(c.chamber.VWC.Chan_Measured)
    HH_climate_stats.vwc = NaN * ones(nRows,c.chamber.chNbr);
    HH_climate_stats.vwc(:,c.chamber.VWC.Chan_Stored) = data_HH_reordered(:,c.chamber.VWC.Chan_Measured); %
    HH_climate_stats.vwc(find(HH_climate_stats.vwc == c.chamber.codeMissingData)) = NaN;
end

%chamber misc temperatures 
if isfield(c.chamber.Misc_Temp,'Chan_Measured') & ~isempty(c.chamber.Misc_Temp.Chan_Measured)
    HH_climate_stats.temp_misc = NaN * ones(nRows,c.chamber.chNbr);
    HH_climate_stats.temp_misc(:,c.chamber.Misc_Temp.Chan_Stored) = data_HH_reordered(:,c.chamber.Misc_Temp.Chan_Measured); %
    HH_climate_stats.temp_misc(find(HH_climate_stats.temp_misc == c.chamber.codeMissingData)) = NaN;
end

%battery voltage
bVol = data_HH_reordered(:,c.chamber.Chan_bVol);         % AVG
%control TCH temperature
cTCHTemp = data_HH_reordered(:,c.chamber.Chan_cTCHTemp); % AVG
%pump TCH temperature
pTCHTemp = data_HH_reordered(:,c.chamber.Chan_pTCHTemp); % AVG

%process miscalenious chamber stuff (CO2 probes and such)
try
	if isfield(c.chamber,'Chan_misc_climate')
		tmp_clim = data_HH_reordered(:,c.chamber.Chan_misc_climate);
		for i = 1:length(c.chamber.Names_misc_climate)
            eval(['HH_climate_stats.misc.' char(c.chamber.Names_misc_climate(i)) ' = tmp_clim(:,i);']);
		end
    end
end
            
%compute diagnostic stats from licor HF measurements
Time_vector_HH_HF = floor(Time_vector_HF*48+8/60*48/60/24)/48;  

HH_ind_HF = find(diff(Time_vector_HH_HF)>0)+1;
if HH_ind_HF(1) ~= 1,
    HH_ind_HF = [1 ;HH_ind_HF(:)];
end

Time_vector_HH_HF = Time_vector_HH_HF(HH_ind_HF(2:end));
numOfHHours_HF = length(Time_vector_HH_HF);

co2 = NaN * ones(numOfHHours_HF,3); 
temp  = co2;
press = co2;
flow  = co2;

for i = 1:numOfHHours_HF;
    ind = HH_ind_HF(i):HH_ind_HF(i+1); 
    if ~isempty(ind) 
        HH_diag_stats.co2(i,1)   = mean(co2_ppm_short(ind));  				%store co2 ppm short avg
        HH_diag_stats.co2(i,2)   = max(co2_ppm_short(ind));
        HH_diag_stats.co2(i,3)   = min(co2_ppm_short(ind));
        HH_diag_stats.temp(i,1)  = mean(temperature(ind));    				%store optical bench temperature avg   
        HH_diag_stats.temp(i,2)  = max(temperature(ind));
        HH_diag_stats.temp(i,3)  = min(temperature(ind));
        HH_diag_stats.press(i,1) = mean(pressure(ind));       				%store licor pressure avg
        HH_diag_stats.press(i,2) = max(pressure(ind));
        HH_diag_stats.press(i,3) = min(pressure(ind));  
        HH_diag_stats.flow(i,1)  = mean(data_HF_reordered(ind,11));         %store MFC flow rate avg                   
        HH_diag_stats.flow(i,2)  = max(data_HF_reordered(ind,11));                   
        HH_diag_stats.flow(i,3)  = min(data_HF_reordered(ind,11));                   
    end                
end
