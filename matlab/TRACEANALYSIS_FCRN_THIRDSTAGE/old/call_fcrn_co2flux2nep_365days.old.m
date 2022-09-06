function [NEP,R,GEP,NEPgf,Rgf,GEPgf,RHat,GEPHat,RHat0,GEPHat0,cR,cGEP,t] = Call_fcrn_CO2Flux2NEP_365days(SiteId,date_start,uStarTH,mSEBClosure,flag_cleaning)
% Call_fcrn_CO2Flux2NEP_last365days - Runs FCRN_CO2Flux2NEP for the past 365 days
%
% Syntax:
% [NEP,R,GEP,NEPgf,Rgf,GEPgf,RHat,GEPHat,RHat0,GEPHat0,cR,cGEP] = Call_fcrn_CO2Flux2NEP_last365days(SiteId,date_start,uStarTH,mSEBClosure,flag_cleaning)
%
% Second stage variables are loaded within the function. 
% Third stage variables are loaded according to flag_cleaning:
% flag_cleaning == 0 : load from database (default)
% flag_cleaning == 1 : load current year from caller workspace and rest from database 
%                      (to be used withing third stage cleaning)

% Feb 14, 2004 kai*
% Revisions:

if ~exist('flag_cleaning') | isempty(flag_cleaning)
   flag_cleaning = 0;
end

%-------------------------------------------------------------------------
% Determine time interval for gap filling
%-------------------------------------------------------------------------
dv = datevec(date_start);
Years = [dv(1)-1 dv(1)];

pth         = biomet_path('yyyy',SiteId,'clean\secondstage');

tv           = read_bor([pth 'clean_tv'],8,[],Years,[],1);
indOut = find(tv > datenum(dv(1)-1,dv(2),dv(3),dv(4),dv(5),dv(6)+10) & ...
   tv <= datenum(dv(1),dv(2),dv(3),dv(4),dv(5),dv(6)));

%-------------------------------------------------------------------------
% Load second stage (non-gap) filled data
%-------------------------------------------------------------------------
t           = read_bor([pth 'clean_tv'],8,[],Years,indOut,1);
PPFD        = read_bor([pth 'ppfd_downwelling_main'],[],[],Years,indOut,1);
Ta          = read_bor([pth 'air_temperature_main'],[],[],Years,indOut,1);
Ts          = read_bor([pth 'soil_temperature_2'],[],[],Years,indOut,1);
NEE         = read_bor([pth 'nee_main'],[],[],Years,indOut,1);
uStar       = read_bor([pth 'ustar_main'],[],[],Years,indOut,1);

%-------------------------------------------------------------------------
% Load third stage data (gap filled)
%-------------------------------------------------------------------------
pth_lin     = biomet_path('yyyy',SiteId,'clean\thirdstage');

try
   PPFDGF      = read_bor([pth_lin 'ppfd_downwelling_main'],[],[],Years,indOut,1);
   TaGF        = read_bor([pth_lin 'air_temperature_main'],[],[],Years,indOut,1);
   TsGF        = read_bor([pth_lin 'soil_temperature_2'],[],[],Years,indOut,1);
   pot_rad     = read_bor([pth_lin 'radiation_downwelling_potential'],[],[],Years,indOut,1); % load data
end

%-------------------------------------------------------------------------
% If cleanging, load current data from caller workspace
%-------------------------------------------------------------------------
if flag_cleaning
   tv_cur = evalin('caller','clean_tv');
   PPFDGF_cur  = evalin('caller','ppfd_downwelling_main');
   TaGF_cur    = evalin('caller','air_temperature_main');
   TsGF_cur    = evalin('caller','soil_temperature_2');
   pot_rad_cur = evalin('caller','radiation_downwelling_potential');
   
   % Treat the old problem that datenum(2004,1,1) is a measurement in 2003
   if date_start == datenum(dv(1),1,1)
        Year_cur = dv(1)-1;
   else
        Year_cur = dv(1);
   end

   ind_cur = find(tv_cur > datenum(Year_cur,1,1,0,29,50) & ...
      tv_cur <= datenum(dv(1),dv(2),dv(3),dv(4),dv(5),dv(6)));
   ind_rep = find(t > datenum(Year_cur,1,1,0,29,50) & ...
      t <= datenum(dv(1),dv(2),dv(3),dv(4),dv(5),dv(6)));
   
   PPFDGF(ind_rep)  = PPFDGF_cur(ind_cur);
   TaGF(ind_rep)    = TaGF_cur(ind_cur);
   TsGF(ind_rep)    = TsGF_cur(ind_cur);
   pot_rad(ind_rep) = pot_rad_cur(ind_cur);

   % If PPFDGF etc. did not exist prior they will be created as row vectors,
   % so here we make them column vectors
   PPFDGF  = PPFDGF(:);
   TaGF    = TaGF(:);
   TsGF    = TsGF(:);
   pot_rad = pot_rad(:);

end

%-------------------------------------------------------------------------
% Run gap filling
%-------------------------------------------------------------------------
isNight     = pot_rad == 0;

switch upper(SiteId)
case 'CR'
   [NEP,R,GEP,NEPgf,Rgf,GEPgf,RHat,GEPHat,RHat0,GEPHat0,cR,cGEP] = ...
      FCRN_optimized_for_CR(t,NEE,uStar,PPFD,Ta,Ts,PPFDGF,TaGF,TsGF,isNight,uStarTH,mSEBClosure,[],[]); 
otherwise
   [NEP,R,GEP,NEPgf,Rgf,GEPgf,RHat,GEPHat,RHat0,GEPHat0,cR,cGEP] = ...
      FCRN_CO2Flux2NEP(t,NEE,uStar,PPFD,Ta,Ts,PPFDGF,TaGF,TsGF,isNight,uStarTH,mSEBClosure,[],[]); 
end

return