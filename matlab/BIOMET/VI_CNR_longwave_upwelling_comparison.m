function VI_CNR_longwave_upwelling_comparison

lwUp_cr = read_db(2005,'cr','climate\clean','radiation_longwave_upwelling_uncorrected_cnr1_45m');
lwUp_yf = read_db(2005,'yf','climate\clean','radiation_longwave_upwelling_uncorrected_cnr1_18m');
lwUp_oy = read_db(2005,'oy','climate\clean','radiation_longwave_upwelling_uncorrected_cnr1_8m');

lwUp_cor_cr = read_db(2005,'cr','clean\secondstage','longwave_radiation_upwelling_main');
lwUp_cor_yf = read_db(2005,'yf','clean\secondstage','longwave_radiation_upwelling_main');
lwUp_cor_oy = read_db(2005,'oy','clean\secondstage','longwave_radiation_upwelling_main');

figure('Name','CNR upwelling longwave comparison');
subplot(2,1,1)
plot([lwUp_oy,lwUp_yf,lwUp_cr]);
subplot(2,1,2)
plot([lwUp_cor_oy,lwUp_cor_yf,lwUp_cor_cr]);

zoom_together(gcf,'x')