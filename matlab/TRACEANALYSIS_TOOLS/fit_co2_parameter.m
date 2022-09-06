function [leafout,leafend,R_coefS,R_coefW,P_coefS,P_coefW] = fit_co2_parameter(siteid,year)
%
%
%
% Function returns parameters base on site and date
% Please give source code that generated these parameters

if ~exist('siteid') | isempty(siteid)
   siteid = fr_current_siteid;
end
if ~exist('year') | isempty(year)
   dummy = datevec(now);
   year  = dummy(1);
end

switch upper(siteid)
   case 'PA'
		switch year
      case 1994 % leafout and leaf end are taken from bill's NEEC_cal.m for 1994 - 1999
        leafout = 120; leafend = 266; 
		  R_coefS = [6.88 0.2474 8.4];   	 	%from Wenjun's paper
		  R_coefW = [8.8258 0.2095 10.4075];   	% u* > 0.35 
		  P_coefS = [0.0387 47.9200]; %coefficient calculate from Photosynth_pl.m 
	     P_coefW = [0.0406 47.9989]; %u*>0.35
      case 1996
        leafout = 140; leafend = 279; 
		  R_coefS = [7.31 0.2606 8.6];         %from Wenjun's paper
		  R_coefW = [8.8659 0.2340 9.9956];   	% u* > 0.35
		  P_coefS = [0.0427 43.3466]; %coefficient calculate from Photosynth_pl.m 
		  P_coefW = [0.0454 43.5782]; %u*>0.35
      case 1997
        leafout = 128; leafend = 273; 
		  R_coefS = [6.7988 0.2642 8.1857 0];  %coefficient calculate from Respiration.m
		  R_coefW = [7.0934 0.2368 8.0189];    % u* > 0.35
		  P_coefS = [0.0371 46.6255]; %coefficient calculate from Photosynth_pl.m 
	     P_coefW = [0.0378 46.1804]; %u*>0.35
      case 1998
        leafout = 100; leafend = 275; 
		  R_coefS = [7.3774 0.2685 9.3938];   	%coefficient calculate from Respiration.m
		  R_coefW = [8.8463 0.2407 10.6355];   	% u* > 0.35
		  P_coefS = [0.0334 42.1229]; %coefficient calculate from Photosynth_pl.m 
		  P_coefW = [0.0347 43.1406]; %u*>0.35
      case 1999
        leafout = 128; leafend = 273; 
		  R_coefS = []; 
		  R_coefW = [7.9822 0.3215 8.2817];   	% u* > 0.35
		  P_coefS = []; % coefficient still to be calculate 
		  P_coefW = [0.0504 37.2427]; %u*>0.35
     end
  end
  
