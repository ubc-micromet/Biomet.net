function [fluxOut] = ach_get_flux(slopeData,evOut,HH_climate_stats,Time_vector_HH_HH,c,Stats);
%[fluxOut] = ach_get_flux(slopeData,evOut,HH_climate_stats,Time_vector_HH_HH,c,Stats)
%
%Function that computes half-hourly fluxes for automated respiration chamber systems
%Called within: ach_HH_flux_stats
%
%Input varibales:    slopeData
%                    evOut
%                    HH_climate_stats
%                    Time_vector_HH_HH
%                    c
%                    Stats (from eddy covariance output) 
%
%Output variables: output structure fluxOut that contains all the information about flux stats     
%
%(c) dgg                
%Created:  Nov 26, 2003
%Revision: Mar 28, 2006

% Revisions
%  March 28, 2006 (David)
%   - added initial CO2 concentration calculation for each slope
%  Dec 1, 2005
%   - added checking if the field for "bad points" is present before trying to use it
%   Aug 29, 2005
%       - Changes to make function generic:
%           - bad point index is now passed from *_init_all.m file
%           - a matrix of chamber areas (48 x chNbr) is now passed from the
%           ini file to this function, it's not anymore calculated here
%   Aug 20, 2005 (Z)
%       - changed all string comparisons to strcmp()
warning off;
R = 8.3144; %in J mol-1 K-1 or Pa m3 mol-1 K-1

%get barometric pressure data 
pBarTmp = Stats.pBarTmp;
tvTmp   = Stats.tvTmp;
[Int,a,b]  = intersect(fr_round_hhour(Time_vector_HH_HH),fr_round_hhour(tvTmp),'tv'); 
pBarTmp = pBarTmp(b);
pBarTmp = pBarTmp .* 1000; %in pascals

pBar = NaN .* zeros(length(pBarTmp),c.chamber.chNbr); 
for j = 1:c.chamber.chNbr
  	pBar(:,j) = pBarTmp(:,1); 
end

pBar(find(isnan(pBar(:))==1))= c.chamber.Pbar * 1000;        % default pressure for all pBar == NaN

%reshape slopeData matrix to account for number of chambers
for ch = 1:c.chamber.chNbr
   chInd = ch:c.chamber.chNbr:length(slopeData);
   fluxOut.dcdt(:,ch) = slopeData(chInd,2);
   fluxOut.r2(:,ch)   = slopeData(chInd,3);
   fluxOut.se(:,ch)   = slopeData(chInd,4);
   fluxOut.wv(:,ch)   = slopeData(chInd,6);
   fluxOut.initialCO2(:,ch)   = slopeData(chInd,7);
end

%get air temperature from HH_climate_stats data
airT = HH_climate_stats.temp_air;
for hhour = 1:size(airT,1)
	for ch = 1:c.chamber.chNbr
        % In case the measurement is missing (NaN) use the mean of all "good" measurements
        if isnan(airT(hhour,ch))
            ind_not_nan = ~isnan(airT(hhour,:));
            airT(hhour,ch) = mean(airT(hhour,ind_not_nan));
        end 
    end
end

%calculate fluxes
fluxOut.flux(:,:) = pBar .* evOut.ev .* fluxOut.dcdt(:,:) ./ ...
	(R .* (airT(:,:) + 273.15) .* c.chamber.Area .* (1 + (fluxOut.wv(:,:)./1000)));

%remove bad fluxes (licor and effective volume calibrations and sample outside air periods)
if isfield(c.chamber,'BadDataPoints') & ~isempty(c.chamber.BadDataPoints)
	fluxOut.dcdt(c.chamber.BadDataPoints,1:c.chamber.chNbr) = NaN;
	fluxOut.r2(c.chamber.BadDataPoints,1:c.chamber.chNbr)   = NaN;
	fluxOut.se(c.chamber.BadDataPoints,1:c.chamber.chNbr)   = NaN;
	fluxOut.wv(c.chamber.BadDataPoints,1:c.chamber.chNbr)   = NaN;
	fluxOut.initialCO2(c.chamber.BadDataPoints,1:c.chamber.chNbr) = NaN;
	fluxOut.flux(c.chamber.BadDataPoints,1:c.chamber.chNbr) = NaN;
end