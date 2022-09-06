function export_fcrn_CO2Flux2NEP(SiteId,Years,uStarTH)

%export_fcrn_CO2Flux2NEP(SiteId,Years)
%
%function to init data for a call of FCRN_CO2Flux2NEP, export traces
%created august 2002, nk
%
%set fig_on = 1 for figures, 0 otherwise
%set export_on = 1 for export of traces, 0 otherwise

fig_on    = 0;
export_on = 1;

close all;

for i=1:length(Years)
    
% load data

pth         = biomet_path('yyyy',SiteId,'clean\secondstage');
pth_lin     = biomet_path('yyyy',SiteId,'clean\thirdstage');

t           = read_bor([pth 'clean_tv'],8,[],Years(i),[],1);
NEE         = read_bor([pth_lin 'nee_main'],[],[],Years(i),[],1);
uStar       = read_bor([pth_lin 'ustar_main'],[],[],Years(i),[],1);
PPFD        = read_bor([pth 'ppfd_downwelling_main'],[],[],Years(i),[],1);
Ta          = read_bor([pth 'air_temperature_main'],[],[],Years(i),[],1);
Ts          = read_bor([pth 'soil_temperature_2'],[],[],Years(i),[],1);
PPFDGF      = read_bor([pth_lin 'ppfd_downwelling_main'],[],[],Years(i),[],1);
TaGF        = read_bor([pth_lin 'air_temperature_main'],[],[],Years(i),[],1);
TsGF        = read_bor([pth_lin 'soil_temperature_2'],[],[],Years(i),[],1);
pot_rad     = read_bor([pth_lin 'radiation_downwelling_potential'],[],[],Years(i),[],1); % load data
isNight     = pot_rad == 0;
if ~exist('uStarTH') | isempty(uStarTH)
   uStarTH     = 0.35;
end

switch lower(SiteId)
   case 'pa', mSEBClosure = 1/1.15;
   case 'bs', mSEBClosure = 1/1.12;
   case 'jp', mSEBClosure = 1/1.18;
   otherwise, mSEBClosure = 1;
end

[NEP,R,GEP,NEPgf,Rgf,GEPgf,RHat,GEPHat,RHat0,GEPHat0,cR,cGEP] = FCRN_CO2Flux2NEP(t,NEE,uStar,PPFD,Ta,Ts,PPFDGF,TaGF,TsGF,isNight,uStarTH,mSEBClosure,[],[]); 
%[NEP,R,GEP,NEPgf,Rgf,GEPgf,RHat,GEPHat,RHat0,GEPHat0,cR,cGEP] = FCRN_CO2Flux2NEP_Version1_030812(t,NEE,uStar,PPFD,Ta,Ts,PPFDGF,TaGF,TsGF,isNight,uStarTH,FracSEBClosure,LogFile,Plots); 

%calculate additional traces

[nep_avg,ind_avg]   = runmean(12/1e6*86400.*NEPgf,48,48);
nep_avg             = nep_avg';
nep_avg2            = nep_avg(ones(1,48),:);
nep_avg2            = nep_avg2(:);
nep_avg_start       = nep_avg2(ones(1,11),1);
nep_filled_avg      = [nep_avg_start; nep_avg2(1:end-11)];
nep_filled_cum      = NaN*ones(size(t));
ind                 = find(~isnan(NEPgf));
nep_filled_cum(ind) = 12./1e6.*1800.* cumsum(NEPgf(ind));
[gep_avg,ind_avg]   = runmean(12/1e6*86400.*GEPgf,48,48);
gep_avg             = gep_avg';
gep_avg2            = gep_avg(ones(1,48),:);
gep_avg2            = gep_avg2(:);
gep_avg_start       = gep_avg2(ones(1,11),1);
gep_filled_avg      = [gep_avg_start; gep_avg2(1:end-11)];
gep_filled_cum      = NaN*ones(size(t));
ind                 = find(~isnan(GEPgf));
gep_filled_cum(ind) = 12./1e6.*1800.* cumsum(GEPgf(ind));
[r_avg,ind_avg]     = runmean(12/1e6*86400.*Rgf,48,48);
r_avg               = r_avg';
r_avg2              = r_avg(ones(1,48),:);
r_avg2              = r_avg2(:);
r_avg_start         = r_avg2(ones(1,11),1);
r_filled_avg        = [r_avg_start; r_avg2(1:end-11)];
r_filled_cum        = NaN*ones(size(t));
ind                 = find(~isnan(Rgf));
r_filled_cum(ind)   = 12./1e6.*1800.* cumsum(Rgf(ind));
                    

%----------------------------------------------------------
%export

if export_on

    pth_out = biomet_path(num2str(Years(i)),SiteId,'clean\ThirdStageFCRN');
    fi      = save_bor([pth_out(1:end-1) '\nep_measured'],1,NEP);
    fi      = save_bor([pth_out(1:end-1) '\nep_filled_with_fits'],1,NEPgf);
    fi      = save_bor([pth_out(1:end-1) '\nep_filled_avg'],1,nep_filled_avg);
    fi      = save_bor([pth_out(1:end-1) '\nep_filled_cum'],1,nep_filled_cum);
    fi      = save_bor([pth_out(1:end-1) '\eco_photosynthesis_measured'],1,GEP);
    fi      = save_bor([pth_out(1:end-1) '\eco_photosynthesis_fitted'],1,GEPHat);
    fi      = save_bor([pth_out(1:end-1) '\eco_photosynthesis_filled_with_fits'],1,GEPgf);
    fi      = save_bor([pth_out(1:end-1) '\eco_photosynthesis_filled_avg'],1,gep_filled_avg);
    fi      = save_bor([pth_out(1:end-1) '\eco_photosynthesis_filled_cum'],1,gep_filled_cum);
    fi      = save_bor([pth_out(1:end-1) '\eco_respiration_measured'],1,R);
    fi      = save_bor([pth_out(1:end-1) '\eco_respiration_fitted'],1,RHat);
    fi      = save_bor([pth_out(1:end-1) '\eco_respiration_filled_with_fits'],1,Rgf);
    fi      = save_bor([pth_out(1:end-1) '\eco_respiration_filled_avg'],1,r_filled_avg);
    fi      = save_bor([pth_out(1:end-1) '\eco_respiration_filled_cum'],1,r_filled_cum);

end

%----------------------------------------------------------
%figures

if fig_on

    t = FCRN_doy(t);

    figure;
    plot(t,Rgf,'b')
    ylab = [num2str(Years(i)) ' R gap filled'];
    ylabel(ylab);
    zoom on;
    figure;
    plot(t,GEPgf,'b')
    ylab = [num2str(Years(i)) ' GEP gap filled'];
    ylabel(ylab);
    zoom on;
    figure;
    plot(t,NEPgf,'b')
    ylab = [num2str(Years(i)) ' NEP gap filled'];
    ylabel(ylab);
    zoom on;
    figure;
    plot(t,RHat0,'b',t,RHat,'r',t,R,'g.')
    ylab = [num2str(Years(i)) ' R'];
    ylabel(ylab);
    zoom on;
    figure;
    plot(t,GEPHat0,'b',t,GEPHat,'r',t,GEP,'g.')
    ylab = [num2str(Years(i)) ' GEP'];
    ylabel(ylab);
    zoom on;
    figure;
    plot(t,cR,'b')
    ylab = [num2str(Years(i)) ' cR'];
    ylabel(ylab);
    zoom on;
    figure;
    plot(t,cGEP,'b')
    ylab = [num2str(Years(i)) ' cGEP'];
    ylabel(ylab);
    zoom on;
    figure;
    plot(t,r_filled_avg,'b')
    ylab = [num2str(Years(i)) ' R avg'];
    ylabel(ylab);
    zoom on;
    figure;
    plot(t,gep_filled_avg,'b')
    ylab = [num2str(Years(i)) ' GEP avg'];
    ylabel(ylab);
    zoom on;
    figure;
    plot(t,nep_filled_avg,'b')
    ylab = [num2str(Years(i)) ' NEP avg'];
    ylabel(ylab);
    zoom on;
    figure;
    plot(t,r_filled_cum,'b')
    ylab = [num2str(Years(i)) ' R cum'];
    ylabel(ylab);
    zoom on;
    figure;
    plot(t,gep_filled_cum,'b')
    ylab = [num2str(Years(i)) ' GEP cum'];
    ylabel(ylab);
    zoom on;
    figure;
    plot(t,nep_filled_cum,'b')
    ylab = [num2str(Years(i)) ' NEP cum'];
    ylabel(ylab);
    zoom on;

end

end %loop years

return