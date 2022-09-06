function ON_GR_HF_test(CurrentDate)

%CurrentDate = datenum(2005,7,26,20,0,0);
CurrentDate = fr_round_hhour(CurrentDate);
DataPath = 'E:\Site_DATA\ON_GR\Met-data\data\';
CSIPath = 'E:\Site_DATA\ON_GR\Met-data\database\2005\ON_TP\Clean\ThirdStage\';
tv_experiment = fr_round_hhour(datenum(2005,8,1):1/48:datenum(2005,8,15));
Nspectra = 13;

% tv       = read_bor(fullfile(CSIPath,'clean_tv'),8);
% Tair_all = read_bor(fullfile(CSIPath,'air_temperature_main'));
RMYoung  = 0;
% RMYoung  = read_bor(fullfile(CSIPath,'wind_speed_cup_main'));
% percip   = read_bor(fullfile(CSIPath,'precipitation'));
% RH       = read_bor(fullfile(CSIPath,'relative_humidity_main'));
% ind = find(CurrentDate == tv);
% Tair = Tair_all(ind);
% RMYoung = RMYoung(ind);

DateS = [datestr(CurrentDate-4/24) ', Local time'];

FileNameX = fr_datetofilename(CurrentDate);
FileNameS = fr_datetofilename(CurrentDate-4/24);

if exist(fullfile(DataPath,FileNameX(1:6))) == 7 
    DataFullPath = [fullfile(DataPath,FileNameX(1:6)) '\'];
else
    DataFullPath = DataPath;
end



XSITE_SONIC = fr_read_digital2_file([DataFullPath FileNameX '.dx5']);
XSITE_IRGA  = fr_read_digital2_file([DataFullPath FileNameX '.dx8']);
XSITE_TC    = fr_read_digital2_file([DataFullPath FileNameX '.dx16']);

dv = datevec(fr_round_hhour(CurrentDate-datenum(0,0,0,0,0,1),3));
ONGR_fileName = sprintf('ts_data_%4i_%02i_%02i_%02i%02i.dat',dv(1),dv(2),dv(3),dv(4),dv(5));
SITE_CR5000 = csvread(fullfile(DataFullPath,ONGR_fileName),4,2);

SITE_SONIC  = SITE_CR5000(:,[1:3 6 10]) ;
SITE_IRGA   = SITE_CR5000(:,[4 5 8 9]) ;
SITE_TC     = SITE_CR5000(:,7);
SITE_E     = SITE_CR5000(:,16);
SITE_Tair   = SITE_CR5000(:,15);
Tair = SITE_Tair;
SITE_Pair   = SITE_CR5000(:,12);

if any(isnan(XSITE_SONIC)) | any(isnan(SITE_SONIC))
     plotSonic = 0;
else
    plotSonic = 1;
    nx = linspace(0,1800,length(XSITE_SONIC));
    ns = linspace(0,1800,length(SITE_SONIC));
    delayX_SONIC  = fr_delay(XSITE_SONIC(:,3),SITE_SONIC(:,3),5000);
end

if any(any(isnan(XSITE_IRGA))) | any(any(isnan(SITE_IRGA)))
     plotIRGA = 0;
else
    plotIRGA = 1;
    nx_irga = linspace(0,1800,length(XSITE_IRGA));
    ns_irga = linspace(0,1800,length(SITE_IRGA));
    % For ON_GR use the same delay as for the sonic (Kai say so!)
    delayX_IRGA   = delayX_SONIC+7;
%    delayX_IRGA   = fr_delay(XSITE_IRGA (:,1),SITE_IRGA (:,1),5000);
end


nt = linspace(0,1800,length(XSITE_TC));

fig=0;

% fig=fig+1;
% figure(fig)
% TitleText = [ 'Rain events,  ' DateS];
% set(fig,'Name',TitleText)
% ind_rain = find(percip>0);
% timeDiff = tv(ind_rain)-CurrentDate;
% %ind_rain = find(min(timeDiff(ind_rain)));  % find the closest rain event
% stem(tv(ind_rain),percip(ind_rain),'o');ax=axis;line([1 1]*CurrentDate,[0 ax(4)],'linewidth',3)
% datetick('x')
% title(TitleText)
% zoom on;
% 
% fig=fig+1;
% figure(fig)
% TitleText = [ 'RH,  ' DateS];
% set(fig,'Name',TitleText)
% [junk,junk,ind_experiment] = intersect(tv_experiment,tv);
% plot(tv(ind_experiment),RH(ind_experiment));ax=axis;line([1 1]*CurrentDate,[ax(3) ax(4)],'linewidth',3)
% datetick('x')
% title(TitleText)
% zoom on;
% 
% fig=fig+1;
% figure(fig)
% TitleText = [ 'Tair,  ' DateS];
% set(fig,'Name',TitleText)
% [junk,junk,ind_experiment] = intersect(tv_experiment,tv);
% plot(tv(ind_experiment),Tair_all(ind_experiment));ax=axis;line([1 1]*CurrentDate,[ax(3) ax(4)],'linewidth',3)
% datetick('x')
% title(TitleText)
% zoom on;

fig=fig+1;
figure(fig)
TitleText = [ 'RH,  ' DateS];
set(fig,'Name',TitleText)
plot(ns_irga,SITE_E./sat_vp(Tair)*100);
title(TitleText)
zoom on;

fig=fig+1;
figure(fig)
TitleText = [ 'Tair,  ' DateS];
set(fig,'Name',TitleText)
plot(ns_irga,Tair);
title(TitleText)
zoom on;

fig=fig+1;
figure(fig)
TitleText = [ 'Pair,  ' DateS];
set(fig,'Name',TitleText)
plot(ns_irga,SITE_Pair);
title(TitleText)
zoom on;


if plotIRGA
	
	fig=fig+1;
	figure(fig)
    TitleText = [ 'Tbench,  ' DateS];
    set(fig,'Name',TitleText)
	plot(nx_irga+delayX_IRGA/20,XSITE_IRGA(:,4),ns_irga,SITE_IRGA(:,3));
	title(TitleText)
	zoom on;
	legend( sprintf('XSITE: %5.2f (%5.2f) ^oC',mean(XSITE_IRGA(:,4)),std(XSITE_IRGA(:,4))),...
            sprintf('SITE : %5.2f (%5.2f) ^oC',mean(SITE_IRGA (:,3)),std(SITE_IRGA (:,3)))...
           )
	
	fig=fig+1;
	figure(fig)
    TitleText = [ 'Plicor,  ' DateS];
    set(fig,'Name',TitleText)
	plot(nx_irga+delayX_IRGA/20,XSITE_IRGA(:,5),ns_irga,SITE_IRGA(:,4));
	title(TitleText)
	zoom on;
	legend( sprintf('XSITE: %5.2f (%5.2f) kPa',mean(XSITE_IRGA(:,5)),std(XSITE_IRGA(:,5))),...
            sprintf('SITE : %5.2f (%5.2f) kPa',mean(SITE_IRGA (:,4)),std(SITE_IRGA (:,4)))...
           )
	
	fig=fig+1;
	figure(fig)
    TitleText = [ 'H_2O,  ' DateS];
    set(fig,'Name',TitleText)
	meanH2O = mean(XSITE_IRGA(:,2));
	plot(nx_irga+delayX_IRGA/20,detrend(XSITE_IRGA(:,2),0)+meanH2O,ns_irga,detrend(SITE_IRGA(:,2),0)+meanH2O);
	title(TitleText)
	zoom on;
	legend( sprintf('XSITE: %5.2f (%5.2f) mmol/mol',mean(XSITE_IRGA(:,2)),std(XSITE_IRGA(:,2))),...
            sprintf('SITE : %5.2f (%5.2f) mmol/mol',mean(SITE_IRGA (:,2)),std(SITE_IRGA (:,2)))...
           )
	
	fig=fig+1;
	figure(fig)
    TitleText = ['CO_2,  ' DateS];
    set(fig,'Name',TitleText)
	meanCO2 = mean(XSITE_IRGA(:,1));
	plot(nx_irga+delayX_IRGA/20,detrend(XSITE_IRGA(:,1),0)+meanCO2,ns_irga,detrend(SITE_IRGA(:,1),0)+meanCO2);
	title(TitleText)
	zoom on;
	legend( sprintf('XSITE: %5.2f (%5.2f) ppm',mean(XSITE_IRGA(:,1)),std(XSITE_IRGA(:,1))),...
            sprintf('SITE : %5.2f (%5.2f) ppm',mean(SITE_IRGA (:,1)),std(SITE_IRGA (:,1)))...
           )

	fig=fig+1;
	figure(fig)
    TitleText = ['PSD of CO_2,  ' DateS];
    set(fig,'Name',TitleText)
    psd(detrend(XSITE_IRGA(:,1)),2^Nspectra,20.234)
    hold on
    psd(detrend(SITE_IRGA(:,1)),2^Nspectra,20.234)
    hold off
	title(TitleText)
	zoom on;
    legend('XSITE','SITE')    
    h = get(fig,'chi');
    h1 = get(h(2),'chi');
    set(h1(2),'color',[1 0 0])
    
	fig=fig+1;
	figure(fig)
    TitleText = ['PSD of H_2O,  ' DateS];
    set(fig,'Name',TitleText)
    psd(detrend(XSITE_IRGA(:,2)),2^Nspectra,20.234)
    hold on
    psd(detrend(SITE_IRGA(:,2)),2^Nspectra,20.234)
    hold off
	title(TitleText)
	zoom on;
    legend('XSITE','SITE')    
    h = get(fig,'chi');
    h1 = get(h(2),'chi');
    set(h1(2),'color',[1 0 0])
    
end
   
if plotSonic 
	fig=fig+1;
	figure(fig)
    TitleText = ['w - wind speed,  '  DateS];
    set(fig,'Name',TitleText)
	plot(nx+delayX_SONIC/20,XSITE_SONIC(:,3),ns,SITE_SONIC(:,3));
	title(TitleText)
	zoom on;
	legend(sprintf('XSITE: %5.2f (%5.2f) m/s',mean(XSITE_SONIC(:,3)),std(XSITE_SONIC(:,3))),...
           sprintf('SITE:  %5.2f (%5.2f) m/s',mean(SITE_SONIC(:,3)),std(SITE_SONIC(:,3)))...
           )
	
	fig=fig+1;
	figure(fig)
    TitleText = ['cup wind speed,  '  DateS];
    set(fig,'Name',TitleText)
	Cup_XSITE = (sqrt(sum((XSITE_SONIC(:,1:3).^2)')))';
	Cup_SITE  = (sqrt(sum(( SITE_SONIC(:,1:3).^2)')))';
	plot(nx+delayX_SONIC/20,Cup_XSITE, ...
         ns                ,Cup_SITE...
         );
	title(TitleText)
	zoom on;
	legend( sprintf('XSITE: %5.2f (%5.2f) m/s',mean(Cup_XSITE),std(Cup_XSITE)),...
            sprintf('SITE : %5.2f (%5.2f) m/s',mean(Cup_SITE ),std(Cup_SITE )),...
            sprintf('RMY  : %5.2f m/s',RMYoung)...
           )

    fig=fig+1;
	figure(fig)
    TitleText = ['Temperature,  ' DateS];
    set(fig,'Name',TitleText)
	meanTemp = mean(SITE_SONIC(:,4));
	%plot(nt,detrend(XSITE_TC(:,1:2),0)+meanTemp,nx+delayX_SONIC/20,detrend(XSITE_SONIC(:,4),0)+meanTemp,ns,detrend(SITE_SONIC(:,4),0)+meanTemp);
	plot(nx+delayX_SONIC/20,detrend(XSITE_SONIC(:,4),0)+meanTemp,ns,detrend(SITE_SONIC(:,4),0)+meanTemp);
	title(TitleText)
	zoom on;
	%legend('TC1','TC2','XSITE','SITE')
	legend( sprintf('XSITE: %5.2f (%5.2f) ^oC',mean(XSITE_SONIC(:,4)),std(XSITE_SONIC(:,4))),...
            sprintf('SITE : %5.2f (%5.2f) ^oC',mean( SITE_SONIC(:,4)),std( SITE_SONIC(:,4)))...
           )

    try
        fig=fig+1;
		figure(fig)
        TitleText = ['Temperatures,  ' DateS];
        set(fig,'Name',TitleText)
		meanTempTc1 = mean(XSITE_TC(:,1));
        meanTempTc2 = mean(XSITE_TC(:,2));
		plot(nt,detrend(XSITE_TC(:,1:2),0)+meanTempTc1);
		%plot(nx+delayX_SONIC/20,detrend(XSITE_SONIC(:,4),0)+meanTemp,ns,detrend(SITE_SONIC(:,4),0)+meanTemp);
		title(TitleText)
		zoom on;
		%legend('TC1','TC2','XSITE','SITE')
		legend( sprintf('Tc1: %5.2f (%5.2f) ^oC',mean(XSITE_TC(:,1)),std(XSITE_TC(:,1))),...
                sprintf('Tc2: %5.2f (%5.2f) ^oC',mean(XSITE_TC(:,2)),std(XSITE_TC(:,2)))...
               )
   catch
       close(fig)
   end

    try
        fig=fig+1;
		figure(fig)
        TitleText = ['Temperatures,  ' DateS];
        set(fig,'Name',TitleText)
        delayTcSonic = fr_delay(XSITE_TC(:,1),XSITE_SONIC(:,4),5000);
        meanTempTc2 = mean(XSITE_TC(:,1));
		plot(nt+(delayTcSonic+delayX_SONIC)/20,detrend(XSITE_TC(:,1),0)+meanTemp,...
             nx+delayX_SONIC/20,detrend(XSITE_SONIC(:,4),0)+meanTemp,...
             ns,detrend(SITE_SONIC(:,4),0)+meanTemp,...
             ns,detrend(SITE_TC,0)+meanTemp...
             );
		%plot(nx+delayX_SONIC/20,detrend(XSITE_SONIC(:,4),0)+meanTemp,ns,detrend(SITE_SONIC(:,4),0)+meanTemp);
		title(['Temperatures,  ' DateS])
		zoom on;
		%legend('TC1','TC2','XSITE','SITE')
		legend( sprintf('Tc1  : %5.2f (%5.2f) ^oC',mean(XSITE_TC(:,1)),std(XSITE_TC(:,1))),...
                sprintf('XSITE: %5.2f (%5.2f) ^oC',mean(XSITE_SONIC(:,4)),std(XSITE_SONIC(:,4))),...
                sprintf(' SITE: %5.2f (%5.2f) ^oC',mean( SITE_SONIC(:,4)),std( SITE_SONIC(:,4))),...
                sprintf('S_Tc : %5.2f (%5.2f) ^oC',mean( SITE_TC),std( SITE_TC))...                
               )
   catch
       close(fig)
   end
    try
        fig=fig+1;
		figure(fig)
        TitleText = ['Sonic Diag,  ' DateS];
        set(fig,'Name',TitleText)
		plot(ns,SITE_SONIC(:,5));
		title(TitleText)
		zoom on;
   catch
       close(fig)
   end
end