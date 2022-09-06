function [fluxFinal] = ach_correct_flux(evLongNew,evShortNew,fluxLongNew,fluxShortNew);

warning off;

fluxLongNewCorrected = fluxLongNew;

%apply correction for effective volume
fluxLongNewCorrected = (fluxLongNewCorrected./evLongNew).*evShortNew;

%perform a linear regression between short and long fluxes to find
%correction factor for the effect of slope length
ind_nonan = find(~isnan(fluxShortNew) & ~isnan(fluxLongNewCorrected));
[p,R2,sigma,s,Y_hat] = polyfit1(fluxShortNew(ind_nonan),fluxLongNewCorrected(ind_nonan),1);

correctionFactor = 1 + (1 - p(1));

fluxFinal = fluxLongNewCorrected.* correctionFactor;

