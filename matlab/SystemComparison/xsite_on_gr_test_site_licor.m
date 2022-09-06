function [Stats_main,HF_main] = xsite_on_gr_test_site_licor(dateIn)

cd('c:\ubc_pc_setup\site_specific');

[Stats_xsite,HF_xsite] = yf_calc_module_main(dateIn,[],2);

cd(fullfile(xsite_base_path,'on_gr','Setup'));

[Stats_main,HF_main] = yf_calc_module_main(dateIn,[],2);


figure('Name',[datestr(dateIn) ' - Site Licor p & Tb']);

tv = [1:length(HF_main.Instrument(3).EngUnits)]./20;

subplot(2,1,1)
plot(tv,HF_main.Instrument(3).EngUnits(:,3))
subplot(2,1,2)
plot(tv,HF_main.Instrument(3).EngUnits(:,4))

zoom_together(gcf,'x','on')


figure('Name',[datestr(dateIn) ' - XSITE Licor p & Tb']);

tv = [1:length(HF_xsite.Instrument(2).EngUnits)]./20;

subplot(2,1,1)
plot(tv,HF_xsite.Instrument(2).EngUnits(:,4))
subplot(2,1,2)
plot(tv,HF_xsite.Instrument(2).EngUnits(:,5))

zoom_together(gcf,'x','on')