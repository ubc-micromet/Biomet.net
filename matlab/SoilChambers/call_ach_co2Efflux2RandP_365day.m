function [Efflux,R,P,Effluxgf,Rgf,Pgf,RHat,PHat,RHat0,PHat0,t] = call_ach_co2Efflux2RandP_365day(SiteId,date_start,flag_cleaning,chNum,use_mvwin)
%-------------------------------------------------------------------------
% Determine time interval for gap filling: always ONE full year (365 days)
%-------------------------------------------------------------------------
date_beg    = datenum(date_start,1,1,0,30,0);
date_end    = datenum(date_start+1,1,1,0,0,0);
date_second = [date_start];
date_third  = [];

arg_default('use_mvwin',0);  % do not use moving window approach to gap-fill
%-------------------------------------------------------------------------
% Load and trim second stage non-gap-filled data
%-------------------------------------------------------------------------
pth  = biomet_path(date_start,SiteId,'clean\secondstage\');
pth2 = biomet_path(date_start,SiteId);
pth2 = [pth2 'Chambers\clean\secondstage\'];

t = read_bor([pth 'clean_tv'],8);
PPFD = read_bor([pth 'ppfd_downwelling_main'],1);
Efflux   = read_bor([pth2 'co2_efflux_main_ch' num2str(chNum)],1);

indOut   = find(t >= date_beg & t <= date_end);

Efflux   = Efflux(indOut);
PPFD     = PPFD(indOut);

%-------------------------------------------------------------------------
% Load data from caller workspace (gap-filled data only!)
%-------------------------------------------------------------------------
    tv_cur      = evalin('caller','clean_tv');
    PPFDGF_cur  = evalin('caller','par_main');

    if SiteId == 'YF'
        TaGF_cur    = evalin('caller','temp_air_main_climate');
    else
        TaGF_cur    = evalin('caller','temp_air_main_BERMS');
    end
    %Added Feb 14, 2006 - Dealing with bole chamber data at PA
    if SiteId == 'PA'
        if date_start < 2005
            if chNum == 3
                TsGF_cur    = evalin('caller','temp_bole_main_BERMS');
            else
                TsGF_cur    = evalin('caller','temp_soil_main_BERMS');
            end
        elseif date_start >= 2005
            if chNum == 1
                TsGF_cur    = evalin('caller','temp_bole_main_BERMS');
            else
                TsGF_cur    = evalin('caller','temp_soil_main_BERMS');
            end
        end
    elseif SiteId == 'YF'
        TsGF_cur    = evalin('caller','temp_soil_main_climate');        
    else
        TsGF_cur    = evalin('caller','temp_soil_main_BERMS');
    end
    pot_rad_cur = evalin('caller','radiation_downwelling_potential');
  
%-------------------------------------------------------------------------
% Splice together and trim data from caller workspace and third stage data
%-------------------------------------------------------------------------    
PPFDGF  = [PPFDGF_cur];
TaGF    = [TaGF_cur];
TsGF    = [TsGF_cur];
pot_rad = [pot_rad_cur];

PPFDGF  = PPFDGF(indOut);
TaGF    = TaGF(indOut);
TsGF    = TsGF(indOut);
pot_rad = pot_rad(indOut);

%-------------------------------------------------------------------------
% Run gap filling
%-------------------------------------------------------------------------
isNight     = pot_rad == 0;

%Using Ta and Ts gap filled all the way...
[Efflux,R,P,Effluxgf,Rgf,Pgf,RHat,PHat,RHat0,PHat0] = ...
    ach_co2Efflux2RandP(t,Efflux,PPFDGF,TaGF,TsGF,PPFDGF,TaGF,TsGF,isNight,[],[],SiteId,chNum,use_mvwin); 

return