function [NEP_FIG,GEP_FIG,R_FIG,NEP_MONTHLY,GEP_MONTHLY,R_MONTHLY,DOY,iOut]=calc_nep_gep_r_for_web_display(SiteId,Years,doy_data,bwfig);

%Years=1999:2011;
%SiteId = 'BS';

% TRACE   - The database name of any trace that can be logically cumsum'd or runmean'd.
% TYPE    - Specifies the type of trace; controls cumsum vs runmean and y-axis units.
%           Possible values: 0 - Cumsum CO2 fluxes (umol CO2/m2/sec => g C/m2/yr), e.g., nep_main (default)
%                            1 - Cumsum latent heat (W/m2 => kg H2O/m2/yr),  e.g., le_mdv_main
%                            2 - Cumsum PPFD-type traces (umol/m2/sec => mol/m2/yr), e.g., ppfd_absorbed
%                            3 - Cumsum radiation, energy budget (W/m2 => MJ/m2/yr), e.g., radiation_downwelling_potential
%                            4 - Cumsum anything else (YMMV), e.g., precipitation
%                            5 - Runmean half-hourly CO2 fluxes (umol CO2/m2/s), e.g., nep_measured
%                            6 - Runmean half-hourly traces with base units (umol/m2/sec), e.g., ppfd_diffuse
%                            7 - Runmean half-hourly traces with base units (W/m2), e.g., soil_heat_flux_main
%                            8 - Runmean anything else (YMMV), e.g., air_temperature_main
% Y_LABEL - A string put into Matlab's ylabel command.  Do NOT include units unless TYPE is "4" OR "8".
%           If left blank 'Cumulative trace' or '14-day running mean' is used by default.
% PERIOD  - Controls which part of the 24h day is cumsum'd.
%           Possible values: 0 - Full 24h day (default)
%                            1 - Nighttime
%                            2 - Daytime
% NAN     - Determines how the function deals with NaNs.
%           Possible values: 0 - Yearly non-NaN median (default for cumsum'd traces)
%                            1 - Yearly non-NaN mean
%                            2 - Missing values are set to zero
%                            3 - Missing values are left as NaNs (default for runmean'd traces)
% NONEG   - Controls whether negative values are set to zero.  For example, setting NONEG to "1"
%           on 'eco_photosynthesis_main' will force the function to replace all negative fluxes
%           with zero.  NONEG is off by default (value is "0").
% PATH    - Directory that points function to data.  Default is 'Clean\ThirdStage'.
%
% NUMDAYS - user set number of days for averaging traces
%
% DOY_DATA - previously any NaN's that existed in the cumulative traces had been replaced up until "now"
%            this made for bad plots where a users database had not been
%            updated until present (such as a database on a users home PC
%            that was not updated to "now"). DOY_DATA allows the user to
%            specify the date where this NaN filling should stop.
% 
% Example:
% hhourly cumulative plots and 10 day averaging 
% fr_biomet_sites_report(2000:2008,'BS','nep_filled_with_fits',0,'Cumulative NEP',0,0,0,[],[],[],0);
% fr_biomet_sites_report(2000:2008,'BS','nep_filled_with_fits',5,'10-day mean NEP',3,3,0,[],10,[],0);
% fr_biomet_sites_report(2000:2008,'BS','eco_photosynthesis_filled_with_fits',0,'Cumulative GEP',0,0,0,[],[],[],0);
% fr_biomet_sites_report(2000:2008,'BS','eco_photosynthesis_filled_with_fits',5,'10-day mean GEP',3,3,0,[],10,[],0);
% fr_biomet_sites_report(2000:2008,'BS','eco_respiration_filled_with_fits',0,'Cumulative R',0,0,0,[],[],[],0);
% fr_biomet_sites_report(2000:2008,'BS','eco_respiration_filled_with_fits',5,'10-day mean R',3,3,0,[],10,[],0);
% fr_biomet_sites_report(2000:2008,'BS','air_temperature_main',8,'10-day mean T_{air} (\circC)',0,0,0,[],10,[],0);
% fr_biomet_sites_report(2000:2008,'BS','soil_temperature_main',8,'10-day mean T_{soil} (\circC)',0,0,0,[],10,[],0);
% fr_biomet_sites_report(2000:2008,'BS','ppfd_downwelling_main',6,'10-day mean PAR',2,3,0,[],10,[],0);
% fr_biomet_sites_report(2000:2008,'BS','precipitation',4,'Precipitation (mm)',0,0,0,[],[],[],0);

% Years=1999:2008;
% SiteId = 'BS';

if ~ismember(SiteId,{'HP09' 'HP11' 'MPB1' 'MPB2' 'MPB3'})
   PATH = 'Clean\ThirdStage';
else
    PATH = '\Flux_logger\computed_fluxes\web_plot_traces';
end
current = datevec(now-14);
current = current(1);
%NONEG=0;
TYPE=0;
PERIOD=0;
NAN=2;
numdays=14;

arg_default('bwfig',0);

doy_now = floor(now-datenum(Years(end),1,0));
arg_default('doy_data',doy_now);

PERIOD = PERIOD-1; % see switch PERIOD below
WHAT = 0; % default is cumsum'd traces
iPeriod = []; % i*'s set up figure name
iWhat = 'Cumulative ';

%set up no arg default and other default args
Y_LABEL= 'Cumulative NEP';
TRACE = {'nep_filled_with_fits' 'eco_photosynthesis_filled_with_fits' 'eco_respiration_filled_with_fits'};

%set up conversion factor and units based on TYPE
switch TYPE
    %cumsum'd traces
    case 0 
        CF = 1800*12e-6; %half-hourly CO2 fluxes umol/m2/s to g C/m2/yr, e.g., nep_main
        Y_UNITS = '(g C m^{-2})';
    case 1
        CF = 1800/2.5e6; %for half-hourly latent heat only; from W/m2 to kg H2O/m2/yr, e.g., le_mdv_main
        Y_UNITS = '(kg H_2O m^{-2})'; %is equivalent to mm/yr
    case 2
        CF = 1800/10^6; %half-hour umol to cumsum'd mol yr, e.g., ppfd_absorbed
        Y_UNITS = '(mol m^{-2})';
    case 3
        CF = 1800/10^6; %half-hour W/m2 (J/m2/s) to MJ/m2/yr, e.g., radiation_downwelling_potential
        Y_UNITS = '(MJ m^{-2})';
    case 4
        CF = 1;
        Y_UNITS = []; % everything else (specify units as desired)
        %runmean traces
    case 5
        CF = 1;
        Y_UNITS = '(\mumol CO_2 m^{-2} s^{-1})'; %half-hourly CO2 fluxes umol/m2/s
    case 6
        CF = 1;
        Y_UNITS = '(\mumol m^{-2} s^{-1})'; %half-hourly anything with base units umol/m2/s EXCEPT CO2 fluxes
    case 7
        CF = 1;
        Y_UNITS = '(W m^{-2}'; %half-hourly anything with base units W/m2
    case 8
        CF = 1;
        Y_UNITS = []; % everything else (specify units as desired)
        
end

switch upper(SiteId)
    case {'BS','PA','HJP02','HJP75','HP09'}
        GMTshift = 6/24;
    case {'CR','YF','OY','MPB1','MPB2','MPB3'}
        GMTshift = 8/24;
    case {'HP11'}
        GMTshift = 5/24;
end


%load data
%[DATA, TV] = read_db(Years,SiteId,PATH,TRACE);
[NEP, TV] = read_db(Years,SiteId,PATH,TRACE{1});
[GEP, TV] = read_db(Years,SiteId,PATH,TRACE{2});
[R, TV] = read_db(Years,SiteId,PATH,TRACE{3});

%reshape data: each column is one yr
%[DATA_MAT,DOY,TV_MAT] = reshape_year(TV,DATA);
[NEP_MAT, DOY, TV_MAT] = reshape_year(TV,NEP);
[GEP_MAT, DOY, TV_MAT] = reshape_year(TV,GEP);
[R_MAT, DOY, TV_MAT] = reshape_year(TV,R);

DV_MAT = datevec(TV_MAT);

DOY = DOY - GMTshift;
%calculate missing values based on NAN flag
switch NAN
    case 0
        %KILL_NAN = FCRN_nanmedian(DATA_MAT); % yearly non-NaN median
        KILL_NANNEP = FCRN_nanmedian(NEP_MAT);
        KILL_NANGEP = FCRN_nanmedian(GEP_MAT);
        KILL_NANR = FCRN_nanmedian(R_MAT);
    case 1
        %KILL_NAN = FCRN_nanmean(DATA_MAT);  % yearly non-NaN mean
        KILL_NANNEP = FCRN_nanmean(NEP_MAT);
        KILL_NANGEP = FCRN_nanmean(GEP_MAT);
        KILL_NANR = FCRN_nanmean(R_MAT);
    case 2
        %KILL_NAN = zeros(size(DATA_MAT,2),1)'; % zero'd out
        KILL_NANNEP = zeros(size(NEP_MAT,2),1)';
        KILL_NANGEP = zeros(size(GEP_MAT,2),1)';
        KILL_NANR = zeros(size(R_MAT,2),1)';
    case 3
        %KILL_NAN = NaN.*zeros(size(DATA_MAT,2),1)'; % leave as is (mainly for runmean'd traces)
        KILL_NANNEP = NaN.*zeros(size(NEP_MAT,2),1)';
        KILL_NANGEP = NaN.*zeros(size(GEP_MAT,2),1)';
        KILL_NANR = NaN.*zeros(size(R_MAT,2),1)';
end

%replace NaNs with missing value rule for all yr
for j = 1:size(NEP_MAT,2)
    
    %IND_NAN = find(isnan(DATA_MAT(:,j)) & TV_MAT(:,j) < now); 
    
    % use last day of data in database rather than "now" 
    IND_NEPNAN = find(isnan(NEP_MAT(:,j)) & TV_MAT(:,j) < datenum(Years(end),1,doy_data)); 
    
    NEP_MAT(IND_NEPNAN,j)=KILL_NANNEP(j);
end

for j = 1:size(GEP_MAT,2)
    
    %IND_NAN = find(isnan(DATA_MAT(:,j)) & TV_MAT(:,j) < now); 
    
    % use last day of data in database rather than "now" 
    IND_GEPNAN = find(isnan(GEP_MAT(:,j)) & TV_MAT(:,j) < datenum(Years(end),1,doy_data)); 
    
    GEP_MAT(IND_GEPNAN,j)=KILL_NANNEP(j);
end

for j = 1:size(R_MAT,2)
    
    %IND_NAN = find(isnan(DATA_MAT(:,j)) & TV_MAT(:,j) < now); 
    
    % use last day of data in database rather than "now" 
    IND_RNAN = find(isnan(R_MAT(:,j)) & TV_MAT(:,j) < datenum(Years(end),1,doy_data)); 
    
    R_MAT(IND_RNAN,j)=KILL_NANR(j);
end

%replace negative values with zero based on NONEG
% if NONEG == 1
%     for j = 1:size(DATA_MAT,2)
%         IND_NEG = find(DATA_MAT(:,j)<0);
%         DATA_MAT(IND_NEG,j)=0;
%     end
% end

%load, reshape, and apply radiation data based on PERIOD
switch PERIOD
    % "0" is nighttime only; "1" is daytime only
    case {0,1}
        %             RAD         = read_db(Years,SiteId,PATH,'ppfd_downwelling_main');
        %             iDay        = find(RAD>0);
        %             iNight      = find(RAD<=0);
        % Nick changed to use potential_dw rad since PAR can be a small
        % number but still >0 during nighttime due to sensor drift
        RAD         = read_db(Years,SiteId,PATH,'radiation_downwelling_potential');
        iDay        = find(RAD>0);
        iNight      = find(RAD<=0);
        %iNaN        = find(isnan(RAD) & TV < now);
        iNaN        = find(isnan(RAD) & TV < datenum(Years(end),1,doy_data)); 
        RAD(iNaN)   = 0;
        RAD(iDay)   = PERIOD;
        RAD(iNight) = abs(PERIOD-1);
        iPeriod = {'nighttime ' , 'daytime '};
        iPeriod = iPeriod(PERIOD+1);
        % set zeros to NaNs for runmean's traces
        if TYPE > 4 
            IND_FLIP = find(RAD==0);
            RAD(IND_FLIP)=NaN;
        end
        RAD = reshape_year(TV,RAD);
        %DATA_MAT = DATA_MAT.*RAD;
        NEP_MAT = DATA_MAT.*RAD;
        GEP_MAT = DATA_MAT.*RAD;
        R_MAT = DATA_MAT.*RAD;
    otherwise % full day (default)
end

NEP_FIG       = cumsum(NEP_MAT).*CF;
%[NEP_MONTHLY] = calc_cumdata_monthly(NEP_FIG,Years,DOY); 
[NEP_MONTHLY] = calc_cumdata_monthly(NEP_FIG,Years,DV_MAT);
GEP_FIG       = cumsum(GEP_MAT).*CF;
%[GEP_MONTHLY] = calc_cumdata_monthly(GEP_FIG,Years,DOY); 
[GEP_MONTHLY] = calc_cumdata_monthly(GEP_FIG,Years,DV_MAT);
R_FIG         = cumsum(R_MAT).*CF;
%[R_MONTHLY]   = calc_cumdata_monthly(R_FIG,Years,DOY);
[R_MONTHLY]   = calc_cumdata_monthly(R_FIG,Years,DV_MAT); 
%set up legend
dv = datevec(TV_MAT(1,1:length(Years)));
iWhen = cellstr(num2str(dv(:,1))); 
%set up cumsum'd totals to display on figure

if TYPE < 5 
    iDub = cell(length(Years),1);
    for nn = 1:length(Years); iDub{nn} = '   ';  end %just a spacer between the yr and total
    for nn = 1:length(Years);
        ind_last = find(isnan(NEP_FIG(:,nn)));
        try
            ind_last = ind_last(1)-1;
        catch
            ind_last = size(NEP_FIG,1);
        end
        try
            iTot(nn) = NEP_FIG(ind_last,nn);
        catch
            iTot(nn) = NaN;
        end
    end
    iTot = iTot';
    iTot = cellstr(num2str(round(iTot)));
    iOut = strcat(iWhen,iDub,iTot);
    clear iTot;
    %just years in legend if runmean'd trace  
else
    iOut = iWhen;
end

%set up figure name
figName = strcat([iWhat,char(iPeriod),'cumNEP and monthly NEP, GEP and R at ' SiteId]);

% %draw figure
% 
% % use two colour schemes to highlight current year
% 
% % all colours
% 
%     
% c_all = [     [1 0 0];
%               [0 0 1];
%               [0 1 0];
%               [0 1 1]; 
%             [ 1.000 0.502 0.000 ];
%             [ 0.502 0.251 0.000 ];
%             [ 0.000 0.502 0.251 ]; 
%            [ 0.502 0.000 0.502 ];
%             [ 0.502 0.502 0.502 ]; 
%            [ 0.000 0.000 0.502 ]; 
%            [ 0.000 0 0.750 ];
%            [ 0.000 0.000 0.251 ];  
%            [ 0.502 0.000 1.000 ]  ];
% 
% c_bw = [[0 0 0];
%         [0 0 0]
%         [0.3 0.3 0.3];
%         [0.3 0.3 0.3];
%         [0.3 0.3 0.3];
%         [0.3 0.3 0.3];
%         [.649 .649 .649]
%         [.649 .649 .649]
%         [.649 .649 .649];
%         [.649 .649 .649]  
%         [.649 .649 .649]];
%     %c_bw=flipud(c_bw);    
% lwi  = [ 3 2 2 2 2 2 2 2 2 2 2];
% lsty = {':','--','-.','-',':','--','-.','-','-.','-'};
% lsty = flipud(lsty');
% 
% c_all = c_all(1:length(Years),:); % trim to proper length
% 
% if WHAT == 0 % if cumulative data is being plotted, then also present monthly bar graphs
%     colordef('white');
%     %figure('Name',[ figName ' by month' ]);
% %     figure('unit','inches','PaperPosition',[.05 .05 8.5 11],...
% %     'position',[0.05    0.25    7.5    10]);
%     figure('unit','inches','PaperPosition',[0 0 4 3.75]);
%     wd = 0.82;
%     ht = 0.20;
%     xleft = 0.16;
%     pos1 = [xleft 0.68 wd 1.5*ht];
%     pos2 = [xleft .47 wd ht];
%     pos3 = [xleft .26 wd ht];
%     pos4 = [xleft .05 wd ht];
%     
%     hb1 = subplot('Position',pos1);
%     %plot(DOY,DATA_FIG(:,1:length(Years)-1),'LineWidth',2); hold on;
%     %plot(DOY,DATA_FIG(:,end),'LineWidth',3); hold on;
%     plot(DOY,NEP_FIG(:,1:length(Years)-1),'LineWidth',2); hold on;
%     plot(DOY,NEP_FIG(:,end),'LineWidth',2); hold on;
%     %axis([1 365 -Inf +Inf]);
%     %xlabel('DOY');
%     ylabel('g C m^{-2}','FontSize',10);
%     HLEG = legend(iOut,'location','SouthWest');
%     set(HLEG,'FontSize',8);
%     legend(gca,'boxoff');
%     hh = get(gca,'Children');
%     if ~bwfig
%        for k=1:length(hh),set(hh(k),'Color',c_all(k,:)); end
%     else
%        for k=1:length(hh),set(hh(k),'Color',c_bw(k,:),'linestyle',lsty{k},'linewidth',lwi(k)); end
%     end
%     [tick_val,tick_label] = monthtick(DOY,1);
% 	
%     doy=DOY';
%     yt1=get(gca,'Yticklabel');
%     set(hb1,'Yticklabel',yt1,'FontSize',10);
%     set(hb1,'XTick',tick_val,'XTickLabel','');
%     set(hb1,'Xlim',[min(floor(DOY)) max(ceil(DOY))]);
%     ylim1 = get(hb1,'YLim');
%     labofst1 = abs(ylim1(2)-ylim1(1))/8;
%     %text(304,ylim1(2)-labofst1,'NEP_{csum}','FontSize',16);
%     text(304,ylim1(2)-labofst1,'NEP_{csum}','FontSize',8);
% 
%     
%     hb2 = subplot('Position',pos2);
%     difftick = diff(tick_val)./2;
%     r2 = bar(tick_val(1:12)+difftick,NEP_MONTHLY,'grouped');
%     hh = get(gca,'Children');
%     for k=1:length(hh),set(hh(k),'FaceColor',c_all(k,:),'EdgeColor',c_all(k,:)); end
%     set(hb2,'XTick',tick_val,'XTickLabel','');
%     set(hb2,'Xlim',[min(floor(DOY)) max(ceil(DOY))]);
%     set(hb2,'YTick',[ -30 -20 -10 0]);
%     set(hb2,'YTickLabel',[ -30 -20 -10 0],'FontSize',10);
%     ylabel('g C m^{-2}','FontSize',10);
%     ylim2 = get(hb2,'YLim');
%     labofst2 = abs(ylim2(2)-ylim2(1))/8;
%     %text(304,ylim2(1)+labofst2,'NEP','FontSize',16);
%     text(304,ylim2(1)+labofst2,'NEP','FontSize',10);
%     hax1 = gca;
%     hax2=axes('position',get(gca,'position'), 'visible','off');
%    
%     hb3 = subplot('Position',pos3);
%     difftick = diff(tick_val)./2;
%     r3 = bar(tick_val(1:12)+difftick,GEP_MONTHLY,'grouped');
%     hh = get(gca,'Children');
%     for k=1:length(hh),set(hh(k),'FaceColor',c_all(k,:),'EdgeColor',c_all(k,:)); end
%     set(hb3,'XTick',tick_val,'XTickLabel','');
%     set(hb3,'Xlim',[min(floor(DOY)) max(ceil(DOY))]);
%     ylabel('g C m^{-2}','FontSize',10);
%     ylim3 = get(hb3,'YLim');
%     
%     set(gca,'layer','top');
%    
%     hb4 = subplot('Position',pos4);
%     difftick = diff(tick_val)./2;
%     r4 = bar(tick_val(1:12)+difftick,R_MONTHLY,'grouped');
%     hh = get(gca,'Children');
%     for k=1:length(hh),set(hh(k),'FaceColor',c_all(k,:),'EdgeColor',c_all(k,:)); end
%     set(hb4,'Ylim',[min(min(floor(R_MONTHLY'))) max(max(ceil(R_MONTHLY')))]);
%     ylabel('g C m^{-2}','FontSize',10);
%     set(hb4,'XTick',tick_val,'XTickLabel','');
%     
%     set(hb4,'Xlim',[min(floor(DOY)) max(ceil(DOY))]);
%     ylim4 = get(hb4,'YLim');
%     
%     month = ['J' 'F' 'M' 'A' 'M' 'J' 'J' 'A' 'S' 'O' 'N' 'D'];
%     yaxmin = min(get(hb4,'YLim'));
%     for j = 1:12; text(tick_val(j)+difftick(j),yaxmin-0.001, month(j),'HorizontalAlignment','center',...
%             'VerticalAlignment','top','FontSize',10);  
%     end
%     set(gca,'layer','top');
%    
%     
%     % reset axis limits for monthly NEP
%     set(hb2,'YLim',ylim2);
%     
%     % set common axis limits for GEP and R
%     ylim_comn = [0 max(ylim3(2),ylim4(2)) ];
%     
%     
%     
%     labofst3 = abs(ylim_comn(2)-ylim_comn(1))/8;
%     set(hb3,'YLim',ylim_comn);
%     set(hb3,'YTick',[0 20 40]);
%     set(hb3,'YTickLabel',[0 20 40],'FontSize',10);
%     set(hb4,'YLim',ylim_comn);
%     set(hb4,'YTick',[0 20 40]);
%     set(hb4,'YTickLabel',[0 20 40],'FontSize',10);
%     
%     
%     axes(hb3);
%     %text(304,ylim_comn(2)-labofst3,'GEP','FontSize',16);
%     text(304,ylim_comn(2)-labofst3,'GEP','FontSize',10);
%     axes(hb4);
%     %text(304,ylim_comn(2)-labofst3,'\itR\rm','FontSize',16);
%     text(304,ylim_comn(2)-labofst3,'\itR\rm','FontSize',10);
%     
% end

% -----------------------------------
% internal functions
% -----------------------------------

function DATA_MONTHLY = calc_cumdata_monthly(DATA_FIG,Years,DV_MAT);

DATA_MONTHLY   = NaN*ones(12,length(Years));
year_mat = reshape(DV_MAT(:,1),size(DATA_FIG,1),length(Years));
month_mat = reshape(DV_MAT(:,2),size(DATA_FIG,1),length(Years));
for k=1:length(Years)
    for month=1:12
        ind = find(year_mat(:,k)==Years(k)& month_mat(:,k)==month);
        DATA_MONTHLY(month,k) = DATA_FIG(ind(end),k) - DATA_FIG(ind(1),k);
    end
end

