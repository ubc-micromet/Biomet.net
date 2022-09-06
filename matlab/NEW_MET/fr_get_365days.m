function trace_365days = fr_get_365days(trace_name,SiteId,clean_tv_in)
% trace_365days = fr_get_365days(trace_name,SiteId,clean_tv_in)
% 
% produces a 365 days long trace starting from today
% created 03 july 03, natascha kljun

pth           = biomet_path('yyyy',SiteId,'clean\ThirdStageAutomated');
[yy,mm,dd]    = datevec(clean_tv_in);
Years         = [yy(8000)-1 yy(8000)];
dv_now = datevec(now);

if strcmp(trace_name,'clean_tv');
    tp = '8';
else
    tp = '[]';
end

trace_name1   = read_bor([pth trace_name],eval(tp),[],Years(1),[],1);
trace_name2   = read_bor([pth trace_name],eval(tp),[],Years(2),[],1);
trace_name    = [trace_name1; trace_name2];
clean_tv1     = read_bor([pth 'clean_tv'],8,[],Years(1),[],1);
clean_tv      = [clean_tv1; clean_tv_in];

if dv_now(1) == Years(2)
   ind_now       = min(find(clean_tv >= now));
else
   ind_now       = length(clean_tv);
end

trace_365days = trace_name((ind_now-length(clean_tv_in)+1):ind_now);

return

