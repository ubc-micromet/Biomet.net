function [NEP,iNight,iDay,iColdSeason,iWarmSeason] = FCRN_VI_select_good_measurements(NEE,uStar,PPFD,iNight,uStarTH)

	iLowuStar 			= find(uStar<uStarTH); 
   iLowLight 			= find(PPFD<100 & PPFD>0); 
   
%	========================================================================

%	Assign NEP.

	NEP 					= -NEE; 

%	Exclude low-u* data at night. 

    iReject = intersect(iLowuStar,iNight); NEP(iReject) = NaN; 
    %iReject = intersect(iLowuStar,iLowLight); NEP(iReject) = NaN; 
