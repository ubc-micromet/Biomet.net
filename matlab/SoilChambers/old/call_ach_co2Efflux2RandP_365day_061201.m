function [Efflux,R,P,Effluxgf,Rgf,Pgf,RHat,PHat,RHat0,PHat0,cR,cP,t] = call_ach_co2Efflux2RandP_365day(SiteId,date_start,flag_cleaning,chNum)
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
Efflux   = read_db(date_second,SiteId,'Chambers\clean\secondstage',['co2_efflux_main_ch' num2str(chNum)]);

indOut   = find(t >= date_beg & t <= date_end);

Efflux   = Efflux(indOut);
PPFD     = PPFD(indOut);

%-------------------------------------------------------------------------
% Load third stage data if needed (gap-filled data only!)
%-------------------------------------------------------------------------
if ~isempty(date_third)
    try
        [PPFDGF_db,t_db] = read_db(date_third,SiteId,'clean\thirdstage','ppfd_downwelling_main');
        TaGF_db          = read_db(date_third,SiteId,'clean\thirdstage','air_temperature_main');
        TsGF_db          = read_db(date_third,SiteId,'clean\thirdstage','soil_temperature_2');
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
    PPFDGF_cur  = evalin('caller','par_main');
    TaGF_cur    = evalin('caller','temp_air_main_BERMS');
    %Added Feb 14, 2006 - Dealing with bole chamber data at PA
    if SiteId == 'PA'
        if dv(1) < 2005
            if chNum == 3
                TsGF_cur    = evalin('caller','temp_bole_main_BERMS');
            else
                TsGF_cur    = evalin('caller','temp_soil_main_BERMS');
            end
        elseif dv(1) >= 2005
            if chNum == 1
                TsGF_cur    = evalin('caller','temp_bole_main_BERMS');
            else
                TsGF_cur    = evalin('caller','temp_soil_main_BERMS');
            end
        end
    else
        TsGF_cur    = evalin('caller','temp_soil_main_BERMS');
    end
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

%Using Ta and Ts gap filled all the way...
[Efflux,R,P,Effluxgf,Rgf,Pgf,RHat,PHat,RHat0,PHat0,cR,cP] = ...
    ach_co2Efflux2RandP(t,Efflux,PPFDGF,TaGF,TsGF,PPFDGF,TaGF,TsGF,isNight,[],[],SiteId); 

return