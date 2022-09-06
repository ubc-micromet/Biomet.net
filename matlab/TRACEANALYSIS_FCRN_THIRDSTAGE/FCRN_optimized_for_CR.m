function [NEP,R,GEP,NEPgf,Rgf,GEPgf,RHat,GEPHat,RHat0,GEPHat0,cR,cGEP] = FCRN_CO2Flux2NEP(t,NEE,uStar,PPFD,Ta,Ts,PPFDGF,TaGF,TsGF,isNight,uStarTH,FracSEBClosure,LogFile,Plots); 
% Version optimized for CR processing:
% - log-transform to find the respiratioin base function
% - log-transfrom to find the mean for a period
% - ustar-threshold applied to 100 mu mol m^-2 s^-1 PAR 

%FCRN_CO2Flux2NEP
%-	post-processes eddy-covariance measurements of 
%	net ecosystem exchange (NEE = CO2 flux + storage)
%-	calculates net ecosystem productivity (NEP) 
%-	partitions NEP into ecosystem respiration (R) 
%	and gross ecosystem photosynthesis (GEP)
%-	fills gaps in NEP, R and GEP, producing NEPgf, Rgf, and GEPgf
%
%Processing Steps:
%----------------
%
%1. NEP is estimated as -NEE after excluding low u* data at night and
%	applying the optional energy closure adjustment.
%2. Measured R is estimated from NEE at night and during the non-GrowingSeason
%3. An empirical R=f(Ts,t) model is fit based on the data from 2
%4. The R=f(Ts,t) model from 3 is used to estimate R during the day 
%	and to fill gaps in R at night
%5. GEP is estimated as NEP+R (daytime, growing season) or zero 
%	(nighttime and non-GrowingSeason) 
%6. An empirical GEP=f(PPFD,t) model is fit to the GEP data from 5
%7. The model from 6 is used to fill gaps in daytime, growing-season GEP
%8. Gaps in NEP are filled using modelled GEP-R
%
%	A moving window is used to capture the time variation in 
%	the R and GEP model parameters cR(t) and cGEP(t): 
%		R 		= cR(t)*bR(1)/(1+exp[bR(2)*(bR(3)-Ts)]); 
%		GEP 	= cGEP(t)*bGEP(1)*PPFD/(bGEP(2)+PPFD); 
%
%Syntax:
%------
%
%[NEP,R,GEP,NEPgf,Rgf,GEPgf] 
%	= CO2Flux2NEP(t,NEE,uStar,PPFD,Ta,Ts,PPFDGF,TaGF,TsGF,isNight,uStarTH,FracSEBClosure); 
%
%Input Arguments:
%---------------
%
%-	t is the decimal day vector
%-	NEE is the measured NEE (CO2 flux + storage) vector
%-	uStar is the friction velocity vector
%-	PPFD is the downwelling PAR flux density vector (used to model GEP)
%-	Ta is the air temperature vector (used optionally to model GEP)
%-	Ts is the soil temperature vector (used to model R)
%-	PPFDGF, TaGF, and TsGF are gap-filled values of PPFD, Ta, and Ts  
%-	isNight is a vector that indicates whether it is day (0) or night (1)
%-	uStarTH is the scalar uStar threshold below which nighttime NEP data are rejected
%-	FracSEBClosure is a scalar or vector SEB-closure adjustment divider 
%-	LogFile is the (optional) log file directory and name; create if not empty. 
%-	Plots (optional) specifies the plots to create. 

%	========================================================================
%	========================================================================

%	Notes

%	FCRN_CO2Flux2NEP Version 1.0
%	Written by Alan Barr and Natascha Kljun, 28 July 2003
%	Last update, 12 Sept 2003 FROZEN AS FCRN VERSION 1.0. 

%	Several non-standard MatLab functions are celled: 
%	- FCRN_doy
%	- FCRN_FillSmallGapsByLinInterp 
%	- FCRN_function_fit
%	- FCRN_gapsize 
%	- FCRN_datevec
%	- FCRN_nanmean
%	- FCRN_nanmedian
%	- FCRN_nansum
%	- FCRN_naninterp1

%	In this implementation, the growing season is not preset externally but falls 
%	out of the GEP analysis (in the cGEP(t) parameter). It is also constrained by air
%	and soil temperatures, which are used to stratify that data into three seasons:
%	-	the cold season (when both Ta and Ts are less than or equal to zero), 
%		when daytime GEP is set to zero, 
%	-	the non-cold season (when either or both Ta and Ts are positive), 
%		when daytime GEP is estimated from measured NEP and modeled R, 
%	-	the warm season (when both Ta and Ts are positive), which is used to estimate 
%		the bGEP model parameters.

% May 07, 2007, added gap filling for small gaps after applying the ustar
% threshold %Praveena
%	========================================================================
%	========================================================================

%	Fill small gaps in input data.	

	GapSizeMax  		= 4; 
	
	NEE	 			  	= FCRN_FillSmallGapsByLinInterp(NEE,GapSizeMax); 
	uStar				= FCRN_FillSmallGapsByLinInterp(uStar,GapSizeMax); 
	PPFD				= FCRN_FillSmallGapsByLinInterp(PPFD,GapSizeMax); 
	Ta					= FCRN_FillSmallGapsByLinInterp(Ta,GapSizeMax); 
	PPFDGF				= FCRN_FillSmallGapsByLinInterp(PPFDGF,GapSizeMax); 
	TaGF				= FCRN_FillSmallGapsByLinInterp(TaGF,GapSizeMax); 
	TsGF				= FCRN_FillSmallGapsByLinInterp(TsGF,GapSizeMax); 
	
%	========================================================================

%	Initial Assignments.

%	Specify the (inline) GEP and R models.

	fTs2R 				= inline(['b(1)./(1+exp(b(2)*(b(3)-Ts)))'],'b','Ts');
	fPPFD2GEP			= inline(['b(1)*PPFD./(b(2)+PPFD)'],'b','PPFD'); % can also be written in terms of alpha.
	
%	Assign the moving window parameters. 
	
	WindowWidthR		= 100; 
	WindowIncR			= 20; 
	
	WindowWidthGEP		= 100; 
	WindowIncGEP		= 20; 

	nt = length(NEE); nd = nt/48; 

    %	Assign conditions (is*) and indices (i*). 
	isDay 				= ~ isNight; 
	isColdSeason 		= TaGF<=0 & TsGF<=0; 
	isWarmSeason 		= TaGF>0 & TsGF>0; 
	isNotColdSeason 	= ~ isColdSeason; 
	
	iNight 				= find(isNight); 
	iDay 				= find(isDay); 
	iColdSeason 		= find(isColdSeason); 
	iWarmSeason 		= find(isWarmSeason); 
	iNotColdSeason		= find(isNotColdSeason); 

    [NEP] = FCRN_VI_select_measurements(NEE,uStar,PPFD,iNight,uStarTH);
    
%	Apply SEB-closure adjustment to the data.
	
	NEP 					= NEP./FracSEBClosure; 
	NEP	 			  	= FCRN_FillSmallGapsByLinInterp(NEP,GapSizeMax); % added  by praveena
%	========================================================================

%	Estimate and gap-fill R.

	disp('CO2Flux2NEP - estimating R ...'); 

	R 						= NaN*ones(size(NEP)); 
	RHat 					= NaN*ones(size(NEP)); 

%	Assign R = NEP at night and during daytime periods in the cold season. 

	R(iNight)			= -NEP(iNight); 
	R(iColdSeason)		= -NEP(iColdSeason); 
	
%	Fit the R model R = cR(t)*bR(1)/(1+exp[bR(2)*(bR(3)-Ts)]).

%	First, fit the bR parameters using binned means of all of the data. 

	iReg 		 			= find(~isnan(R+Ts) & R>0); 
	nReg 					= length(iReg); 
	%bRGuess	 			= [10 0.10 10]; 
	%bR 					= FCRN_function_fit(fTs2R,bRGuess,R(iReg),[],Ts(iReg)); 
	%RHat0 				= fTs2R(bR,TsGF); 
		
	bR = linregression(Ts(iReg),log(R(iReg)));
	[lin_R,lin_dR] = linprediction(bR,TsGF);
	RHat0 = exp(lin_R);

%	Second, use a moving window to estimate mcR(t), based on measured R  
%	and the preliminary estimate of modelled R (RHat0). The values (mcR,mtR) 
%	are first fit to each window and then interpolated to (cR(t),t). 

	i						= 0; 
	mtR					= []; 
	mcR					= []; 
	
	for jReg1 = 1:WindowIncR:nReg; 
		
		jReg2 			= jReg1+WindowWidthR-1; 
		
		if jReg2<=nReg; 
			
			i 				= i + 1; 
			it 			= iReg(jReg1:jReg2); 
			mtR(i)	 	= mean(t(it)); 
							  diary off; TempDiaryFile=tempname; 
							  diary (TempDiaryFile); 
%  			mcR(i)	 	= RHat0(it)\R(it); 
  			mcR(i)	 	= lin_R(it)\log(R(it)); 
							  diary off; 
							  fid = fopen(TempDiaryFile,'r'); 
							  cDiary = char(fread(fid))'; 
							  fclose(fid); delete (TempDiaryFile); 
%			if ~isempty(cDiary); mcR(i) = mean(R(it))/mean(RHat0(it)); end; % linear regression failed. 
			if ~isempty(cDiary); mcR(i) = mean(log(R(it)))/mean(lin_R(it)); end; % linear regression failed. 
			
		end; % if jReg2< = nReg; 
	end; % for jReg1 = 1:WindowIncR:nReg; 
	
%	Interpolate (mtR,mcR) coefficients to (t,cR) 30 min periods.

	cR						= FCRN_naninterp1(mtR,mcR,t,'linear'); 
	
%	If the data begin or end part-way through the time series, 
%	set cR to 1.0 at the beginning and/or end. Allow a 30-day buffer.
	
	itN					= min(iReg); 
	itX 					= max(iReg); 
	if itN>30*48; it = 1:(itN-1); cR(it) = 1; end; 	
	if itX<(nt-30*48); it = (itX+1):nt; cR(it) = 1; end; 
	
%	Calculate modeled R (RHat). 

%	RHat 					= cR.*RHat0; 
	RHat 					= exp(cR.*lin_R); 
			
%	Merge R and RHat to produce Rgf (gap-filled). 
				
	Rgf	 				= R; 
	igf 					= find(isnan(R) & ~isnan(RHat)); 
	Rgf(igf) 			= RHat(igf); 
	
%	========================================================================

%	Estimate and gap-fill GEP.
	
	disp('CO2Flux2NEP - estimating GEP ...'); 

%	Estimate measured GEP. Convention: NEP = GEP-R so GEP = NEP+R. 

	GEP					= NEP+Rgf; 
	
%	Set GEP to zero at night and during the cold season. 

	GEP(iNight) 		= 0; 
	GEP(iColdSeason) 	= 0; 

%	Fit the GEP model in two steps.
			
%	First, estimate the constant bGEP parameters using warm-season data only. 

	iReg 					= find(isDay & isWarmSeason & ~isnan(sum([PPFD GEP],2))); 
	bGEPGuess 			= [20 500]; 
	bGEP					= FCRN_function_fit(fPPFD2GEP,bGEPGuess,GEP(iReg),[],PPFD(iReg,:)); 
	GEPHat0				= fPPFD2GEP(bGEP,PPFDGF); 
			
%	Second, estimate mcGEP(t) for the whole annual cycle based on the NotColdSeason GEP data. 
%	Using a moving window, estimate mcGEP(t) by forced origin linear regression 
% 	of measured GEP versus GEPHat0, i.e., GEP(t)  =  mcGEP(t) * GEPHat0.

% 	Use diary to check for error messages; skip if the regression fails.

	iReg 					= find(isDay & isNotColdSeason & ~isnan(sum([PPFD GEP],2))); 
	nReg 					= length(iReg); 
	
	i						= 0; 
	mtGEP					= []; 
	mcGEP					= []; 
	
	for jReg1 = 1:WindowIncGEP:nReg; 
		
		jReg2 			= jReg1+WindowWidthGEP-1; 
		
		if jReg2<=nReg; 
			
			i				= i + 1; 
			it 			= iReg(jReg1:jReg2); 
			mtGEP(i) 	= mean(t(it)); 
							  diary off; 
							  diary(TempDiaryFile); 
  			mcGEP(i)	 	= GEPHat0(it)\GEP(it); 
							  diary off; 
							  fid = fopen(TempDiaryFile,'r'); 
							  cDiary = char(fread(fid))'; 
							  fclose(fid); delete ((TempDiaryFile)); 
		  if ~isempty(cDiary); mcGEP(i) = mean(GEP(it))/mean(GEPHat0(it)); end; % linear regression failed. 
								
		end; % if jReg2< = nReg; 
	end; % for jReg1 
	
%	Interpolate (mtGEP,mcGEP) to (t,cGEP) and calculate modeled GEP (GEPHat).
%	First, drop missing values of mcGEP.

	iNaN					= find(isnan(mcGEP)); 
	mtGEP(iNaN)			= []; 
	mcGEP(iNaN)			= []; 
	
	cGEP					= FCRN_naninterp1(mtGEP,mcGEP,t,'linear'); 
							
%	If the data begin or end part-way through the time series, 
%	set cGEP to NaN for non-cold-season daytime periods 
%	at the beginning and/or end. 

	itN 					= min(iReg); 
	itX 					= max(iReg); 
	iEx 					= [1:(itN-1) (itX+1):nt]; 
	iEx 					= intersect(iEx,iDay); 
	iEx 					= intersect(iEx,iNotColdSeason); 
	cGEP(iEx) 			= NaN; 
	
%	Also set cGEP to zero for periods when GEP is zero.
%	Probably redundant because GEP is already set to zero for these periods.	

	iZero 				= union(iNight,iColdSeason); 
	cGEP(iZero)			= 0; 

%	Estimate modelled GEP (GEPHat). 
			
	GEPHat 				= cGEP.*GEPHat0; 
	
%	Merge GEP and GEPHat to create GEPgf (gap-filled). 

	GEPgf 				= GEP; 
	
	igf 					= find(isnan(GEP) & ~isnan(GEPHat)); 
	GEPgf(igf)	    	= GEPHat(igf); 
	
%	========================================================================

%	Assign final gap-filled NEP = GEP-R values and fill gaps with modeled estimates.	
	
	NEPgf 				= NEP; 
	
	igf 					= find(isnan(NEPgf) & ~isnan(Rgf+GEP)); 
	NEPgf(igf)  		= GEP(igf)-Rgf(igf); 
	igf 					= find(isnan(NEPgf) & ~isnan(R+GEPgf)); 
	NEPgf(igf) 	    	= GEPgf(igf)-R(igf); 
	igf 					= find(isnan(NEPgf) & ~isnan(Rgf+GEPgf)); 
	NEPgf(igf)   		= GEPgf(igf)-Rgf(igf); 
	
%	========================================================================
%	========================================================================

%	End of computation. Optional log file output and graphics follow.	

%	========================================================================
%	========================================================================

%	Optional log file.

	if ~isempty(LogFile); 

		[myR,mmR,mdR,mhR,mnR,msR]=FCRN_datevec(mtR); 
		mmddR=mmR*100+mdR; hhmmR=mhR*100+mnR; 
		doyR=FCRN_DOY(mtR); 
		
		[myGEP,mmGEP,mdGEP,mhGEP,mnGEP,msGEP]=FCRN_datevec(mtGEP);
		mmddGEP=mmGEP*100+mdGEP; hhmmGEP=mhGEP*100+mnGEP; 
		doyGEP=FCRN_DOY(mtGEP); 
		
		% The use of iy below limits the annual totals to the median year. 
		
		[y,m,d,h,mn,s]=FCRN_datevec(t); iYr=median(y); iy=find(y==iYr); 
		mmdd=m*100+d; hhmm=h*100+mn; 
							
		c=12*30*60/1e6; % umol/m2/s to gC m-2; 
		sNEP=c*FCRN_nansum(NEPgf(iy)); sR=c*FCRN_nansum(Rgf(iy)); sGEP=c*FCRN_nansum(GEPgf(iy)); 
		nNEP=sum(~isnan(NEPgf(iy))); nR=sum(~isnan(Rgf(iy))); nGEP=sum(~isnan(GEPgf(iy))); 
		nmNEP=sum(isnan(NEPgf(iy))); nmR=sum(isnan(Rgf(iy))); nmGEP=sum(isnan(GEPgf(iy))); 
		
		fid=fopen(LogFile,'w'); 
		fprintf (fid,'FCRN_CO2Flux2NEP Version 1.0\n',LogFile); 
		fprintf (fid,'\n'); 
		fprintf (fid,'LogFile: %s\n',LogFile); 
		fprintf (fid,'Created: %s\n',datestr(now)); 
		fprintf (fid,'\n'); 
		fprintf(fid,'Year: %g\n',iYr); 
		fprintf (fid,'\n'); 
		fprintf(fid,'RModel: Ts2RLogistic\n'); 
		fprintf(fid,'GEPModel: PPFD2GEP\n'); 
		fprintf (fid,'\n'); 
		fprintf(fid,'Low-u* Exclusion Period: Nighttime only\n'); 
		fprintf(fid,'u*TH: %g\n',uStarTH); 
		fprintf(fid,'FracSEBClosure: %g\n',FracSEBClosure); 
		fprintf (fid,'\n'); 
		fprintf(fid,'Total NEP=GEP-R:  %5.0f = %5.0f - %5.0f gC.m-2\n',sNEP,sGEP,sR); 
		fprintf(fid,'nData NEP=GEP-R:  %5.0f   %5.0f   %5.0f\n',nNEP,nGEP,nR); 
		fprintf(fid,'nMiss NEP=GEP-R:  %5.0f   %5.0f   %5.0f\n',nmNEP,nmGEP,nmR); 
		fprintf (fid,'\n'); 
		fprintf (fid,'\n'); 
		fprintf(fid,'Fixed annual bR: %g %g %g\n',bR); 
		fprintf(fid,'Fixed annual bGEP: %g %g\n',bGEP); 
		fprintf (fid,'\n'); 
		fprintf(fid,'Moving mcR: %4.0f %4.0f %3.0f %4.0f  %7.3f\n',[myR' mmddR' doyR' hhmmR' mcR']'); 
		fprintf (fid,'\n'); 
		fprintf(fid,'Moving mcGEP: %4.0f %4.0f %3.0f %4.0f  %7.3f\n',[myGEP' mmddGEP' doyGEP' hhmmGEP' mcGEP']'); 
		fclose(fid); 
							
	end; % if ~isempty(LogFile); 
	
%	========================================================================

%	Optional Diagnostic Figures.

%	1. NEP=GEP-R time series plot.

	if ismember(1,Plots); figure(1); clf; % (t,[NEP R GEP])
		subplot('position',[0.10 0.68 0.85 0.28]); 
			plot(t,NEP,'b.'); hold on; 
			iGF=find(isnan(NEP)); 
			plot(t(iGF),NEPgf(iGF),'r.'); hold on; 
			set(gca,'FontSize',12,'FontWeight','bold'); 
			hold off; grid on; 
			ylabel('NEP'); 
			datetick('x',2); xlim([min(t) max(t)]); set(gca,'xTickLabel',[]); 
			yInc=5; ylim([floor(min(NEPgf)/yInc)*yInc ceil(max(NEPgf)/yInc)*yInc]); 
			legend('EC','GapFilled',2); 
		subplot('position',[0.10 0.39 0.85 0.28]); 
			plot(t,R,'b.'); hold on; 
			iGF=find(isnan(R)); 
			plot(t(iGF),Rgf(iGF),'r.'); hold on; 
			set(gca,'FontSize',12,'FontWeight','bold'); 
			hold off; grid on; 
			ylabel('R'); 
			datetick('x',2); xlim([min(t) max(t)]); set(gca,'xTickLabel',[]); 
			yInc=5; ylim([floor(min(Rgf)/yInc)*yInc ceil(max(Rgf)/yInc)*yInc]); 
		subplot('position',[0.10 0.10 0.85 0.28]); 
			plot(t,GEP,'b.'); hold on; 
			iGF=find(isnan(GEP)); 
			plot(t(iGF),GEPgf(iGF),'r.'); hold on; 
			set(gca,'FontSize',12,'FontWeight','bold'); 
			hold off; grid on; 
			ylabel('GEP'); 
			datetick('x',2); xlim([min(t) max(t)]); 
			yInc=5; ylim([floor(min(GEPgf)/yInc)*yInc ceil(max(GEPgf)/yInc)*yInc]); 
	end; 	
	
%	2. R model parameters and performance. 

	if ismember(2,Plots); figure(2); clf; % (t,R)
		subplot('position',[0.10 0.66 0.85 0.32]); 
			plot(t,R,'b.'); hold on; 
			plot(t,RHat,'r.'); hold on; 
			set(gca,'FontSize',12,'FontWeight','bold'); 
			hold off; grid on; 
			ylabel('R'); 
			datetick('x',2); xlim([min(t) max(t)]); set(gca,'xTickLabel',[]); 
			yInc=5; ylim([floor(min(Rgf)/yInc)*yInc ceil(max(Rgf)/yInc)*yInc]); 
			legend('EC','Estimated',2); 
		subplot('position',[0.10 0.38 0.85 0.26]); 
			plot(mtR,mcR,'ro','MarkerFaceColor','r'); hold on; 
			plot(t,cR,'k-'); hold on; 
			set(gca,'FontSize',12,'FontWeight','bold'); 
			hold off; grid on; 
			datetick('x',2); xlim([min(t) max(t)]); set(gca,'xTickLabel',[]); 
			ylabel('cR'); 
			yInc=0.5; ylim([floor(min(mcR)/yInc)*yInc ceil(max(mcR)/yInc)*yInc]); 
		subplot('position',[0.10 0.10 0.85 0.26]); 
			plot(t,Ts,'b-');  
			set(gca,'FontSize',12,'FontWeight','bold'); 
			grid on; 
			ylabel('Ts'); 
			datetick('x',2); xlim([min(t) max(t)]); 
			yInc=2; ylim([floor(min(Ts)/yInc)*yInc ceil(max(Ts)/yInc)*yInc]); 
	end; 	
	
%	3. GEP model parameters. 

	if ismember(3,Plots); figure(3); clf; % (t,GEP)
			
		subplot('position',[0.10 0.66 0.85 0.32]); 
			plot(t,GEP,'b.'); hold on; 
			plot(t,GEPHat,'r.'); hold on; 
			set(gca,'FontSize',12,'FontWeight','bold'); 
			hold off; grid on; 
			ylabel('GEP'); 
			datetick('x',2); xlim([min(t) max(t)]); set(gca,'xTickLabel',[]); 
			yInc=5; ylim([floor(min(GEPgf)/yInc)*yInc ceil(max(GEPgf)/yInc)*yInc]); 
			legend('EC','Estimated',2); 
		subplot('position',[0.10 0.38 0.85 0.26]); 
			plot(mtGEP,mcGEP,'ro','MarkerFaceColor','r'); hold on; 
			plot(t(iDay),cGEP(iDay),'k-'); hold on; 
			set(gca,'FontSize',12,'FontWeight','bold'); 
			hold off; grid on; 
			datetick('x',2); xlim([min(t) max(t)]); set(gca,'xTickLabel',[]); 
			ylabel('cGEP'); 
			yInc=0.5; ylim([floor(min(mcGEP)/yInc)*yInc ceil(max(mcGEP)/yInc)*yInc]); 
		subplot('position',[0.10 0.10 0.85 0.26]); 
			plot(t,PPFD,'b-');  
			set(gca,'FontSize',12,'FontWeight','bold'); 
			grid on; 
			ylabel('PPFD'); 
			datetick('x',2); xlim([min(t) max(t)]); 
			yInc=200; ylim([floor(min(PPFD)/yInc)*yInc ceil(max(PPFD)/yInc)*yInc]); 
			
	end; 	

%	xy plots.		

%	4. R vs Ts. 

	if ismember(4,Plots); figure(4); clf; % (Ts,R)
		plot(Ts,R,'b.'); hold on; 
		plot(Ts,RHat,'c.'); hold on; 
		plot(Ts,RHat0,'r.'); hold on; 
		set(gca,'FontSize',12,'FontWeight','bold'); 
		grid on; hold off; 
		xlabel('Ts'); ylabel('R'); 
		legend('EC','Estimated','Annual',2); 
	end; 	
		
%	5. GEP vs PPFD. 

	if ismember(5,Plots); figure(5); clf; % (PPFD {Ta D],GEP)
		plot(PPFD(iNotColdSeason),GEP(iNotColdSeason),'k.'); hold on; 
		plot(PPFD(iNotColdSeason),GEPHat(iNotColdSeason),'r.'); hold on; 
		set(gca,'FontSize',12,'FontWeight','bold'); 
		grid on; hold off; 
		xlabel('PPFD'); ylabel('GEP'); 
		legend('EC','Estimated',2); 
	end; 	
	
	if ~isempty(Plots); 'Paused after CO2Flux2NEP plots.', pause; end; 

	disp('CO2Flux2NEP - Finished.'); 
	
%	========================================================================
