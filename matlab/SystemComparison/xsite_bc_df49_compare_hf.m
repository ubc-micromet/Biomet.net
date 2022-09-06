function xsite_bc_df48_compare_hf(currentDate)

cd(fullfile(xsite_base_path,'BC_DF48','Setup'));
[dd,hh] = fr_get_local_path;

%currentDate = datenum(2005,4,21,16,0,0);
% currentDate = datenum(2005,4,21,14,0,0); % Good example for tower wake


hf_main = FR_read_raw_data(fullfile(dd,[fr_datetofilename(currentDate) '.dc1']),5)'./100;

u_main = sqrt(sum(hf_main(:,1:3).^2,2));

hf_xsite = fr_read_digital2_file(fullfile(dd,[fr_datetofilename(currentDate) '.dx5']));

u_xsite = sqrt(sum(hf_xsite(:,1:3).^2,2));

plot(linspace(0,1800,length(u_main)),u_main,linspace(0,1800,length(u_xsite))+40,u_xsite);
legend('Main','XSITE')
zoom on

[mean(u_main)./mean(u_xsite)]