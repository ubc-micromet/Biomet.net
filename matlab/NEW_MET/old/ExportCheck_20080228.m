function ExportCheck(Year,SiteId)

out_inf = fcrnexport_dir(SiteId);
trace_str = [];

for i = 1:length(out_inf)
    trace_str_tmp = readDISCSV(Year,out_inf(i).pth);
    if ~isempty(trace_str_tmp)
        trace_str = [trace_str trace_str_tmp(7:end-2)];
    end
end

H = ExportCheckGUI('UserData',[],'Visible','off');
set(H,'UserData',trace_str);
ExportCheckGUI('popupmenu1_Callback',H);

return