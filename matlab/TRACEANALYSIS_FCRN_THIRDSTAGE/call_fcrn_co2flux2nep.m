function [NEP,R,GEP,NEPgf,Rgf,GEPgf,RHat,GEPHat,RHat0,GEPHat0,cR,cGEP] = call_fcrn_CO2Flux2NEP(SiteId,Year)

%function to init data for a call of FCRN_CO2Flux2NEP
%[NEP,R,GEP,NEPgf,Rgf,GEPgf,RHat,GEPHat,RHat0,GEPHat0,cR,cGEP] = call_fcrn_CO2Flux2NEP(SiteId,Year)

% load data

pth         = biomet_path('yyyy',SiteId,'clean\secondstage');
pth_lin     = biomet_path('yyyy',SiteId,'clean\thirdstage');

t           = read_bor([pth 'clean_tv'],8,[],Year,[],1);
NEE         = read_bor([pth_lin 'nee_main'],[],[],Year,[],1);
uStar       = read_bor([pth_lin 'ustar_main'],[],[],Year,[],1);
PPFD        = read_bor([pth 'ppfd_downwelling_main'],[],[],Year,[],1);
Ta          = read_bor([pth 'air_temperature_main'],[],[],Year,[],1);
% Read soil_temperature_main in an earlier version
Ts          = read_bor([pth 'soil_temperature_2'],[],[],Year,[],1);
PPFDGF      = read_bor([pth_lin 'ppfd_downwelling_main'],[],[],Year,[],1);
TaGF        = read_bor([pth_lin 'air_temperature_main'],[],[],Year,[],1);
% Read soil_temperature_main in an earlier version
TsGF        = read_bor([pth_lin 'soil_temperature_2'],[],[],Year,[],1);
pot_rad     = read_bor([pth_lin 'radiation_downwelling_potential'],[],[],Year,[],1); % load data
isNight     = pot_rad == 0;
uStarTH     = 0.35;

switch lower(SiteId)
   case 'pa', mSEBClosure = 1/1.15;
   case 'bs', mSEBClosure = 1/1.12;
   case 'jp', mSEBClosure = 1/1.18;
   otherwise, mSEBClosure = 1/1.18;
end


[NEP,R,GEP,NEPgf,Rgf,GEPgf,RHat,GEPHat,RHat0,GEPHat0,cR,cGEP] = FCRN_CO2Flux2NEP(t,NEE,uStar,PPFD,Ta,Ts,PPFDGF,TaGF,TsGF,isNight,uStarTH,mSEBClosure,[],[]); 

[NEP,R,GEP,NEPgfm,Rgfm,GEPgfm,RHatm,GEPHatm,RHat0m,GEPHat0m,cRm,cGEPm] = FCRN_CO2Flux2NEP_Ver1_030812(t,NEE,uStar,PPFD,Ta,Ts,PPFDGF,TaGF,TsGF,isNight,uStarTH,mSEBClosure,[],[]); 
%[NEP,R,GEP,NEPgf,Rgf,GEPgf,RHat,GEPHat,RHat0,GEPHat0,cR,cGEP]  = FCRN_CO2Flux2NEP_Ver1_030812(t,NEE,uStar,PPFD,Ta,Ts,PPFDGF,TaGF,TsGF,isNight,uStarTH,mSEBClosure,[],[]); 

t = FCRN_doy(t);

close all;
figure;
plot(t,Rgf,'b',t,Rgfm,'r')
ylabel('R gap filled');
zoom on;
figure;
plot(t,GEPgf,'b',t,GEPgfm,'r')
ylabel('GEP gap filled');
zoom on;
figure;
plot(t,NEPgf,'b',t,NEPgfm,'r')
ylabel('NEP gap filled');
zoom on;
figure;
plot(t,RHat0,'b',t,RHat,'r',t,RHatm,'g',t,R,'k.')
ylabel('R');
zoom on;
figure;
plot(t,GEPHat0,'b',t,GEPHat,'r',t,GEPHatm,'g',t,GEP,'k.')
ylabel('GEP');
zoom on;
figure;
plot(t,cR,'b',t,cRm,'r')
ylabel('cR');
zoom on;
figure;
plot(t,cGEP,'b',t,cGEPm,'g')
ylabel('cGEP');
zoom on;

return