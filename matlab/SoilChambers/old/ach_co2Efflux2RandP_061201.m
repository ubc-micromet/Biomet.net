function [Efflux,R,P,Effluxgf,Rgf,Pgf,RHat,PHat,RHat0,PHat0,cR,cP] = ach_co2Efflux2RandP(t,Efflux,PPFD,Ta,Ts,PPFDGF,TaGF,TsGF,isNight,LogFile,Plots,siteId); 

%	Fill small gaps in input data.	

	GapSizeMax  		= 4; 
	
	Efflux			  	= FCRN_FillSmallGapsByLinInterp(Efflux,GapSizeMax); 
	PPFD				= FCRN_FillSmallGapsByLinInterp(PPFD,GapSizeMax); 
	Ta					= FCRN_FillSmallGapsByLinInterp(Ta,GapSizeMax); 
	PPFDGF				= FCRN_FillSmallGapsByLinInterp(PPFDGF,GapSizeMax); 
	TaGF				= FCRN_FillSmallGapsByLinInterp(TaGF,GapSizeMax); 
	TsGF				= FCRN_FillSmallGapsByLinInterp(TsGF,GapSizeMax); 
	
%	========================================================================

%	Initial Assignments.

%	Specify the (inline) R and P models.

	fTs2R 				= inline(['b(1)./(1+exp(b(2)*(b(3)-Ts)))'],'b','Ts');
	fPPFD2P 			= inline(['b(1)*PPFD./(b(2)+PPFD)'],'b','PPFD'); % can also be written in terms of alpha.
	
%	Assign the moving window parameters. 
	
	WindowWidthR		= 100; 
	WindowIncR			= 20; 
	
	WindowWidthP		= 100; 
	WindowIncP		    = 20; 

%	Assign conditions (is*) and indices (i*). 
	
	nt = length(Efflux); nd = nt/48; 

	isDay 				= ~ isNight; 
	isColdSeason 		= TsGF<=0; 
	isWarmSeason 		= TsGF>0; 
	isNotColdSeason 	= ~ isColdSeason; 
	
	iNight 				= find(isNight); 
	iDay 				= find(isDay); 
	iColdSeason 		= find(isColdSeason); 
	iWarmSeason 		= find(isWarmSeason); 
	iNotColdSeason		= find(isNotColdSeason); 
		
%	========================================================================

%	Estimate and gap-fill R.

	disp('co2Efflux2RandP - estimating R ...'); 

	R 						= NaN*ones(size(Efflux)); 
	RHat 					= NaN*ones(size(Efflux)); 

%	Assign R = Efflux at night and during daytime periods in the cold season. 

    R(iNight)			= Efflux(iNight); 
	R(iColdSeason)		= Efflux(iColdSeason); 
	
%   Assign R = Efflux during day for PA (assuming no photosynthesis) 
	if siteId == 'PA'
        R(iDay)			= Efflux(iDay); 
	end
    
%	First, fit the bR parameters using binned means of all of the data. 

	iReg 		 		= find(~isnan(R+Ts)); 
	nReg 				= length(iReg); 
	bRGuess	 			= [20 0.10 20]; 
	bR 					= FCRN_function_fit(fTs2R,bRGuess,R(iReg),[],Ts(iReg)); 
	RHat0 				= fTs2R(bR,TsGF); 
		
%	Second, use a moving window to estimate mcR(t), based on measured R  
%	and the preliminary estimate of modelled R (RHat0). The values (mcR,mtR) 
%	are first fit to each window and then interpolated to (cR(t),t). 

	i					= 0; 
	mtR					= []; 
	mcR					= []; 
	
	for jReg1 = 1:WindowIncR:nReg; 
		
		jReg2 			= jReg1+WindowWidthR-1; 
		
		if jReg2<=nReg; 
			
			i 			= i + 1; 
			it 			= iReg(jReg1:jReg2); 
			mtR(i)	 	= mean(t(it)); 
						  diary off; TempDiaryFile=tempname; 
						  diary (TempDiaryFile); 
  			mcR(i)	 	= RHat0(it)\R(it); 
						  diary off; 
						  fid = fopen(TempDiaryFile,'r'); 
						  cDiary = char(fread(fid))'; 
						  fclose(fid); delete (TempDiaryFile); 
			if ~isempty(cDiary); mcR(i) = mean(R(it))/mean(RHat0(it)); end; % linear regression failed. 
			
		end; % if jReg2< = nReg; 
	end; % for jReg1 = 1:WindowIncR:nReg; 
	
%	Interpolate (mtR,mcR) coefficients to (t,cR) 30 min periods.

	cR					= FCRN_naninterp1(mtR,mcR,t,'linear'); 
	
%	If the data begin or end part-way through the time series, 
%	set cR to 1.0 at the beginning and/or end. Allow a 30-day buffer.
	
	itN					= min(iReg); 
	itX 				= max(iReg); 
	if itN>30*48; it = 1:(itN-1); cR(it) = 1; end; 	
	if itX<(nt-30*48); it = (itX+1):nt; cR(it) = 1; end; 
	
%	Calculate modeled R (RHat). 

	RHat 				= cR.*RHat0; 
			
%	Merge R and RHat to produce Rgf (gap-filled). 
				
	Rgf	 				= R; 
	igf 				= find(isnan(R) & ~isnan(RHat)); 
	Rgf(igf) 			= RHat(igf); 
	
%	========================================================================

%	Estimate and gap-fill P.
	
	disp('co2Efflux2RandP - estimating P ...'); 

%	Estimate measured P.  

	P					= Efflux-Rgf; 
	
%	Set P to zero at night and during the cold season. 

	P(iNight) 		= 0; 
	P(iColdSeason) 	= 0; 

%	Set P to zero during day for PA (assuming no photosynthesis). 
	if siteId == 'PA'
		P(iDay) 	= 0; 
	end
   
%	Fit the P model in two steps.
			
%	First, estimate the constant bP parameters using warm-season data only. 

	iReg 				= find(isDay & isWarmSeason & ~isnan(sum([PPFD P],2))); 
	bPGuess 			= [20 500]; 
	bP					= FCRN_function_fit(fPPFD2P,bPGuess,P(iReg),[],PPFD(iReg,:)); 
	PHat0				= fPPFD2P(bP,PPFDGF); 
			
%	Second, estimate mcP(t) for the whole annual cycle based on the NotColdSeason P data. 
%	Using a moving window, estimate mcP(t) by forced origin linear regression 
% 	of measured P versus PHat0, i.e., P(t)  =  mcP(t) * PHat0.

% 	Use diary to check for error messages; skip if the regression fails.

	iReg 					= find(isDay & isNotColdSeason & ~isnan(sum([PPFD P],2))); 
	nReg 					= length(iReg); 
	
	i						= 0; 
	mtP					= []; 
	mcP					= []; 
	
	for jReg1 = 1:WindowIncP:nReg; 
		
		jReg2 			= jReg1+WindowWidthP-1; 
		
		if jReg2<=nReg; 
			
			i				= i + 1; 
			it 			= iReg(jReg1:jReg2); 
			mtP(i) 	= mean(t(it)); 
							  diary off; 
							  diary(TempDiaryFile); 
  			mcP(i)	 	= PHat0(it)\P(it); 
							  diary off; 
							  fid = fopen(TempDiaryFile,'r'); 
							  cDiary = char(fread(fid))'; 
							  fclose(fid); delete ((TempDiaryFile)); 
		  if ~isempty(cDiary); mcP(i) = mean(P(it))/mean(PHat0(it)); end; % linear regression failed. 
								
		end; % if jReg2< = nReg; 
	end; % for jReg1 
	
%	Interpolate (mtP,mcP) to (t,cP) and calculate modeled P (PHat).
%	First, drop missing values of mcP.

	iNaN					= find(isnan(mcP)); 
	mtP(iNaN)			= []; 
	mcP(iNaN)			= []; 
	
	cP					= FCRN_naninterp1(mtP,mcP,t,'linear'); 
							
%	If the data begin or end part-way through the time series, 
%	set cP to NaN for non-cold-season daytime periods 
%	at the beginning and/or end. 

	itN 					= min(iReg); 
	itX 					= max(iReg); 
	iEx 					= [1:(itN-1) (itX+1):nt]; 
	iEx 					= intersect(iEx,iDay); 
	iEx 					= intersect(iEx,iNotColdSeason); 
	cP(iEx) 			= 0; 
	
%	Also set cP to zero for periods when P is zero.
%	Probably redundant because P is already set to zero for these periods.	

	iZero 				= union(iNight,iColdSeason); 
	cP(iZero)			= 0; 

%	Estimate modelled P (PHat). 
			
	PHat 				= cP.*PHat0; 
    
%	Merge P and PHat to create Pgf (gap-filled). 

	Pgf 				= P; 
	
	igf 				= find(isnan(P) & ~isnan(PHat)); 
	Pgf(igf)	    	= PHat(igf); 
	
%	========================================================================

%	Assign final gap-filled Efflux = P-R values and fill gaps with modeled estimates.	
	
	Effluxgf 			= Efflux; 
	
   	igf 				= find(isnan(Effluxgf) & ~isnan(Rgf+P)); 
	Effluxgf(igf)  		= P(igf)+Rgf(igf); 
	igf 				= find(isnan(Effluxgf) & ~isnan(R+Pgf)); 
	Effluxgf(igf) 	    = Pgf(igf)+R(igf); 
	igf 				= find(isnan(Effluxgf) & ~isnan(Rgf+Pgf)); 
	Effluxgf(igf)   	= Pgf(igf)+Rgf(igf); 

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
		
		[myP,mmP,mdP,mhP,mnP,msP]=FCRN_datevec(mtP);
		mmddP=mmP*100+mdP; hhmmP=mhP*100+mnP; 
		doyP=FCRN_DOY(mtP); 
		
		% The use of iy below limits the annual totals to the median year. 
		
		[y,m,d,h,mn,s]=FCRN_datevec(t); iYr=median(y); iy=find(y==iYr); 
		mmdd=m*100+d; hhmm=h*100+mn; 
							
		c=12*30*60/1e6; % umol/m2/s to gC m-2; 
		sEfflux=c*FCRN_nansum(Effluxgf(iy)); sR=c*FCRN_nansum(Rgf(iy)); sP=c*FCRN_nansum(Pgf(iy)); 
		nEfflux=sum(~isnan(Effluxgf(iy))); nR=sum(~isnan(Rgf(iy))); nP=sum(~isnan(Pgf(iy))); 
		nmEfflux=sum(isnan(Effluxgf(iy))); nmR=sum(isnan(Rgf(iy))); nmP=sum(isnan(Pgf(iy))); 
		
		fid=fopen(LogFile,'w'); 
		fprintf (fid,'ach_co2Efflux2RandP Version 1.0\n',LogFile); 
		fprintf (fid,'\n'); 
		fprintf (fid,'LogFile: %s\n',LogFile); 
		fprintf (fid,'Created: %s\n',datestr(now)); 
		fprintf (fid,'\n'); 
		fprintf(fid,'Year: %g\n',iYr); 
		fprintf (fid,'\n'); 
		fprintf(fid,'RModel: Ts2RLogistic\n'); 
		fprintf(fid,'PModel: PPFD2P\n'); 
		fprintf (fid,'\n'); 
		fprintf(fid,'Total Efflux=P-R:  %5.0f = %5.0f - %5.0f gC.m-2\n',sEfflux,sP,sR); 
		fprintf(fid,'nData Efflux=P-R:  %5.0f   %5.0f   %5.0f\n',nEfflux,nP,nR); 
		fprintf(fid,'nMiss Efflux=P-R:  %5.0f   %5.0f   %5.0f\n',nmEfflux,nmP,nmR); 
		fprintf (fid,'\n'); 
		fprintf (fid,'\n'); 
		fprintf(fid,'Fixed annual bR: %g %g %g\n',bR); 
		fprintf(fid,'Fixed annual bP: %g %g\n',bP); 
		fprintf (fid,'\n'); 
		fprintf(fid,'Moving mcR: %4.0f %4.0f %3.0f %4.0f  %7.3f\n',[myR' mmddR' doyR' hhmmR' mcR']'); 
		fprintf (fid,'\n'); 
		fprintf(fid,'Moving mcP: %4.0f %4.0f %3.0f %4.0f  %7.3f\n',[myP' mmddP' doyP' hhmmP' mcP']'); 
		fclose(fid); 
							
	end; % if ~isempty(LogFile); 
	
%	========================================================================

%	Optional Diagnostic Figures.

%	1. Efflux=P-R time series plot.

	if ismember(1,Plots); figure(1); clf; % (t,[Efflux R P])
		subplot('position',[0.10 0.68 0.85 0.28]); 
			plot(t,Efflux,'b.'); hold on; 
			iGF=find(isnan(Efflux)); 
			plot(t(iGF),Effluxgf(iGF),'r.'); hold on; 
			set(gca,'FontSize',12,'FontWeight','bold'); 
			hold off; grid on; 
			ylabel('Efflux'); 
			datetick('x',2); xlim([min(t) max(t)]); set(gca,'xTickLabel',[]); 
			yInc=5; ylim([floor(min(Effluxgf)/yInc)*yInc ceil(max(Effluxgf)/yInc)*yInc]); 
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
			plot(t,P,'b.'); hold on; 
			iGF=find(isnan(P)); 
			plot(t(iGF),GEPgf(iGF),'r.'); hold on; 
			set(gca,'FontSize',12,'FontWeight','bold'); 
			hold off; grid on; 
			ylabel('GEP'); 
			datetick('x',2); xlim([min(t) max(t)]); 
			yInc=5; ylim([floor(min(Pgf)/yInc)*yInc ceil(max(Pgf)/yInc)*yInc]); 
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
	
%	3. P model parameters. 

	if ismember(3,Plots); figure(3); clf; % (t,P)
			
		subplot('position',[0.10 0.66 0.85 0.32]); 
			plot(t,P,'b.'); hold on; 
			plot(t,PHat,'r.'); hold on; 
			set(gca,'FontSize',12,'FontWeight','bold'); 
			hold off; grid on; 
			ylabel('GEP'); 
			datetick('x',2); xlim([min(t) max(t)]); set(gca,'xTickLabel',[]); 
			yInc=5; ylim([floor(min(Pgf)/yInc)*yInc ceil(max(Pgf)/yInc)*yInc]); 
			legend('EC','Estimated',2); 
		subplot('position',[0.10 0.38 0.85 0.26]); 
			plot(mtP,mcP,'ro','MarkerFaceColor','r'); hold on; 
			plot(t(iDay),cP(iDay),'k-'); hold on; 
			set(gca,'FontSize',12,'FontWeight','bold'); 
			hold off; grid on; 
			datetick('x',2); xlim([min(t) max(t)]); set(gca,'xTickLabel',[]); 
			ylabel('cGEP'); 
			yInc=0.5; ylim([floor(min(mcP)/yInc)*yInc ceil(max(mcP)/yInc)*yInc]); 
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
		
%	5. P vs PPFD. 

	if ismember(5,Plots); figure(5); clf; % (PPFD {Ta D],P)
		plot(PPFD(iNotColdSeason),P(iNotColdSeason),'k.'); hold on; 
		plot(PPFD(iNotColdSeason),PHat(iNotColdSeason),'r.'); hold on; 
		set(gca,'FontSize',12,'FontWeight','bold'); 
		grid on; hold off; 
		xlabel('PPFD'); ylabel('GEP'); 
		legend('EC','Estimated',2); 
	end; 	
	
	if ~isempty(Plots); 'Paused after co2Flux2RandP plots.', pause; end; 

	disp('co2Flux2RandP - Finished.'); 
	
%	========================================================================
