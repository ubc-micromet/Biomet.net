function [NEP,iNight,iDay,iColdSeason,iWarmSeason] = FCRN_select_good_measurements(NEE,uStar,iNight,uStarTH)

	iLowuStar 			= find(uStar<uStarTH); 

%	========================================================================

%	Assign NEP.

	NEP 					= -NEE; 

%	Exclude low-u* data at night. 

	iReject 				= intersect(iLowuStar,iNight); NEP(iReject) = NaN; 
