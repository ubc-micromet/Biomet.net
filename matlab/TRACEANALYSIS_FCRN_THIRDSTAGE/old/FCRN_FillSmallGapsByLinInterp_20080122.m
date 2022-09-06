	function xGF=FillSmallGapsByLinInterp(x,GapSizeMax); 
	
%	xGF=FillSmallGapsByLinInterp(x,GapSizeMax); 
%	
%	FillSmallGapsByLinInterp fills small gaps 
%	in time series by linear interpolation. 
%
%	Gaps are filled if the gap size is less than 
%	or equal to GapSizeMax.

%	Written by Alan Barr 2002.
%	Calls gapsize which is also written by Alan Barr 2002.. 
	
	GapSize=FCRN_gapsize(x); 
	iGF=find(GapSize>0 & GapSize<=GapSizeMax); 
	iYaN=find(~isnan(x)); 
	GF=interp1(iYaN,x(iYaN),iGF,'linear'); 
	xGF=x; xGF(iGF)=GF; 	
	
