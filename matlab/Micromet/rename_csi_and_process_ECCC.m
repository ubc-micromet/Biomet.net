function rename_csi_and_process_ECCC
diary('P:\Sites\Common\rename_csi_and_process_ECCC')
fprintf('=================================================\n')
fprintf('Started: %s\n',datestr(now));
try
    renam_csi_dat_files('P:\Sites\BB\Met');
catch
end
try
    renam_csi_dat_files('P:\Sites\BB2\Met'); 
catch
end
try
    renam_csi_dat_files('P:\Sites\DSM\Met'); 
catch
end
try
    renam_csi_dat_files('P:\Sites\RBM\Met');
catch
end
try
    fprintf('Start ECCC processing\n');
    run_ECCC_climate_station_update
    fprintf('Finish ECCC processing\n');
catch ME
    disp(ME);
end
fprintf('Finished: %s\n',datestr(now));
fprintf('-------------------------------------------------\n')
diary off
