function [npp_trace, npp_total, a_new, ra, rh] = fr_npp_trace(Xyear,SiteID,style_,step_,figure_,cue_upper,cue_lower);

% This function calculates a half-hourly or a cumulative NPP trace
% (npp_trace) based on EC measurements (3rd stage only), yearly NPP
% (npp_total), heterotrophic (rh) and autotrophic respiration (ra)
% (hhour fluxes) as well as the ratio of autotrophic to TER (a_new).
% Calculations are based on a parametric bootstrap and constrained using
% CUE values from the literature (see Griffis et al. (2004) Fig. 8 in AFM).
%
% Note: This function takes time viz. > 10^6 RNG calls!!!
%
% Arguements:
%
% Xyear  - Numerical year.
% SiteID - 2 letter site abbr.
% style_ - Controls output mode and cleaning environment.
%          Possible values are: 0 - npp_trace is half-hourly (umol CO2/m2/sec) (default)
%                               1 - npp_trace is cumulative sum (g C/m2/yr)
%                               2 - 3rd stage cleaning mode
% step_  - Sets the time step for the ratio of NEP/ER.  The default is monthly.
%          Read thru the function body before changing this.
%          Possible values are: 1 - hhour
%                               2 - day
%                               3 - week
%                               4 - month (default)
%                               5 - year
% figure_ - Toggles graphic output, e.g., cumulative NPP (g C/m2/yr) with NEP, P,
% R_E, R_a, and R_h. "1" will display the figures, "0" (default value) will not.  
%
% "cue_upper" and "cue_lower" refer to CUE thresholds used to get endpoints 
% of the R_a/ER uniform distribution.  Read thru the function before altering
% these values.

% (c) Christopher Schwalm     Dec 06, 2004

error(nargchk(2,7,nargin));     %correct # of args?
SiteID = upper(SiteID);         %CAPS only
arg_default('style_',0);        %default output style is hhour trace in umol CO2/m2/sec
arg_default('step_',4);         %default to monthly nep/er ratios
arg_default('figure_',0);       %default is no figure
arg_default('cue_upper',0.60);  %default upper limit on CUE from Gifford (1994) Aust. J. Plant Physiol. 21:1-15. 
arg_default('cue_lower',0.47);  %default lower limt on CUE from Waring et al. (1998) Tree Physiol. 18:129-134.

disp(' ');
disp(['Estimating NPP for ' SiteID ' in ' num2str(Xyear) ' via parametric bootstrap constrained using CUE...']);
disp(' ');

%load data
if (style_ == 2) %cleaning mode
    tv  = evalin('caller','clean_tv');
    nep = evalin('caller','nep_main');
    psn = evalin('caller','eco_photosynthesis_main');
    er  = evalin('caller','eco_respiration_main');
else
    pth = biomet_path('yyyy',SiteID,'Clean\ThirdStage');
    tv  = read_bor([pth 'clean_tv'],8,[],Xyear,[],1);
    try
        nep = read_bor([pth 'nep_main'],[],[],Xyear,[],1); 
    catch
        nep = read_bor([pth 'nep_filled_with_fits'],[],[],Xyear,[],1);  
    end
    
    try
        er = read_bor([pth 'eco_respiration_main'],[],[],Xyear,[],1); 
    catch
        try
            er = read_bor([pth 'eco_respiration_filled_with_fits'],[],[],Xyear,[],1);
        catch
            er = read_bor([pth 'eco_respiration'],[],[],Xyear,[],1);
        end
    end
    
    try
        psn = read_bor([pth 'eco_photosynthesis_main'],[],[],Xyear,[],1); 
    catch
        psn = read_bor([pth 'eco_photosynthesis_filled_with_fits'],[],[],Xyear,[],1);  
    end
end

%resync tv
[t] = fr_get_doy(tv,0);
max_doy = t(length(t)-1);
t = t-0.020833;
t(length(t)) = max_doy;

%track impossible values in incomplete years (current year or yr of establishment)
flag_future = zeros(length(t),1); %vector to hold impossible data: future part of current year
flag_nodata = zeros(length(t),1); %vector to hold impossible data: before site establishment
tm = datevec(now);
gs = fcrn_gapsize(nep);
if tm(1) == Xyear | max(gs>672)
    ind_future = find(t > fr_get_doy(now) & tm(1) == Xyear);
    ind_nodata = find(t(gs>672) & tm(1) ~= Xyear); %no data for two weeks in a row assumed to catch years of site establishment
    flag_future(ind_future) = 1;
    flag_nodata(ind_nodata) = 1;
    step_ = 5;
    disp('Defaulting to yearly NEP/ER ratio for incomplete year.');
end

%make sure traces have no missing values
ind_dub = find(isnan(nep)); flag_dub = zeros(length(t),1); flag_dub(ind_dub) = 1;
bad_data = find(flag_future==0 & flag_nodata==0 & flag_dub==1);
if length(bad_data)>0
    temp = FCRN_nanmean(nep);
    nep(bad_data) = temp;
    disp(['Substituting annual mean for all ' num2str(length(bad_data)) ' NaN values in hhour NEP!']);
end
clear ind_dub; clear flag_dub;

ind_dub = find(isnan(er)); flag_dub = zeros(length(t),1); flag_dub(ind_dub) = 1;
bad_data = find(flag_future==0 & flag_nodata==0 & flag_dub==1);
if length(bad_data)>0
    temp = FCRN_nanmean(er(find(er>=0)));
    er(bad_data) = temp;
    disp(['Substituting annual mean for all ' num2str(length(bad_data)) ' NaN values in hhour ecorespiration!']);
end
clear ind_dub; clear flag_dub;
zero_data = find(er<0);
if length(zero_data)>0
    disp(['Setting ' num2str(length(zero_data)) ' negative values in hhour ecorespiration to zero!']);
    er(zero_data)=0;
    clear zero_data;
end

ind_dub = find(isnan(psn)); flag_dub = zeros(length(t),1); flag_dub(ind_dub) = 1;
bad_data = find(flag_future==0 & flag_nodata==0 & flag_dub==1);
if length(bad_data)>0
    temp = FCRN_nanmean(psn(find(psn>=0)));
    psn(bad_data) = temp;
    disp(['Substituting annual mean for all ' num2str(length(bad_data)) ' NaN values in hhour photosynthesis!']);
end
zero_data = find(psn<0);
if length(zero_data)>0
    disp(['Setting ' num2str(length(zero_data)) ' negative values in hhour photosynthesis to zero!']);
    psn(zero_data)=0;
    clear zero_data;
end

%create empty NPP and a
npp = zeros(length(t),1); 
a_mean = zeros(length(t),1); 

% setp up r based on desired temporal scale
try
    switch step_
        case 1 %-- hhourly
            r_hh = nep./er; 
            r = r_hh;
        case 2 %-- daily
            r_day = fastavg(nep,48)./fastavg(er,48); 
            r_day = (ones(48,1)*r_day');
            r_day = r_day(:); 
            r = r_day;
        case 3 %-- weekly
            r_wk = fastavg(nep,48*7)./fastavg(er,48*7); % not 1:1 correspondance with calendar weeks but identical for all practical purposes)
            r_wk = (ones(ceil(length(t)/52),1)*r_wk');
            r_wk = r_wk(:);
            r = r_wk;
        case 4 %-- monthly
            r_mth = fastavg(nep,ceil(length(t)/12))./fastavg(er,ceil(length(t)/12)); % not 1:1 correspondance with calendar months but identical for all practical purposes)
            r_mth = (ones(length(t)/12,1)*r_mth');
            r_mth = r_mth(:);
            r = r_mth;
        case 5 %-- yearly
            r_year = FCRN_nanmean(nep)./FCRN_nanmean(er);
            r_year = r_year.*ones(length(t),1);
            r = r_year;
        otherwise
            disp('Invalid step_ argument, using monthly NEP/ER ratios...');
            r_mth = fastavg(nep,ceil(length(t)/12))./fastavg(er,ceil(length(t)/12)); % not 1:1 correspondance with calendar months but identical for all practical purposes)
            r_mth = (ones(length(t)/12,1)*r_mth');
            r_mth = r_mth(:);
            r = r_mth;
    end
catch
    r_year = FCRN_nanmean(nep)./FCRN_nanmean(er);
    r_year = r_year.*ones(length(t),1);
    r = r_year;
    disp('NEP/ER ratio returned a NaN, using yearly NEP/ER ratio...');
end

%dub in yearly r for bogus r values, resize
bad_r = find(r<= -1 | isnan(r)); 
r(bad_r) = mean(nep)./mean(er);
r = r(1:length(t));

%setup loop
tic
count = 0; %tracks # of many RNG calls
for ind = 1:length(t);
    %check for actual data using NaNs...  NaN's at this point indicate no data possible
    if isnan(nep(ind))
        npp(ind) = NaN;
        %check for non-nighttime --must have p to have npp (this is driven by the
        %mathematics and not by biology per se)
    elseif  psn(ind) == 0 | nep(ind)+er(ind) == 0
        npp(ind) = 0;
    else
        %assuming p occurs that day --continue to invert eq from Fig. 8 in Griffis et al.
        %(2004) in press: cue_lower,upper = 1 - ( a/1+r ), where r is the ratio of NEP over
        %RE, and a is ratio of autotrophic to ecosystem respiration.  a has the same temporal
        %scale as r.  Solve for a at the endpoints of CUE and constrain a to be (0.1, 0.9).
        a_upper = (1 + r(ind))*(1 - cue_lower); 
        a_lower = (1 + r(ind))*(1 - cue_upper); 
        if a_upper < 0.1
            a_upper = 0.1; a_lower = 0.075;
        else
            a_upper = min([a_upper 0.9]);
            a_lower = min([ 0.875  max([a_lower 0.1]) ]);
        end
        count = count+1;
        %Note: a is inversely proportional to CUE so the "upper" and "lower" tags are
        %switched!!!  Assume a~U(a_lower,a_upper) THEN use a parametric bootstrap with
        %ntrials = 100 to calculate NPP as follows: npp = p ( (1 - a_bootstrap)/(1 + r) )
        %Note: the mathematics preclude mighttime NPP as P = 0!  Also, using NEP -
        %ER is unhelpful as nighttime NEP = ER (EC measures ER at night).
        B = 100; %number of bootstrap replicates/samples per datum
        npp_bootstrap = zeros(B,1); %create empty vectors
        a_boostrap = zeros(B,1);
        for i = 1:B;
            a_bootstrap(i) = a_lower + ((a_upper - a_lower) * rand(1)); %offsets RNG so numbers are along required interval and not (0,1)
            cue = 1 - (a_bootstrap(i)/(1 + r(ind)));
            cue = max([cue 0]); %cue must be positive
            npp_bootstrap(i) = psn(ind)*cue; 
        end %end for bootstrap loop
        npp(ind)    = mean(npp_bootstrap);
        a_mean(ind) = mean(a_bootstrap); %always zero at night!!!
    end %end nan and psn check
end %end setup loop
time_ = toc;
disp(' ');
disp([ num2str(B*count) ' RNG function callls in ' num2str(time_) ' seconds.']);
disp(' ');

%track non-nans (relevant for incomplete calendar yrs only and figure output)
ind_data = find(~isnan(npp));

%output NPP tracebased on _style
if style_ == 1
    npp_trace = [cumsum(npp(ind_data))*1800*0.000012011]; %convert umol CO2/m2/s to g C/m2/yr
else
    npp_trace = [npp]; % half-hourly fluxes
end

%output NPP total
if nargout > 1
    temp = cumsum(npp(ind_data))*1800*0.000012011;
    npp_total = temp(end);
end

%output the rest
ind_bad         = find(a_mean==0); %nighttime is not the right time... (r is undefined at night and therefore so is a)
a_mean(ind_bad) = NaN;
a_new           = ta_interp_points(a_mean,48); %make interval long enough to cover any night
ra              = er.*a_new;
rh              = er.*(1-a_new);

%figure ? 
if figure_ == 1
    %graph cumulative traces
    npp = cumsum(npp(ind_data))*1800*0.000012011;
    nep = cumsum(nep(ind_data))*1800*0.000012011;
    er  = cumsum( er(ind_data))*1800*0.000012011;
    ra  = cumsum( ra(ind_data))*1800*0.000012011;
    rh  = cumsum( rh(ind_data))*1800*0.000012011;
    p   = cumsum(psn(ind_data))*1800*0.000012011;
    df  = er-(ra+rh);
    figure;
    plot(t,nep,'b',t,er,'r',t,p,'k',t,npp,'g',t,ra,'w',t,rh,'y','LineStyle','-','LineWidth',2);
    axis([1,365,-Inf,+Inf])
    ylabel('Cumulative flux (g C m^{-2})');
    xlabel('Day of year');
    legend('NEP', 'R_{E}', 'P', 'NPP','R_{a}','R_{h}',2);
    title(['Site: ' SiteID ' Year: ' num2str(Xyear)]);
    zoom on;
    figure;
    plot(t,a_new,'b');
    axis([1,365,-Inf,1])
    ylabel('R_{a}/R_{E}');
    xlabel('Day of year');
    title(['Site: ' SiteID ' Year: ' num2str(Xyear) ' Yearly R_{a}/R_{E}: ' num2str(mean(a_new))]);
    figure;
    plot(t,r,'r');
    axis([1,365,-1,1])
    ylabel('NEP/R_{E}');
    xlabel('Day of year');
    title(['Site: ' SiteID ' Year: ' num2str(Xyear)]);
    figure;
    plot(t,df,'m-');
    axis([1,365, -Inf, +Inf])
    ylabel('Difference between main R_{E} and bootstrap R_h + R_a');
    xlabel('Day of year');
    title(['Site: ' SiteID ' Year: ' num2str(Xyear)]);
end