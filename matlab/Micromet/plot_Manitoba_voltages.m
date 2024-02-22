%% Script for exporting Manitoba site voltage traces for the last two weeks
% It creates a Gdrive pdf file that we can share with Pascal
%
% Zoran Nesic       File created:       Feb 8, 2024

siteID = 'HOGG';
dateRange = [now-8 now];
yearIn = year(dateRange(2));
pthSite = biomet_path(year(now),siteID,'');
tv=fr_round_time(read_bor(fullfile(pthSite,'flux','Clean_tv'),8));
V_HOGG1 = read_bor(fullfile(pthSite,'monitorSites',sprintf('%s.DSIVin.avg',siteID)));

siteID = 'YOUNG';
pthSite = biomet_path(year(now),siteID,'');
V_YOUNG1 = read_bor(fullfile(pthSite,'monitorSites',sprintf('%s.DSIVin.avg',siteID)));

siteID = 'OHM';
pthSite = biomet_path(year(now),siteID,'');
V_OHM1 = read_bor(fullfile(pthSite,'monitorSites',sprintf('%s.DSIVin.avg',siteID)));

ind = find(tv>=dateRange(1) & tv<= dateRange(end));

figure(1)
plot(datetime(tv(ind),'ConvertFrom','datenum'), [V_HOGG1(ind) V_YOUNG1(ind) V_OHM1(ind)],'LineWidth',2)
grid on
zoom on
ylabel('Volts')
legend('HOGG','YOUNG','OHM')

set(gcf,'PaperPosition',[0.5 0.5 10 7.5])
set(gcf,'PaperSize',[11 8.5])
saveas(gcf,'G:\My Drive\Micromet Lab\Projects\ForPascal\Manitoba_Voltages','pdf')

close(gcf)


