function [NEP,R,GEP,NEPgf,Rgf,GEPgf,RHat,GEPHat,RHat0,GEPHat0,cR,cGEP,t] = Call_fcrn_CO2Flux2NEP_365days(SiteId,date_start,uStarTH,mSEBClosure,flag_cleaning)
% Call_fcrn_CO2Flux2NEP_last365days - Runs FCRN_CO2Flux2NEP for the past 365 days
%
% Syntax:
% [NEP,R,GEP,NEPgf,Rgf,GEPgf,RHat,GEPHat,RHat0,GEPHat0,cR,cGEP] = Call_fcrn_CO2Flux2NEP_last365days(SiteId,date_start,uStarTH,mSEBClosure,flag_cleaning)
%
% Second stage variables are loaded within the function. 
% Third stage variables are loaded according to flag_cleaning:
% flag_cleaning == 0 : load from database (default)
% flag_cleaning == 1 : Gap-fill backwards. 
%                      Load LAST year from database and append current year 
%                      from caller workspace 
%                      (to be used with third stage cleaning second year onward)
% flag_cleaning == 2 : Gap-fill forward. 
%                      Load current year from caller workspace and and append NEXT 
%                      from database 
%                      (to be used withing third stage cleaning for the first year of data)

% Feb 14, 2004 kai*
% Revisions:
% Aug 16, 2004 kai*
% - Introduced forward gap-filling for third stage

arg_default('flag_cleaning',0);

%-------------------------------------------------------------------------
% Determine time interval for gap filling
%-------------------------------------------------------------------------
dv = datevec(date_start);
Years = [dv(1)-1 dv(1)];

pth         = biomet_path('yyyy',SiteId,'clean\secondstage');

%-------------------------------------------------------------------------
% Load second stage (non-gap) filled data
%-------------------------------------------------------------------------
[PPFD,t]= read_db(Years,SiteId,'clean\secondstage','ppfd_downwelling_main');
Ta      = read_db(Years,SiteId,'clean\secondstage','air_temperature_main');
Ts      = read_db(Years,SiteId,'clean\secondstage','soil_temperature_2');
NEE     = read_db(Years,SiteId,'clean\secondstage','nee_main');
uStar   = read_db(Years,SiteId,'clean\secondstage','ustar_main');

% Cut out one year from start date backward
indOut = find(t > datenum(dv(1)-1,dv(2),dv(3),dv(4),dv(5),dv(6)+10) & ...
    t <= datenum(dv(1),dv(2),dv(3),dv(4),dv(5),dv(6)));
t     = t(indOut);
PPFD  = PPFD(indOut);
Ta    = Ta(indOut);
Ts    = Ts(indOut);
NEE   = NEE(indOut);
uStar = uStar(indOut);

%-------------------------------------------------------------------------
% Load third stage data (gap filled)
%-------------------------------------------------------------------------
if ~flag_cleaning
    try
        PPFDGF  = read_db(Years,SiteId,'clean\thirdstage','ppfd_downwelling_main');
        TaGF    = read_db(Years,SiteId,'clean\thirdstage','air_temperature_main');
        TsGF    = read_db(Years,SiteId,'clean\thirdstage','soil_temperature_2');
        pot_rad = read_db(Years,SiteId,'clean\thirdstage','radiation_downwelling_potential');
        PPFDGF  = PPFDGF(indOut);
        TaGF    = TaGF(indOut);
        TsGF    = TsGF(indOut);
        pot_rad = pot_rad(indOut);
    end
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
    
    % Fix yyyy when datestart = datenum(yyyy+1,1,1)
    if     date_start == datenum(dv(1),1,1) & flag_cleaning == 1    
        date_beg = datenum(dv(1)-1,1,1,0,29,50);
        date_end = datenum(dv(1),dv(2),dv(3),dv(4),dv(5),dv(6));
    elseif date_start ~= datenum(dv(1),1,1) & flag_cleaning == 1    
        date_beg = datenum(dv(1),1,1,0,29,50);
        date_end = datenum(dv(1),dv(2),dv(3),dv(4),dv(5),dv(6));
    elseif flag_cleaning == 2
        date_beg = datenum(dv(1)-1,dv(2),dv(3),dv(4),dv(5),dv(6));
        date_end = datenum(dv(1)-1,12,31,24,0,0);
    end

    ind_cur = find(tv_cur > date_beg & tv_cur <= date_end);
    ind_rep = find(t      > date_beg & t      <= date_end);
    
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
    case {'CR','OY','YF'}
        [NEP,R,GEP,NEPgf,Rgf,GEPgf,RHat,GEPHat,RHat0,GEPHat0,cR,cGEP] = ...
            FCRN_optimized_for_CR(t,NEE,uStar,PPFD,Ta,Ts,PPFDGF,TaGF,TsGF,isNight,uStarTH,mSEBClosure,[],[]); 
    otherwise
        [NEP,R,GEP,NEPgf,Rgf,GEPgf,RHat,GEPHat,RHat0,GEPHat0,cR,cGEP] = ...
            FCRN_CO2Flux2NEP(t,NEE,uStar,PPFD,Ta,Ts,PPFDGF,TaGF,TsGF,isNight,uStarTH,mSEBClosure,[],[]); 
end

return