function xsite_bc_hd48_check_pgauge(currentDate)

cd(fullfile(xsite_base_path,'BC_DF48','Setup_XSITE'));
pth = fullfile(xsite_base_path,'BC_DF48','met-data','data','050421');
x = fr_read_digital2_file(fullfile(pth,[fr_datetofilename(currentDate),'.DX8']));
y = fr_read_digital2_file(fullfile(pth,[fr_datetofilename(currentDate),'.DX16']));

subplot(4,1,1);
plot(x(:,4))
ylabel('T_{LICOR}')

subplot(4,1,2);
plot(polyval( [1 -203 ] * 0.0197,y(:,3)))
ylabel('P_{LICOR}')

subplot(4,1,3);
plot(x(:,5))
ylabel('P_{gauge}')

subplot(4,1,4);
plot(x(:,1))
ylabel('CO_2')

zoom_together(gcf,'x','on');