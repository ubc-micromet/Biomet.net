function ON_GR_Process_Climate
yearN = 2005;
for monthN = 7:8;
    for dayN = 1:31
        wildCard = sprintf('%4d%02d%02d\\CR5000_flux%4d%02d%02d.dat',yearN,monthN,dayN,yearN,monthN,dayN);
        fr_ON_GR_DataBase(wildCard,'CR5000_progress_list.mat');
    end
end

[dataPth, hhourPth, pthOut] = FR_get_local_path;

Tair=read_bor(fullfile(pthOut,'2005\ON_GR\clean\ThirdStage\air_temperature_main'));
rho_v = read_bor(fullfile(pthOut,'2005\ON_GR\clean\ThirdStage\rho_v'));
RH = rho_v .*1.*8.314.*(Tair+273.15)./18./sat_vp(Tair)/10;
save_bor(fullfile(pthOut,'2005\ON_GR\clean\ThirdStage\relative_humidity_main'),1,RH);

