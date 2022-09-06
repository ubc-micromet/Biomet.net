function fcrnexport(SiteId,traces_fcrn,flag_local)

%-------------------------------------------
% Export ascii files
%-------------------------------------------

% Nick modified June 28, 2007 to update a local copy of the export database
arg_default('flag_local',0);
out_inf = fcrnexport_dir(SiteId,flag_local);

if flag_local == 0
    for i = 1:length(out_inf)
        fcrn_table_export(traces_fcrn,out_inf(i).fileId,out_inf(i).pth);
    end
else % update local biomet copy of export database right up to current date
    for i = 1:length(out_inf)
        fcrn_table_export(traces_fcrn,out_inf(i).fileId,out_inf(i).pth,0);
    end
end