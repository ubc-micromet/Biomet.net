function run_SMAP_export(year,daybuf);

arg_default('daybuf',7);
% run export for half-hourly L3  data product.  SMAP labels appear in the
% FirstStage ini files for both PA and OBS.  Traces can be added and
% deleted by adding or deleting FCRN_Datatype labels.

Sites={'PA' 'BS'};
for k=1:length(Sites)
    try
        siteId=char(Sites{k});
        switch upper(siteId)
            case 'BS'
                pth_out='\\annex001\FTP_FLUXNET\BERMS\SK-OldBlackSpruce\SMAP\L3_hhourly';
            case 'PA'
                pth_out='\\annex001\FTP_FLUXNET\BERMS\SK-OldAspen\SMAP\L3_hhourly';
        end
        db_ini=db_pth_root;
        data_first = fr_cleaning_siteyear(year,siteId,1,db_ini);
        data_smap = fcrn_trace_str(data_first);
        fcrn_table_export(data_smap,'SMAP',pth_out,0);

    catch
        disp(['SMAP export failed for L3 hhourly data for ' siteId ]);
    end
end
% run export for L4 product: daily averaged tower flux data


for k=1:length(Sites)
    try
        siteId=char(Sites{k});
        switch upper(siteId)
            case 'BS'
                pth_out='\\annex001\FTP_FLUXNET\BERMS\SK-OldBlackSpruce\SMAP\L4_daily';
            case 'PA'
                pth_out='\\annex001\FTP_FLUXNET\BERMS\SK-OldAspen\SMAP\L4_daily';
        end
        %daybuf=7; % seven day latency in data
        export_SMAP_traces_local_standard_time(siteId,year,pth_out,daybuf);

    catch
        disp(['SMAP export failed for L4 daily data for ' siteId ]);
    end
end
return
