function [h_mod,h_gf,le_mod,le_gf] = gf_LE_H_Amiro_movwin_regr(tv,LE,H,Rn,Gtot,rdwpot,Tair,Tsoil,opSite);
%  gap fill LE and Hs using moving window regression with Rn-Gtot (Amiro, 2006)
%  winter-time fill with an ensemble average
%    -240 point day moving window regression model with Rn-G incremented 48 points (1 day) at a time

% Revisions
% Sept 17, 2014 (Nick)
%  -winter ensemble average selected for open and enclosed path IRGAs only
% i.e. site dependent

arg_default('opSite',1); % assume open path IRGA by default

t = tv;
dv =datevec(tv(100));
year = dv(1);
doy = t-datenum(year,1,0);
le_main = LE;
h_main = H;
net_rad_eco = Rn - Gtot;
pot_rad= rdwpot;
ta = Tair;
ts = Tsoil;

isNight     = pot_rad == 0;
isWinter    = ta<0 & ts<0;

% this function models sensible and latent heat using a moving window
% approach (Amiro et al. 2006).

%	Assign the moving window parameters. 
	
	WindowWidthR		= 240; 
	WindowIncR			= 48; 
    
% model sensible heat---------------------------------------    
	iReg 		 			= find(~isnan(h_main+net_rad_eco)); 
	nReg 					= length(iReg); 
    
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
%    			mcR(i)	 	= RHat0(it)\R(it); 
            [p, r2(i), sigma(i)] = polyfit1(net_rad_eco(it),h_main(it),1);
            mult(i) = p(1);
            offset(i)= p(2);

            							  diary off; 
							  fid = fopen(TempDiaryFile,'r'); 
							  cDiary = char(fread(fid))'; 
							  fclose(fid); delete (TempDiaryFile); 

			
 		end; % if jReg2< = nReg; 
	end; % for jReg1 = 1:WindowIncR:nReg; 
    	cR						= FCRN_naninterp1(mtR,mult,t,'linear'); 
            	cR1						= FCRN_naninterp1(mtR,offset,t,'linear'); 
                
 h_mod = cR.*net_rad_eco+cR1;
 
 % combine main and modelled trace to form gap-filled H
 
h_gf=h_main;
ind = find(isnan(h_gf));
h_gf(ind)=h_mod(ind);
 
 % latent heat ------------------------------------------------
 	iReg 		 			= find(~isnan(le_main+net_rad_eco)); 
	nReg 					= length(iReg); 
    
    i						= 0; 
	mtR					= []; 
	mcR					= []; 
	mult                = [];
    offset                = [];
	for jReg1 = 1:WindowIncR:nReg; 
		
		jReg2 			= jReg1+WindowWidthR-1; 
		
		if jReg2<=nReg; 
			
			i 				= i + 1; 
			it 			= iReg(jReg1:jReg2); 
			mtR(i)	 	= mean(t(it)); 
							  diary off; TempDiaryFile=tempname; 
							  diary (TempDiaryFile); 
%    			mcR(i)	 	= RHat0(it)\R(it); 
            [p, r2(i), sigma(i)] = polyfit1(net_rad_eco(it),le_main(it),1);
            mult(i) = p(1);
            offset(i)= p(2);

            							  diary off; 
							  fid = fopen(TempDiaryFile,'r'); 
							  cDiary = char(fread(fid))'; 
							  fclose(fid); delete (TempDiaryFile); 

			
 		end; % if jReg2< = nReg; 
	end; % for jReg1 = 1:WindowIncR:nReg; 
    	cR						= FCRN_naninterp1(mtR,mult,t,'linear'); 
            	cR1						= FCRN_naninterp1(mtR,offset,t,'linear'); 
%   doy = t - 8/24 -datenum(2007,1,0);              
 le_mod = cR.*net_rad_eco+cR1;
 
 % replace nan's during night in measured LE with zero.
le_measured=le_main;

inightnan = find(isnan(le_measured));
iNight = find(isNight);
iReject 				= intersect(inightnan,iNight);
le_measured(iReject)=zeros;
le_gf=le_measured;

if opSite % open or enclosed path IRGAs... iffy winters.
    ind = find(isnan(le_gf) & ~isWinter);
    le_gf(ind)=le_mod(ind);

    % during the winter ensemble average LE measurements
    le_winter = le_measured;
    ind=(isWinter & ~isNight);
    le_winter(1:length(le_measured))=NaN;
    le_winter(ind)=le_measured(ind);
    %doy_end = floor(doy(end));
    doy_end = floor(doy(end-1));
    %le_winter = reshape(le_winter,48,doy_end-1);
    le_winter = reshape(le_winter,48,doy_end);
    le_winter = nanmean(le_winter')';
    le_winter1 = le_winter;
    for i=1:doy_end-1
        le_winter1 = [le_winter1; le_winter];
    end

    ind1 = (isWinter & ~isNight & isnan(le_gf));

    le_gf(ind1)=le_winter1(ind1);
else % closed path site, reliable winters
    ind = find(isnan(le_gf));
    le_gf(ind)=le_mod(ind);
end

% COMMENTED OUT: DO ALL OTHER SMALL GAP FILLING IN THE INI FILE! (Nick, 2/16/12)
% now fill gaps in le_winter1 with linear interpolation. Gaps may remain
% due to the winter daytime averaging if no good measurements were amde in
% a particular half-hour (there are many nans in le as the winter cleariing procedure was applied to both le and fc.
% le_gf = FCRN_FillSmallGapsByLinInterp(le_gf,3); 
% le_gf = fr_fill_with_mdv(le_gf,9);
% le_et = le_gf/48*86400/(2.45*10^6);
% le_measured = le_measured/48*86400/(2.45*10^6); 