function [NEP,R,GEP,NEPgf,Rgf,GEPgf,RHat,GEPHat,RHat0,GEPHat0,cR,cGEP,t] = Call_fcrn_CO2Flux2NEP_365days_nsgfwstdds(SiteId,date_start,wstdTH,mSEBClosure,flag_cleaning)
% Call_fcrn_CO2Flux2NEP_last365days - Runs FCRN_CO2Flux2NEP for the past 365 days
%
% Syntax:
% [NEP,R,GEP,NEPgf,Rgf,GEPgf,RHat,GEPHat,RHat0,GEPHat0,cR,cGEP] 
%       = Call_fcrn_CO2Flux2NEP_last365days(SiteId,date_start,uStarTH,mSEBClosure,flag_cleaning)
%
% Second stage variables are loaded within the function. 
% Third stage variables are loaded according to flag_cleaning:
% flag_cleaning == 1 : Gap-fill backwards. 
%                      Load LAST year from database and append current year 
%                      from caller workspace 
%                      (to be used with third stage cleaning second year onward)
% flag_cleaning == 2 : Gap-fill forward. 
%                      Load current year from caller workspace and and append NEXT 
%                      from database 
%                      (to be used within third stage cleaning for the first year of data)

% Feb 14, 2004 kai*
% Revisions:
% Aug 16, 2004 kai*
% - Introduced forward gap-filling for third stage
% Sep 27, 2004 crs  Removed 'flag_cleaning == 0 : load from database
% (default)'  This program is ALWAYS called in Third Stage cleaning!  Fixed
% data wrapping and reorganized program...
% March 2006 
% soil_temperature_2 were replaced with soil_temperature_main
% * praveena
%-------------------------------------------------------------------------
% Determine time interval for gap filling: always ONE full year (365 days)
%-------------------------------------------------------------------------
dv = datevec(date_start); 
% Note: date_start is an unfortunate name, it is not the 'start' of
% anything, just a time marker!!!  date_start is used in all 3rd stage ini
% files currently...

% Adjust dates based on cleaning flag and dv. Four dates are tracked:
%   date_beg - start of 1 yr period
%   date_end - end of 1 yr period
%   date_second - what 2nd stage data to get (yr only)
%   date_third  - what 3rd stage data is needed (yr only)

% A full calendar year exists and is being cleaned, e.g., CR in 2001
if  date_start == datenum(dv(1),1,1) & flag_cleaning == 1   
    date_beg    = datenum(dv(1)-1,1,1,0,30,0);
    date_end    = datenum(dv(1),1,1,0,0,0);
    date_second = [dv(1)-1];
    date_third  = [];
% The current year is being cleaned, future data is missing so everything is pushed back to get a full year        
elseif date_start ~= datenum(dv(1),1,1) & flag_cleaning == 1
    date_end    = date_start;
    date_beg    = datenum(dv(1)-1,dv(2),dv(3),0,30,0);
    date_second = [dv(1)-1 dv(1)];
    date_third  = dv(1)-1;
 % The first year of a site is being cleaned, e.g., OY in 2000. The partial yr is combined with the part of next yr to get a full yr        
elseif flag_cleaning == 2
    date_beg    = datenum(dv(1)-1,dv(2),dv(3),0,30,0); 
    date_end    = datenum(dv(1),dv(2),dv(3),0,0,0); 
    date_second = [dv(1)-1 dv(1)];
    date_third  = dv(1);
end

%-------------------------------------------------------------------------
% Load and trim second stage non-gap-filled data
%-------------------------------------------------------------------------
pth      = biomet_path('yyyy',SiteId,'clean\secondstage');
[PPFD,t] = read_db(date_second,SiteId,'clean\secondstage','ppfd_downwelling_main');
Ta       = read_db(date_second,SiteId,'clean\secondstage','air_temperature_main');
Ts       = read_db(date_second,SiteId,'clean\secondstage','soil_temperature_main');
NEE      = read_db(date_second,SiteId,'clean\secondstage','nee_main');
wstd    = read_db(date_second,SiteId,'Flux\Clean','wind_speed_w_std_before_rot_csat');
indOut   = find(t >= date_beg & t <= date_end);
t        = t(indOut);
PPFD     = PPFD(indOut);
Ta       = Ta(indOut);
Ts       = Ts(indOut);
NEE      = NEE(indOut);
wstd    = wstd(indOut);

%-------------------------------------------------------------------------
% Load third stage data if needed (gap-filled data only!)
%-------------------------------------------------------------------------
if ~isempty(date_third)
    try
        [PPFDGF_db,t_db] = read_db(date_third,SiteId,'clean\thirdstage','ppfd_downwelling_main');
        TaGF_db          = read_db(date_third,SiteId,'clean\thirdstage','air_temperature_main');
        TsGF_db          = read_db(date_third,SiteId,'clean\thirdstage','soil_temperature_main');
        pot_rad_db       = read_db(date_third,SiteId,'clean\thirdstage','radiation_downwelling_potential');
    end
else
    PPFDGF_db  = [];
    TaGF_db    = [];
    TsGF_db    = [];
    pot_rad_db = [];
end

%-------------------------------------------------------------------------
% Load data from caller workspace (gap-filled data only!)
%-------------------------------------------------------------------------
    tv_cur      = evalin('caller','clean_tv');
    PPFDGF_cur  = evalin('caller','ppfd_downwelling_main');
    TaGF_cur    = evalin('caller','air_temperature_main');
    TsGF_cur    = evalin('caller','soil_temperature_main');
    pot_rad_cur = evalin('caller','radiation_downwelling_potential');
    
%-------------------------------------------------------------------------
% Splice together and trim data from caller workspace and third stage data
%-------------------------------------------------------------------------    
if flag_cleaning == 2
    PPFDGF  = [PPFDGF_cur ; PPFDGF_db];
    TaGF    = [TaGF_cur ; TaGF_db];
    TsGF    = [TsGF_cur; TsGF_db];
    pot_rad = [pot_rad_cur; pot_rad_db];
else
    PPFDGF  = [PPFDGF_db ; PPFDGF_cur];
    TaGF    = [TaGF_db ; TaGF_cur];
    TsGF    = [TsGF_db; TsGF_cur];
    pot_rad = [pot_rad_db; pot_rad_cur];
end
PPFDGF  = PPFDGF(indOut);
TaGF    = TaGF(indOut);
TsGF    = TsGF(indOut);
pot_rad = pot_rad(indOut);

%-------------------------------------------------------------------------
% Run gap filling
%-------------------------------------------------------------------------
isNight     = pot_rad == 0;
threshold_const = 4

switch upper(SiteId)
    case {'CR','OY','YF'}
        [NEP,R,GEP,NEPgf,Rgf,GEPgf,RHat,GEPHat,RHat0,GEPHat0,cR,cGEP] = ...
            FCRN_optimized_for_CR_nsgfwstdds(t,NEE,wstd,PPFD,Ta,Ts,PPFDGF,TaGF,TsGF,isNight,wstdTH,mSEBClosure,[],[]); 
    otherwise
%         [NEP,R,GEP,NEPgf,Rgf,GEPgf,RHat,GEPHat,RHat0,GEPHat0,cR,cGEP] = ...
%             FCRN_CO2Flux2NEP_nsgfwstdds(t,NEE,wstd,PPFD,Ta,Ts,PPFDGF,TaGF,TsGF,isNight,wstdTH,mSEBClosure,['IH_gfresults_nsgfwstdds_' num2str(dv(1)-1) '.txt'],[]); 
        [NEP,R,GEP,NEPgf,Rgf,GEPgf,RHat,GEPHat,RHat0,GEPHat0,cR,cGEP] = ...
            FCRN_CO2Flux2NEP_nsgfwstdds(t,NEE,wstd,PPFD,Ta,Ts,PPFDGF,TaGF,TsGF,isNight,wstdTH,mSEBClosure,[],[]); 
end

return