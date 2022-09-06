function fr_biomet_sites_report(Years,SiteId,TRACE,TYPE,Y_LABEL,PERIOD,NAN,NONEG,PATH,numdays,doy_data,web_flag);
% Data visualization tool for the BERMS sites. Generates one graph for each
% site that shows cumulative traces OR 14-day running means for each site year 
% excluding the year of establishment.  If no arguments are specified gapfilled 
% NEP is cumsum'd and displayed.  Also, for cumsum'd traces the totals are
% displayed within the legend.
%
%  Function based on fr_berms_report and fr_bcfn_report by Christopher
%  Schwalm. (c) Oct 3, 2005 
%  Modifications for nicer plots and consolidation for use with
%  any biomet site by Nick Grant, Oct 2007 and Oct 2008.

%
% Arguments:
%
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

% 10-day avg, daytime GEP:
% fr_biomet_sites_report(2000:2008,'BS','eco_photosynthesis_filled_with_fits',5,'10-day mean GEP',2,3,0,[],10,[],0); 
% fr_biomet_sites_report(2000:2008,'BS','eco_respiration_filled_with_fits',0,'Cumulative R',0,0,0,[],[],[],0);

% 10-day avg, 24 h avg R:
% fr_biomet_sites_report(2000:2008,'BS','eco_respiration_filled_with_fits',5,'10-day mean R',3,3,0,[],10,[],0);

% fr_biomet_sites_report(2000:2008,'BS','air_temperature_main',8,'10-day mean T_{air} (\circC)',0,0,0,[],10,[],0);
% fr_biomet_sites_report(2000:2008,'BS','soil_temperature_main',8,'10-day mean T_{soil} (\circC)',0,0,0,[],10,[],0);
% fr_biomet_sites_report(2000:2008,'BS','ppfd_downwelling_main',6,'10-day mean PAR',2,3,0,[],10,[],0);
% fr_biomet_sites_report(2000:2008,'BS','precipitation',4,'Precipitation (mm)',0,0,0,[],[],[],0);


arg_default('PATH','Clean\ThirdStage');
current = datevec(now-14);
current = current(1);
arg_default('NONEG',0);
arg_default('TYPE',0);
arg_default('PERIOD',0);
arg_default('NAN',0);

arg_default('numdays',14);

doy_now = floor(now-datenum(Years(end),1,0));
arg_default('doy_data',doy_now);

PERIOD = PERIOD-1; % see switch PERIOD below
WHAT = 0; % default is cumsum'd traces
iPeriod = []; % i*'s set up figure name
iWhat = 'Cumulative ';

%set up no arg default and other default args
if nargin == 0 
    arg_default('Y_LABEL','Cumulative NEP');
    arg_default('TRACE','nep_filled_with_fits');
elseif TYPE < 5
    arg_default('Y_LABEL','Cumulative trace');
else
    arg_default('Y_LABEL',[ num2str(numdays) '-day running mean']);
    WHAT = 1;
    iWhat = [ num2str(numdays) '-day running mean '];
    arg_default('NAN',3);
end

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

% for ii = 2;   % commented out to allow user defined site and years Nick,
%                  Oct 2, 2007
%              
%     
%     %site specifics; ID and first full yr after establishment
%     switch ii
%         case 1
%             Years = 1999:2005;
%             SiteId = 'PA';
%         case 2
%             Years = 2000:2007;
%             SiteId = 'BS';
%         case 3
%             Years = 2000:2003;
%             SiteId = 'JP';
%             % Note: The HJP sites and FEN are currently disabled due to data
%             % quality and availabilty issues. Try reenabling in 2006.
%         case 4
%             Years = 2004:current;
%             SiteId = 'HJP02';
%         case 5
%             Years = 2005:current;
%             SiteId = 'HJP75';
%         case 6
%             Years = 2003:current;
%             SiteId = 'FEN';
%     end
    
    %load data
    [DATA, TV] = read_db(Years,SiteId,PATH,TRACE);
    
    %reshape data: each column is one yr
    [DATA_MAT,DOY,TV_MAT] = reshape_year(TV,DATA);
    
    %calculate missing values based on NAN flag
    switch NAN
        case 0
            KILL_NAN = FCRN_nanmedian(DATA_MAT); % yearly non-NaN median
        case 1
            KILL_NAN = FCRN_nanmean(DATA_MAT);  % yearly non-NaN mean
        case 2
            KILL_NAN = zeros(size(DATA_MAT,2),1)'; % zero'd out
        case 3
            KILL_NAN = NaN.*zeros(size(DATA_MAT,2),1)'; % leave as is (mainly for runmean'd traces)
    end
    
    %replace NaNs with missing value rule for all yr
    for j = 1:size(DATA_MAT,2)
        
        %IND_NAN = find(isnan(DATA_MAT(:,j)) & TV_MAT(:,j) < now); 
       
        % use last day of data in database rather than "now" 
        IND_NAN = find(isnan(DATA_MAT(:,j)) & TV_MAT(:,j) < datenum(Years(end),1,doy_data)); 
        
        DATA_MAT(IND_NAN,j)=KILL_NAN(j);
    end
    
    %replace negative values with zero based on NONEG
    if NONEG == 1
        for j = 1:size(DATA_MAT,2)
            IND_NEG = find(DATA_MAT(:,j)<0);
            DATA_MAT(IND_NEG,j)=0;
        end
    end
    
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
            DATA_MAT = DATA_MAT.*RAD;
        otherwise % full day (default)
    end
    
    %cumsum or runmean data based on WHAT
    switch WHAT
        case 0
            DATA_FIG = cumsum(DATA_MAT).*CF;
        case 1
            [DATA_FIG,ind] = runmean(DATA_MAT,numdays.*48,numdays.*48); % Nick modified to allow for user defined averaging window
            DATA_FIG = DATA_FIG.*CF;
            DOY = DOY(ind);
    end
    
    %set up legend
    dv = datevec(TV_MAT(1,1:length(Years)));
    iWhen = cellstr(num2str(dv(:,1))); 
    %set up cumsum'd totals to display on figure
    if TYPE < 5 
        iDub = cell(length(Years),1);
        for nn = 1:length(Years); iDub{nn} = '   ';  end %just a spacer between the yr and total
        for nn = 1:length(Years);
            ind_last = find(isnan(DATA_FIG(:,nn)));
            try
                ind_last = ind_last(1)-1;
            catch
                ind_last = size(DATA_FIG,1);
            end
            try
                iTot(nn) = DATA_FIG(ind_last,nn);
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
    figName = strcat([iWhat,char(iPeriod),TRACE,' at ',SiteId]);
    
    %draw figure
    
    % use two colour schemes to highlight current year
    
    % all colours
    c_all = [ [0 0 0.75];
             [ 0.000 0.000 0.502 ];
             [ 0.502 0.000 1.000 ];  
             [1 0 1]; 
             [0 1 0];
             [0 1 1]; 
             [ 1.000 0.502 0.000 ];
             [1 0 0]; 
             [ 0.502 0.251 0.000 ];
             [ 0.000 0.502 0.251 ]; 
             [ 0.502 0.000 0.502 ];
             [ 0.502 0.502 0.502 ]; 
             [ 0.000 0.000 0.502 ]    ];
    
    c_all = c_all(1:length(Years),:); % trim to proper length
    
    % all grey with one year highlighted in black
    c_one = [ 0 0 0 ];
    %c_one = [ 0.000 0.251 0.502 ];
    for k=1:length(Years-1)
        c_one = [ c_one; [ 0.753 0.753 0.753 ]; ];
    end
    
    if web_flag % produce plots for web
        figure('Name',figName);
        

        %figure('Name',[ figName ' ' num2str(Years(end)) ]);
        hp1 = subplot('Position',subplot_position(2,1,1));
        plot(DOY,DATA_FIG(:,1:length(Years)),'LineWidth',1.5);
        axis([1 365 -Inf +Inf]);
        %xlabel('DOY');
        hy=ylabel([Y_LABEL ' ' Y_UNITS]);
        set(hy,'position',[-32.22 -25 1.00011]);
        title([SiteId ' ' num2str(Years(end))]);
        hh = get(gca,'Children');
        [tick_val,tick_label] = monthtick(DOY);
        set(gca,'XTick',tick_val,'XTickLabel','');
        for k=1:length(hh),set(hh(k),'Color',c_one(k,:)); end
        %hl = legend(iOut(end),2,'FontSize',12);
        hp2 = subplot('Position',subplot_position(2,1,2));
        plot(DOY,DATA_FIG(:,1:length(Years)),'LineWidth',1.5);
        axis([1 365 -Inf +Inf]);
        hl = legend(iOut,2);
        set(hl,'FontSize',12);
        hh = get(gca,'Children');
        for k=1:length(hh),set(hh(k),'Color',c_all(k,:)); end
        set(gca,'XTick',tick_val,'XTickLabel',tick_label);
        
    else % plot for powerpoint slides
        figure('Name',figName);
        plot(DOY,DATA_FIG(:,1:length(Years)),'LineWidth',1.5);
        axis([1 365 -Inf +Inf]);
        xlabel('DOY');
        ylabel([Y_LABEL ' ' Y_UNITS]);
        title([SiteId ' from ' num2str(Years(1)) ' to ' num2str(Years(end))]);
        hl = legend(iOut,2);
        set(hl,'FontSize',12);
        hh = get(gca,'Children');
        for k=1:length(hh),set(hh(k),'Color',c_all(k,:)); end

        figure('Name',[ figName ' ' num2str(Years(end)) ]);
        plot(DOY,DATA_FIG(:,1:length(Years)),'LineWidth',1.5);
        axis([1 365 -Inf +Inf]);
        xlabel('DOY');
        ylabel([Y_LABEL ' ' Y_UNITS]);
        title([SiteId ' ' num2str(Years(end))]);
        %hl = legend(iOut,2);
        hh = get(gca,'Children');
        for k=1:length(hh),set(hh(k),'Color',c_one(k,:)); end
        %end

    end
    
    