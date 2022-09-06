function fcrnexport(SiteId,traces_fcrn)

%-------------------------------------------
% Export ascii files
%-------------------------------------------
out_inf = fcrnexport_dir(SiteId);

for i = 1:length(out_inf)
    fcrn_table_export(traces_fcrn,out_inf(i).fileId,out_inf(i).pth);
end
