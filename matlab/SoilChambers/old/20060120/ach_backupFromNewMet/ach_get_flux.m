function [fluxOut] = ach_get_flux(SiteFlag,slopeData,evOut,HH_climate_stats,Time_vector_HH_HH,c,Stats,recalc);
%[fluxOut] = ach_get_flux(slopeData,evOut,HH_climate_stats,Time_vector_HH_HH,c,Stats,recalc)
%
%Input varibales:    SiteFlag
%                    slopeData
%                    evOut
%                    HH_climate_stats
%                    Time_vector_HH_HH
%                    c
%                    Stats (from eddy covariance output) 
%						 recalc
%
%Output variables: output structure fluxOut that contains all the information about flux stats     
%
%Function that computes half-hourly fluxes for automated respiration chamber systems
%Called within: ach_calc_flux
%
%(c) dgg                
%Created:  Nov 26, 2003
%Revision: none
warning off;
R = 8.3144; %in J mol-1 K-1 or Pa m3 mol-1 K-1

%get barometric pressure data from eddy covariance output 
if recalc == 1
	pBarR = Stats.pBarTmp;
	tvR   = Stats.tvTmp;
	[Int,a,b]  = intersect(fr_round_hhour(Time_vector_HH_HH),fr_round_hhour(tvR),'tv'); 
	pBarTmp = pBarR(b);
	pBarTmp = pBarTmp .* 1000; %in pascals
else
	pBarTmp = squeeze(Stats.BeforeRot.AvgMinMax(1,20,:));
	pBarTmp = pBarTmp .* 1000; %in pascals
end

pBar = NaN .* zeros(length(pBarTmp),c.chamber.chNbr); 
for j = 1:c.chamber.chNbr
  	pBar(:,j) = pBarTmp(:,1); 
end

if isnan(pBar)
	pBar = 94500;
end

%reshape slopeData matrix to account for number of chambers
for ch = 1:c.chamber.chNbr
   chInd = ch:c.chamber.chNbr:length(slopeData);
   fluxOut.dcdt(:,ch) = slopeData(chInd,2);
   fluxOut.r2(:,ch)   = slopeData(chInd,3);
   fluxOut.se(:,ch)   = slopeData(chInd,4);
   fluxOut.wv(:,ch)   = slopeData(chInd,6);
end

%get air temperature from HH_climate_stats data
airT = HH_climate_stats.temp_air(:,:);

%create effective volume temporary matrix
ev = evOut.ev;

%create soil or bole area temporary matrix for SOA
if SiteFlag == 'PA' & c.chamber.systemType == 1
   aS = c.chamber.area;
   aB = c.chamber.areaBole;
   areaTmp = [aS aS aB aS aS aS];
   area = NaN .* zeros(length(fluxOut.dcdt),c.chamber.chNbr);
   for j = 1:48
      area(j,1:c.chamber.chNbr) = areaTmp(:,:); 
   end   
elseif SiteFlag == 'PA' & c.chamber.systemType == 2
   aS = c.chamber.area;
   aB = c.chamber.areaBole;
   areaTmp = [aB aS aS aS aS aS aS aS aS aS aS aS];
   area = NaN .* zeros(length(fluxOut.dcdt),c.chamber.chNbr);
   for j = 1:48
      area(j,1:c.chamber.chNbr) = areaTmp(:,:); 
   end   
else
   area = c.chamber.area;
end

%create soil area temporary matrix for YF
if SiteFlag == 'YF' & c.chamber.systemType == 2
   aS = c.chamber.area;
   areaTmp = [aS aS aS aS aS aS aS aS aS aS aS aS];
   area = NaN .* zeros(length(fluxOut.dcdt),c.chamber.chNbr);
   for j = 1:48
      area(j,1:c.chamber.chNbr) = areaTmp(:,:); 
   end   
else
   area = c.chamber.area;
end


%calculate fluxes
fluxOut.flux(:,:) = pBar .* ev .* fluxOut.dcdt(:,:) ./ ...
	(R .* (airT(:,:) + 273.15) .* area .* (1 + (fluxOut.wv(:,:)./1000)));

%remove bad fluxes (licor and effective volume calibrations and sample outside air periods)
tvHHData = datevec(Time_vector_HH_HH);

if c.chamber.evCalHour+1 == 24
    endEvCal = 0;
else
    endEvCal = c.chamber.evCalHour+1;
end

if c.chamber.calHour+1 == 24
    endCal = 0;
else
    endCal = c.chamber.calHour+1;
end

if (c.chamber.systemType == 1) | (upper(SiteFlag) == 'JP' & c.chamber.systemType == 2)
   badSlopeInd = find((tvHHData(:,4) == c.chamber.evCalHour & tvHHData(:,5) == 0)  | ...
                      (tvHHData(:,4) == c.chamber.evCalHour & tvHHData(:,5) == 30) | ...
                      (tvHHData(:,4) == c.chamber.evCalHour2 & tvHHData(:,5) == 0) | ...
                      (tvHHData(:,4) == c.chamber.evCalHour2 & tvHHData(:,5) == 30)| ...
                      (tvHHData(:,4) == c.chamber.evCalHour2+1 & tvHHData(:,5) == 0) | ...
                      (tvHHData(:,4) == c.chamber.calHour));
elseif (upper(SiteFlag) == 'BS' & c.chamber.systemType == 2) | (upper(SiteFlag) == 'PA' & c.chamber.systemType == 2)...
        | (upper(SiteFlag) == 'YF' & c.chamber.systemType == 2)
    badSlopeInd = find((tvHHData(:,4) == c.chamber.evCalHour & tvHHData(:,5) == 30) | ...
                      (tvHHData(:,4) == endEvCal & tvHHData(:,5) == 0)| ...
                      (tvHHData(:,4) == c.chamber.calHour & tvHHData(:,5) == 30)| ...
                      (tvHHData(:,4) == endCal & tvHHData(:,5) == 0));
end

fluxOut.dcdt(badSlopeInd,1:c.chamber.chNbr) = NaN;
fluxOut.r2(badSlopeInd,1:c.chamber.chNbr)   = NaN;
fluxOut.se(badSlopeInd,1:c.chamber.chNbr)   = NaN;
fluxOut.wv(badSlopeInd,1:c.chamber.chNbr)   = NaN;
fluxOut.flux(badSlopeInd,1:c.chamber.chNbr) = NaN;
